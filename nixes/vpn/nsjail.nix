{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "100"
, timeZone ? "UTC"
, nameservers ? [ "1.1.1.1" ]
, vpnStart ? "true"
, vpnStop ? "pkill openvpn"
, openvpnConfig ? "/etc/openvpn/all.conf"
#, openvpnConfig ? null
, run ? null
, runAsUser ? null
, cmds ? [
  #{ start = "kitty zsh"; }
  { start = "transmission-daemon --no-portmap --foreground --no-dht -g ${homeDir}/.transmission -w ${homeDir}/Downloads"; }
  { start = "firefox --private-window --no-remote http://localhost:9091/transmission/web/"; }
]
, packages ? with pkgs; [ transmission firefox zsh kitty ]
, preCmds ? [ ]
, chroot ? "${homeDir}/.vpn/${name}/chroot"
, mounts ? [ ]
, romounts ? [
  { from = "/run/opengl-driver"; to = "/run/opengl-driver"; }
  { from = "${homeDir}/.config/kitty"; to = "${homeDir}/.config/kitty"; }
  { from = "${homeDir}/.zshrc"; to = "${homeDir}/.zshrc"; }
  { from = "${homeDir}/.zlogin"; to = "${homeDir}/.zlogin"; }
  { from = "${homeDir}/.vpn/openvpns"; to = "/etc/openvpn"; }
]
, symlinks ? [ ]
, variables ? [
  { name = "MOZ_ENABLE_WAYLAND"; value = "1"; }
]
, waylandDisplay ? "wayland-1"
, caps ? [ ]
, extraArgs ? ""
, tmpfs ? [ ]
, homeDir ? "/home/${user}"
, newuidmap ? "/run/wrappers/bin/newuidmap"
, newgidmap ? "/run/wrappers/bin/newgidmap"
, interactiveShell ? "${pkgs.stdenv.shell}" }:
with pkgs;
with lib;
let
  nsjail = pkgs.nsjail.overrideDerivation (old: {
    preBuild = ''
      makeFlagsArray+=(USER_DEFINES='-DNEWUIDMAP_PATH=${newuidmap} -DNEWGIDMAP_PATH=${newgidmap}')
    '';
  });

  preCmd = writeScript "pre-cmd.sh" ''
    #!${stdenv.shell}
    ${concatMapStringsSep "\n" (c: "${c}") preCmds}
  '';

  mkCmd = name: { start, stop ? "" }: writeScript "start-${name}.sh" ''
    #!${stdenv.shell}
    set -e
    stop_script() {
      echo "Exiting ${name} ..."
      ${stop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM
    ${start}
    wait $!
  '';

  mkUpCmd = writeScript "start-up.sh" ''
    #!${stdenv.shell}
    set -e
    ${concatImapStringsSep "\n" (i: p: ''
    supervisorctl --serverurl=unix:///tmp/supervisor.sock start p${toString i}
    '') cmds}
  '';

  mkVpnCmd = writeScript "start-vpn.sh" ''
    #!${stdenv.shell}
    set -e
    stop_script() {
      echo "Exiting vpn ..."
      ${vpnStop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM
    ${if openvpnConfig == null then ''
      ${vpnStart}
      ${mkUpCmd}
      while true
      do
        sleep 1
      done
    '' else ''
      cd $(dirname ${openvpnConfig})
      ${openvpn}/bin/openvpn --config '${openvpnConfig}'
    ''}
  '';

  supervisorConf = writeText "supervisord.conf" ''
    [supervisord]
    directory = /root/.supervisord
    user = root
    nodaemon = true
    pidfile = ${homeDir}/supervisord.pid

    [unix_http_server]
    file = /tmp/supervisor.sock

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl = unix:///tmp/supervisor.sock

    [program:vpn]
    command = ${mkVpnCmd}
    priority = 0
    directory = /root
    user = root
    numprocs = 1
    autostart = true
    autorestart = unexpected
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = /root/.supervisord/vpn.log
    stdout_logfile_maxbytes = 0

    ${concatImapStringsSep "\n" (i: p: ''
    [program:p${toString i}]
    command = ${mkCmd "p${toString i}" p}
    priority = ${toString i}
    directory = ${homeDir}
    user = ${user}
    numprocs = 1
    autostart = ${if openvpnConfig == null then "false" else "true"}
    autorestart = true
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = /root/.supervisord/p${toString i}.log
    stdout_logfile_maxbytes = 0
    '') cmds}
  '';

  unshareCmd = writeScript "unshare.sh" ''
    #!${stdenv.shell}
    set -ex
    echo $$ > ${homeDir}/ns.pid

    #sysctl net.ipv6.conf.all.disable_ipv6=1

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done
    ip addr show dev tap0 || exit 1

    mkdir -p /root/.supervisord

    ${if run != null then run else if runAsUser != null then "ns_su_user ${runAsUser}" else "supervisord --configuration=${supervisorConf}"}
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e
    mkdir -p ${homeDir}/.vpn/${name}/chroot/run/user/1000
    mkdir -p ${homeDir}/.vpn/${name}/home
    mkdir -p ${homeDir}/.vpn/${name}/root
    mkdir -p ${homeDir}/.vpn/${name}/etc

    echo > ${homeDir}/.vpn/${name}/home/ns.pid

    cat ${resolvConf} > ${homeDir}/.vpn/${name}/etc/resolv.conf
    chmod o+rw ${homeDir}/.vpn/${name}/etc/resolv.conf

    ln -sf ${machineId} ${homeDir}/.vpn/${name}/etc/machine-id
    ln -sf ${passwdFile} ${homeDir}/.vpn/${name}/etc/passwd
    ln -sf ${groupFile} ${homeDir}/.vpn/${name}/etc/group
    ln -sf ${hostsFile} ${homeDir}/.vpn/${name}/etc/hosts
    ln -sf ${hostnameFile} ${homeDir}/.vpn/${name}/etc/hostname
    ln -sf "${tzdata}/share/zoneinfo/${timeZone}" ${homeDir}/.vpn/${name}/etc/localtime

    ${preCmd}

    for i in {1..50}
    do
      nspid="$(cat ${homeDir}/.vpn/${name}/home/ns.pid)"
      if [ ! -z "$nspid" ] && [ -f "/proc/$nspid/cmdline" ]
      then
        slirp4netns --disable-dns --configure --mtu=65520 --disable-host-loopback $nspid tap0
        break
      fi
      sleep 0.1
    done &

    trap 'kill $(cat ${homeDir}/.vpn/${name}/home/supervisord.pid); kill $(jobs -rp)' EXIT
    trap 'exit 0' SIGINT SIGTERM

    nsjail \
      -Mo \
      --chroot ${chroot} \
      --rw \
      --disable_proc \
      --bindmount ${homeDir}/.vpn/${name}/home:${homeDir} \
      --bindmount ${homeDir}/.vpn/${name}/root:/root \
      --bindmount /sys:/sys \
      --bindmount /dev:/dev \
      --mount none:/tmp:tmpfs:rw \
      --bindmount_ro /nix:/nix \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/hosts:$(realpath /etc/hosts) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/passwd:$(realpath /etc/passwd) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/group:$(realpath /etc/group) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/hostname:$(realpath /etc/hostname) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/machine-id:$(realpath /etc/machine-id) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/localtime:$(realpath /etc/localtime) \
      --mount none:/etc/ssl:tmpfs:rw \
      --bindmount_ro ${cacert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt \
      --tmpfsmount /sbin \
      --symlink ${openresolv}/bin/resolvconf:/sbin/resolvconf \
      --tmpfsmount /bin \
      --tmpfsmount /usr \
      --symlink ${binPath}/bin:/usr/bin \
      --symlink ${bash}/bin/bash:/bin/bash \
      --symlink ${bash}/bin/sh:/bin/sh \
      --tmpfsmount /run \
      --mount none:/run/user/${uid}:tmpfs:rw \
      --bindmount /run/user/${uid}/${waylandDisplay}:/run/user/${uid}/${waylandDisplay} \
      --bindmount /run/user/${uid}/pulse:/run/user/${uid}/pulse \
      --bindmount ${homeDir}/.vpn/${name}/etc/resolv.conf:$(realpath /etc/resolv.conf) \
      --disable_clone_newpid \
      --bindmount /proc:/proc \
      --hostname RESTRICTED \
      --cwd ${homeDir} \
      --uid_mapping 0:101000:1 \
      --gid_mapping 0:100100:1 \
      --uid_mapping ${uid}:${uid}:1 \
      --gid_mapping ${gid}:${gid}:1 \
      --keep_caps \
      --rlimit_as 40960 \
      --rlimit_cpu 10000 \
      --rlimit_nofile 5120 \
      --rlimit_fsize 10240 \
      --bindmount_ro /etc/fonts:/etc/fonts \
      --env FONTCONFIG_FILE=/etc/fonts/fonts.conf \
      --env FC_CONFIG_FILE=/etc/fonts/fonts.conf \
      --env XDG_RUNTIME_DIR=/run/user/${uid} \
      --env HOME=${homeDir} \
      --env USER=${user} \
      --env PATH=${binPaths} \
      --env WAYLAND_DISPLAY=${waylandDisplay} \
      --env PULSE_SERVER=/run/user/${uid}/pulse/native \
      ${concatMapStringsSep " " (c: "--cap ${c}") caps} \
      ${concatMapStringsSep " " (m: "--tmpfsmount ${m}") tmpfs} \
      ${concatMapStringsSep " " (m: "--bindmount ${m.from}:${m.to}") mounts} \
      ${concatMapStringsSep " " (m: "--bindmount_ro ${m.from}:${m.to}") romounts} \
      ${concatMapStringsSep " " (m: "--symlink ${m.from}:${m.to}") symlinks} \
      ${concatMapStringsSep " " (m: "--env ${m.name}=${m.value}") variables} \
      ${extraArgs} \
      ${unshareCmd}
  '';

  resolvConf = writeText "resolv.conf" ''
    ${concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
  '';

  machineId = writeText "machine-id" ''
    10000000000000000000000000000000
  '';

  passwdFile = writeText "passwd" ''
    root:!:0:0::/root:${interactiveShell}
    ${user}:!:${uid}:${gid}::${homeDir}:${interactiveShell}
  '';

  groupFile = writeText "group" ''
    root:x:0:
    ${user}:x:${gid}:${user}
  '';

  hostsFile = writeText "hosts" ''
    127.0.0.1  RESTRICTED
  '';

  hostnameFile = writeText "hostname" ''RESTRICTED'';

  buildInputs = [
      iproute2 slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree util-linux fontconfig coreutils libcap strace less
      python39Packages.supervisor gawk dnsutils iptables nsjail gnugrep
  ] ++ packages;

  binPaths = makeBinPath buildInputs;

  binPath = buildEnv {
    name = "PATH";
    paths = buildInputs;
    pathsToLink = [ "/bin" ];
  };
in
  mkShell {
    name = "${user}-${name}";
    inherit buildInputs;
    shellHook = ''
      exec ${script}
    '';
  }
