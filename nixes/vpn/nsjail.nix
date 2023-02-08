{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "1000"
, timeZone ? "UTC"
, nameservers ? [ "1.1.1.1" ]
, vpnStart ? "openvpn --config /etc/openvpn/ovpn --daemon --log /root/openvpn.log --auth-user-pass /etc/openvpn/pass"
, vpnStop ? "pkill openvpn"
, openvpnConfig ? null
, run ? null
, runAsUser ? null
, cmds ? [
  { start = "firefox --private-window --no-remote"; }
]
, packages ? with pkgs; [ firefox ]
, preCmds ? [ ]
, chroot ? "${homeDir}/.vpn/${name}/chroot"
, mounts ? [ ]
, romounts ? [
  { from = "/run/opengl-driver"; to = "/run/opengl-driver"; }
  { from = "${homeDir}/.vpn/openvpns"; to = "/etc/openvpn"; }
  { from = "/tmp/.X11-unix/X0"; to = "/tmp/.X11-unix/X0"; }
]
, symlinks ? [ ]
, variables ? [
  { name = "DISPLAY"; value = ":0"; }
  { name = "MOZ_ENABLE_WAYLAND"; value = "1"; }
]
, waylandDisplay ? "wayland-1"
, caps ? [ ]
, extraArgs ? ""
, tmpfs ? [ ]
, homeDir ? "/home/${user}"
, newuidmap ? "/run/wrappers/bin/newuidmap"
, newgidmap ? "/run/wrappers/bin/newgidmap"
, nsjail ? "${homeDir}/.vpn/bin/nsjail"
, interactiveShell ? "${pkgs.stdenv.shell}" }:
with pkgs;
with lib;
let
  nsUtils = import ./ns_utils.nix { inherit pkgs; };

  nsjail = import ../nsjail.nix { inherit pkgs; };

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
      ${vpnStart} || exit 1
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
    directory = ${homeDir}/.supervisord
    user = root
    nodaemon = true
    pidfile = ${homeDir}/.supervisord/.pid

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
    stdout_logfile = ${homeDir}/.supervisord/vpn.log
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
    stdout_logfile = ${homeDir}/.supervisord/p${toString i}.log
    stdout_logfile_maxbytes = 0
    '') cmds}
  '';

  insideCmd = writeScript "inside.sh" ''
    #!${stdenv.shell}
    set -e

    echo -n "$$" > ${homeDir}/.ns.pid

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done
    ip addr show dev tap0 || exit 1

    mkdir -p ${homeDir}/.supervisord

    trap 'kill $(cat ${homeDir}/.supervisord/.pid); kill $(jobs -rp)' SIGINT SIGTERM EXIT

    ${if run != null then run else if runAsUser != null then "ns_su ${uid} ${gid} ${runAsUser}" else "supervisord --configuration=${supervisorConf}"}
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    mkdir -p ${homeDir}/.vpn/${name}/home

    cat ${resolvConf} >${homeDir}/.vpn/${name}/.resolv.conf
    touch ${homeDir}/.vpn/${name}/home/.ns.pid

    ${preCmd}

    for i in {1..50}
    do
      nspid="$(cat ${homeDir}/.vpn/${name}/home/.ns.pid || echo "")"
      if [ ! -z "$nspid" ] && [ -f "/proc/$nspid/cmdline" ]
      then
        slirp4netns --disable-dns --configure --mtu=65520 --disable-host-loopback $nspid tap0
        break
      fi
      sleep 0.1
    done &

    trap 'kill $(cat ${homeDir}/.vpn/${name}/home/.supervisord/.pid); kill $(jobs -rp)' EXIT
    trap 'exit 0' SIGINT SIGTERM

    ${nsjail}/bin/nsjail \
      -Mo \
      --tmpfsmount / \
      --disable_proc \
      --bindmount ${homeDir}/.vpn/${name}/home:${homeDir} \
      --tmpfsmount /root \
      --bindmount /dev:/dev \
      --bindmount /sys:/sys \
      --mount none:/tmp:tmpfs:rw \
      --tmpfsmount /nix \
      --bindmount_ro /nix/store:/nix/store \
      --tmpfsmount /etc \
      --symlink ${hostsFile}:/etc/hosts \
      --symlink ${passwdFile}:/etc/passwd \
      --symlink ${groupFile}/etc/group:/etc/group \
      --symlink ${hostnameFile}:/etc/hostname \
      --symlink ${machineId}:/etc/machine-id \
      --symlink ${tzdata}/share/zoneinfo/${timeZone}:/etc/localtime \
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
      --bindmount ${homeDir}/.vpn/${name}/.resolv.conf:/etc/resolv.conf \
      --disable_clone_newpid \
      --bindmount /proc:/proc \
      --hostname RESTRICTED \
      --cwd / \
      --keep_caps \
      --uid_mapping 0:200000:1 \
      --gid_mapping 0:200000:1 \
      --uid_mapping 1000:1000:1 \
      --gid_mapping 1000:1000:1 \
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
      -- ${insideCmd}
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
    nobody:!:65534:65534::/var/empty:${shadow}/bin/nologin
  '';

  groupFile = writeText "group" ''
    root:x:0:
    users:x:${gid}:${user}
    nogroup:x:65534:nobody
  '';

  hostsFile = writeText "hosts" ''
    127.0.0.1  RESTRICTED
  '';

  hostnameFile = writeText "hostname" ''RESTRICTED'';

  buildInputs = [
      iproute2 slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree util-linux fontconfig coreutils libcap strace less
      python39Packages.supervisor gawk dnsutils iptables gnugrep
      nsUtils shadow
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
