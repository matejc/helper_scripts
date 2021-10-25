{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "1000"
, nameservers ? [ "1.1.1.1" ]
, cmds ? [
  { start = "fakeroot protonvpn connect --fastest"; stop = "fakeroot protonvpn disconnect"; }
  { start = "transmission-daemon --no-portmap --foreground --no-dht -g ${homeDir}/.transmission -w ${homeDir}/Downloads"; }
  { start = "chromium --no-sandbox --incognito --enable-features=UseOzonePlatform --ozone-platform=wayland http://localhost:9091/transmission/web/"; }
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

  preCmd = writeScript "stop.sh" ''
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

  unshareCmd = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    echo $$ >/tmp/pid

    sysctl net.ipv6.conf.all.disable_ipv6=1

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done

    supervisord --nodaemon --pidfile=${homeDir}/supervisord.pid --configuration=${supervisorConf}
  '';

  nixGL = (import (builtins.fetchGit {
    url = git://github.com/guibou/nixGL; ref = "refs/heads/main";
  }) { enable32bits = false; }).auto;

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e
    mkdir -p ${homeDir}/.vpn/${name}/{home,resolve,root}

    cat ${resolvConf} > ${homeDir}/.vpn/${name}/resolve/stub-resolv.conf

    ${concatMapStringsSep "\n" (m: "[ -f ${m.from} ] || mkdir -p ${m.from}") mounts}
    ${concatMapStringsSep "\n" (m: "[ -f ${m.from} ] || mkdir -p ${m.from}") tmpMounts}

    echo 'root:!:0:0::/root:${interactiveShell}' > ${homeDir}/.vpn/${name}/passwd
    echo '${user}:!:${uid}:${gid}::${homeDir}:${interactiveShell}' >> ${homeDir}/.vpn/${name}/passwd
    echo 'messagebus:!:101:101::/tmp:${interactiveShell}' >> ${homeDir}/.vpn/${name}/passwd
    echo > ${homeDir}/.vpn/${name}/pid
    echo > ${homeDir}/.vpn/${name}/home/supervisord.pid

    echo "127.0.0.1 RESTRICTED" > ${homeDir}/.vpn/${name}/hosts

    ${preCmd}

    for i in {1..50}
    do
      vpnnspid="$(cat ${homeDir}/.vpn/${name}/pid)"
      if [ ! -z "$vpnnspid" ] && [ -f "/proc/$vpnnspid/cmdline" ]
      then
        slirp4netns --configure --mtu=65520 --disable-host-loopback --disable-dns $vpnnspid tap0
        break
      fi
      sleep 0.1
    done &

    stop_script() {
      echo exiting ...
      kill $(cat ${homeDir}/.vpn/${name}/home/supervisord.pid)
    }
    trap stop_script SIGINT SIGTERM

    set +e

    bwrap \
      --tmpfs / \
      $(find / -mindepth 1 -maxdepth 1 | grep -v /home | grep -v /root | xargs -i sh -c "test -r '{}' && basename '{}'" | awk '{printf "--bind /"$1" /"$1" "}') \
      --bind ${homeDir}/.vpn/${name}/resolve /run/systemd/resolve \
      --dev /dev \
      --dev-bind /dev/dri /dev/dri \
      --dev-bind /dev/net/tun /dev/net/tun \
      --bind ${homeDir}/.vpn/${name}/pid /tmp/pid \
      --ro-bind ${homeDir}/.vpn/${name}/hosts /etc/hosts \
      --ro-bind ${homeDir}/.vpn/${name}/passwd /etc/passwd \
      --ro-bind ${machineId} /etc/machine-id \
      --bind ${homeDir}/.vpn/${name}/home ${homeDir} \
      --bind ${homeDir}/.vpn/${name}/root /root \
      --unshare-net \
      --unshare-uts \
      --hostname RESTRICTED \
      ${concatMapStringsSep " " (m: ''--tmpfs $(dirname ${m.to}) --bind ${m.from} ${m.to} $(find $(dirname ${m.to})/ -mindepth 1 -maxdepth 1 | grep -v "$(dirname ${m.to})/$(basename ${m.from})" | xargs -i sh -c "test -r '{}' && basename '{}'" | awk -v to=$(dirname ${m.to}) '{printf "--bind "to"/"$1" "to"/"$1" "}')'') tmpMounts} \
      ${concatMapStringsSep " " (m: "--tmpfs ${m}") tmpfs} \
      ${concatMapStringsSep " " (m: "--bind ${m.from} ${m.to}") mounts} \
      ${concatMapStringsSep " " (m: "--symlink ${m.from} ${m.to}") symlinks} \
      ${concatMapStringsSep " " (m: "--setenv ${m.name} ${m.value}") variables} \
      --die-with-parent \
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
in
  mkShell {
    name = "${user}-${name}";
    buildInputs = [
      bwrap iproute2 shadow slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree utillinux fontconfig coreutils libcap strace less
      python39Packages.supervisor
    ] ++ packages;
    shellHook = ''
      ${script}
      exit 0
    '';
  }
