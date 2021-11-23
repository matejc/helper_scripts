{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "1000"
, nameservers ? [ "1.1.1.1" ]
, vpnStart ? "fakeroot protonvpn connect --fastest"
, vpnStop ? "fakeroot protonvpn disconnect"
, cmds ? [
  #{ start = "transmission-daemon --no-portmap --foreground --no-dht -g ${homeDir}/.transmission -w ${homeDir}/Downloads"; }
  #{ start = "chromium --no-sandbox --incognito --enable-features=UseOzonePlatform --ozone-platform=wayland http://localhost:9091/transmission/web/"; }
  #{ start = "firefox --private-window --no-remote http://localhost:9091/transmission/web/"; }
]
, packages ? [ pkgs.protonvpn-cli pkgs.transmission pkgs.firefox ]
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

    mk_swap_overridable() {
      target="$1"
      if [ -z "$target" ]
      then
        echo "$target does not exist!" >&2
        exit 1
      fi
      name=$(echo "$target" | md5sum | awk '{printf $1}')
      mkdir -p /tmp/$name/a /tmp/$name/b
      mount --rbind $target /tmp/$name/a
      mount --rbind /tmp/$name/b $target
    }

    mk_swap_overridable_links() {
      target="$1"
      if [ -z "$target" ]
      then
        echo "$target does not exist!" >&2
        exit 1
      fi
      name=$(echo "$target" | md5sum | awk '{printf $1}')
      mkdir -p /tmp/$name/a /tmp/$name/b
      mount --rbind $target /tmp/$name/a
      mount --rbind /tmp/$name/b $target
      mkdir -p $target/.real
      mount --move /tmp/$name/a $target/.real
      for f in $(find $target/.real -mindepth 1 -maxdepth 1)
      do
        [ -L "$target/$(basename $f)" ] && \
          rm $target/$(basename $f) && \
          ln -s $f $target/$(basename $f)
      done
    }

    mk_overridable_home() {
      name=$(echo "${homeDir}" | md5sum | awk '{printf $1}')
      mkdir -p /tmp/$name/h
      mount --rbind ${homeDir} /tmp/$name/h
      mount --rbind /tmp/$name/h/.vpn/${name}/home ${homeDir}
      mkdir -p ${homeDir}/.real
      mount --move /tmp/$name/h ${homeDir}/.real
      rm -f ${homeDir}/.vpn
      ln -s ${homeDir}/.real/.vpn ${homeDir}/.vpn
    }

    mount -t tmpfs none /run/mount
    mk_swap_overridable_links /run

    mk_swap_overridable /etc
    ln -sf ${homeDir}/.vpn/${name}/etc/resolv.conf /etc/resolv.conf
    ln -sf ${homeDir}/.vpn/${name}/etc/hosts /etc/hosts
    ln -sf ${homeDir}/.vpn/${name}/etc/passwd /etc/passwd
    ln -sf ${homeDir}/.vpn/${name}/etc/hostname /etc/hostname
    ln -sf ${homeDir}/.vpn/${name}/etc/machine-id /etc/machine-id

    mount --bind ${homeDir}/.vpn/${name}/root /root

    mk_overridable_home

    echo $$ > ${homeDir}/.vpn/${name}/home/ns.pid

    sysctl net.ipv6.conf.all.disable_ipv6=1
    sysctl net.ipv4.ip_forward=1

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
      echo "Exiting vpn ..."
      ${vpnStop}
    }
    trap stop_vpn EXIT
    trap "exit 0" SIGINT SIGTERM
    ${vpnStart}

    supervisord --nodaemon --configuration=${supervisorConf}
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e
    mkdir -p ${homeDir}/.vpn/${name}/home
    mkdir -p ${homeDir}/.vpn/${name}/root
    mkdir -p ${homeDir}/.vpn/${name}/etc

    ln -sf ${machineId} ${homeDir}/.vpn/${name}/etc/machine-id

    cat ${resolvConf} > ${homeDir}/.vpn/${name}/etc/resolv.conf
    chmod o+rw ${homeDir}/.vpn/${name}/etc/resolv.conf

    ln -sf ${passwd} ${homeDir}/.vpn/${name}/etc/passwd

    echo > ${homeDir}/.vpn/${name}/home/ns.pid

    ln -sf ${hosts} ${homeDir}/.vpn/${name}/etc/hosts

    ln -sf ${hostname} ${homeDir}/.vpn/${name}/etc/hostname

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

    exec unshare --user --map-root-user --net --mount --kill-child ${unshareCmd}
  '';

  resolvConf = writeText "resolv.conf" ''
    ${concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
  '';

  machineId = writeText "machine-id" ''
    10000000000000000000000000000000
  '';

  passwd = writeText "passwd" ''
    root:!:0:0::/root:${interactiveShell}
    ${user}:!:${uid}:${gid}::${homeDir}:${interactiveShell}
  '';

  hosts = writeText "hosts" ''
    127.0.0.1  RESTRICTED
  '';

  hostname = writeText "hostname" ''RESTRICTED'';
in
  mkShell {
    name = "${user}-${name}";
    buildInputs = [
      iproute2 shadow slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree utillinux fontconfig coreutils libcap strace less
      python39Packages.supervisor gawk dnsutils iptables
    ] ++ packages;
    shellHook = ''
      ${script}
      exit 0
    '';
  }
