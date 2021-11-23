{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "100"
, nameservers ? [ "1.1.1.1" ]
, vpnStart ? "fakeroot protonvpn connect --fastest"
, vpnStop ? "fakeroot protonvpn disconnect"
, cmds ? [
  #{ start = "transmission-daemon --no-portmap --foreground --no-dht -g ${homeDir}/.transmission -w ${homeDir}/Downloads"; }
  { start = "chromium --no-sandbox --incognito --enable-features=UseOzonePlatform --ozone-platform=wayland http://localhost:9091/transmission/web/"; }
  #{ start = "env MOZ_X11_EGL=1 MOZ_ENABLE_WAYLAND=1 firefox --private-window --no-remote http://localhost:9091/transmission/web/"; }
  #{ start = "qutebrowser http://localhost:9091/transmission/web/"; }
]
, packages ? [ pkgs.protonvpn-cli pkgs.transmission pkgs.chromium ]
, preCmds ? [ ]
, mounts ? [ ]
, variables ? [ ]
, tmpfs ? [ ]
, symlinks ? [ ]
, tmpMounts ? [ ]
, homeDir ? "/var/home/${user}"
, interactiveShell ? "${pkgs.stdenv.shell}" }:
with pkgs;
with lib;
let
  bwrap = stdenv.mkDerivation rec {
    pname = "bubblewrap";
    version = "0.5.0";

    src = fetchurl {
      url = "https://github.com/containers/bubblewrap/releases/download/v${version}/${pname}-${version}.tar.xz";
      sha256 = "sha256-Fv2vM3mdYxBONH4BM/kJGW/pDQxQUV0BC8tCLrWgCBg=";
    };

    nativeBuildInputs = [ libxslt docbook_xsl ];
    buildInputs = [ libcap ];
  };

  nsExecC = writeText "ns_exec.c" ''
    #define _GNU_SOURCE
    #include <fcntl.h>
    #include <sched.h>
    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>

    #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                           } while (0)

    int
    main(int argc, char *argv[])
    {
      int fd;

      if (argc < 3) {
         fprintf(stderr, "%s /proc/PID/ns/FILE cmd args...\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      fd = open(argv[1], O_RDONLY);  /* Get file descriptor for namespace */
      if (fd == -1)
        errExit("open");

      if (setns(fd, 0) == -1)        /* Join that namespace */
        errExit("setns");

      execvp(argv[2], &argv[2]);     /* Execute a command in namespace */
      errExit("execvp");
    }
  '';

  nsSuC = writeText "ns_su.c" ''
    #define _GNU_SOURCE
    #include <fcntl.h>
    #include <sched.h>
    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>

    #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                           } while (0)

    int
    main(int argc, char *argv[])
    {
      int err;

      if (argc < 2) {
         fprintf(stderr, "%s cmd args...\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      uid_t uid = ${uid};
      err = setuid(uid);
      if (err == -1)
        errExit("seteuid");

      execvp(argv[1], &argv[1]);
      errExit("execvp");
    }
  '';

  nsUtils = runCommand "ns_utils" {
    buildInputs = [ stdenv.cc.cc binutils ];
  } ''
    mkdir -p $out/bin
    gcc -o $out/bin/ns_exec -B${stdenv.cc.libc}/lib ${nsExecC}
    gcc -o $out/bin/ns_su -B${stdenv.cc.libc}/lib ${nsSuC}
  '';

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

  supervisorConf = writeText "supervisord.conf" ''
    [supervisord]
    directory = /tmp
    user = root

    [supervisorctl]
    serverurl = unix:///tmp/supervisor.sock

    ${concatImapStringsSep "\n" (i: p: ''
    [program:p${toString i}]
    command = ${mkCmd "p${toString i}" p}
    priority = ${toString i}
    directory = ${homeDir}
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
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    '') cmds}
  '';

  unshareCmd = writeScript "unshare.sh" ''
    #!${stdenv.shell}
    set -e
    echo $$ > /tmp/.vpn/home/ns.pid

    sysctl net.ipv6.conf.all.disable_ipv6=1

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done
    ip addr show dev tap0 || exit 1

    cd ${homeDir}

    stop_vpn() {
      echo "Stopping vpn ..."
      ${vpnStop}
    }
    trap stop_vpn EXIT
    #${vpnStart}

    #bwrap --userns  --bind / / --uid ${uid} --gid ${gid} id
    #ns_exec /proc/$$/ns/user id
    ns_su id

    #supervisord --nodaemon --pidfile=${homeDir}/supervisord.pid --configuration=${supervisorConf}
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
    ln -sf ${shadowFile} ${homeDir}/.vpn/${name}/etc/shadow
    ln -sf ${hostsFile} ${homeDir}/.vpn/${name}/etc/hosts
    ln -sf ${hostnameFile} ${homeDir}/.vpn/${name}/etc/hostname

    ${preCmd}

    set -x
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

    trap 'kill $(cat ${homeDir}/.vpn/${name}/home/supervisord.pid)' EXIT
    trap 'exit 0' SIGINT SIGTERM

    bwrap \
      --bind / / \
      --dev /dev \
      --dev-bind /dev/dri /dev/dri \
      --dev-bind /dev/net/tun /dev/net/tun \
      --bind ${homeDir}/.vpn/${name} /tmp/.vpn \
      --bind ${homeDir}/.vpn/${name}/home ${homeDir} \
      --bind ${homeDir}/.vpn/${name}/root /root \
      --bind ${homeDir}/.vpn/${name}/etc/resolv.conf "$(realpath /etc/resolv.conf)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/hosts "$(realpath /etc/hosts)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/passwd "$(realpath /etc/passwd)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/group "$(realpath /etc/group)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/shadow "$(realpath /etc/shadow)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/hostname "$(realpath /etc/hostname)" \
      --ro-bind ${homeDir}/.vpn/${name}/etc/machine-id "$(realpath /etc/machine-id)" \
      --tmpfs /etc/ssl/certs \
      --ro-bind ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt \
      --unshare-user \
      --unshare-net \
      --unshare-uts \
      --hostname RESTRICTED \
      --new-session \
      --uid 0 --gid 0 \
      --cap-add CAP_NET_ADMIN \
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

  shadowFile = writeText "shadow" ''
    root:!:1::::::
    ${user}:!:1::::::
  '';

  hostsFile = writeText "hosts" ''
    127.0.0.1  RESTRICTED
  '';

  hostnameFile = writeText "hostname" ''RESTRICTED'';
in
  mkShell {
    name = "${user}-${name}";
    buildInputs = [
      iproute2 shadow slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree utillinux fontconfig coreutils libcap strace less
      python39Packages.supervisor gawk dnsutils iptables bwrap nsUtils
    ] ++ packages;
    shellHook = ''
      exec ${script}
    '';
  }
