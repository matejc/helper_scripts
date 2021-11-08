{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "100"
, nameservers ? [ "1.1.1.1" ]
, vpnStart ? "fakeroot protonvpn connect --fastest"
, vpnStop ? "fakeroot protonvpn disconnect"
, cmds ? [
  { start = "transmission-daemon --no-portmap --foreground --no-dht -g ${homeDir}/.transmission -w ${homeDir}/Downloads"; }
  { start = "firefox --private-window --no-remote http://localhost:9091/transmission/web/"; }
]
, packages ? [ pkgs.protonvpn-cli pkgs.transmission pkgs.firefox ]
, preCmds ? [ ]
, mounts ? [ ]
, variables ? [ ]
, tmpfs ? [ ]
, symlinks ? [ ]
, tmpMounts ? [ ]
, homeDir ? "/var/home/${user}"
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
    while true
    do
      sleep 1
    done
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
    ${vpnStart}
    ${concatImapStringsSep "\n" (i: p: ''
    supervisorctl --serverurl=unix:///tmp/supervisor.sock start p${toString i}
    '') cmds}
    while true
    do
      sleep 1
    done
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
    autostart = false
    autorestart = unexpected
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
    set -e
    echo $$ > /tmp/.vpn/home/ns.pid

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
    supervisord --configuration=${supervisorConf}
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e
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
      --chroot / \
      --rw \
      --disable_proc \
      --bindmount ${homeDir}/.vpn/${name}:/tmp/.vpn \
      --bindmount ${homeDir}/.vpn/${name}/home:${homeDir} \
      --bindmount ${homeDir}/.vpn/${name}/root:/root \
      --bindmount ${homeDir}/.vpn/${name}/etc/resolv.conf:$(realpath /etc/resolv.conf) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/hosts:$(realpath /etc/hosts) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/passwd:$(realpath /etc/passwd) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/group:$(realpath /etc/group) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/hostname:$(realpath /etc/hostname) \
      --bindmount_ro ${homeDir}/.vpn/${name}/etc/machine-id:$(realpath /etc/machine-id) \
      --tmpfsmount /etc/ssl/certs \
      --bindmount_ro ${cacert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt \
      --mount none:/run:tmpfs:uid=0,gid=0 \
      --bindmount_ro /run/opengl-driver:/run/opengl-driver \
      --bindmount /run/user/${uid}:/run/user/${uid} \
      --disable_clone_newpid \
      --hostname RESTRICTED \
      --cwd ${homeDir} \
      --uid_mapping 0:101000:1 \
      --gid_mapping 0:100100:1 \
      --uid_mapping 1000:1000:1 \
      --gid_mapping 100:100:1 \
      --keep_caps \
      --rlimit_nofile 64000 \
      --rlimit_as 64000 \
      --rlimit_cpu 64000 \
      --rlimit_fsize 64000 \
      --keep_env \
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
in
  mkShell {
    name = "${user}-${name}";
    buildInputs = [
      iproute2 slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree utillinux fontconfig coreutils libcap strace less
      python39Packages.supervisor gawk dnsutils iptables nsjail
    ] ++ packages;
    shellHook = ''
      exec ${script}
    '';
  }
