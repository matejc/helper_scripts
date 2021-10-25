{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? "matejc"
, uid ? "1000"
, gid ? "1000"
, nameservers ? [ "1.1.1.1" ]
, startCmds ? [ "fakeroot protonvpn connect --fastest" ]
, stopCmds ? [ "fakeroot protonvpn disconnect" ]
, runCmds ? [
  "transmission-daemon --no-portmap --foreground --no-dht -g /home/${user}/.transmission -w /home/${user}/Downloads &"
  "nixGL chromium --no-sandbox --incognito --enable-features=UseOzonePlatform --ozone-platform=wayland http://localhost:9091/transmission/web/"
]
, packages ? [ pkgs.protonvpn-cli pkgs.transmission pkgs.chromium ]
, mounts ? [
  { from = "/home/${user}/.vpn/${name}/chromium"; to = "/home/${user}/.config/chromium"; }
  { from = "/home/${user}/.vpn/${name}/transmission"; to = "/home/${user}/.config/transmission"; }
  { from = "/home/${user}/.vpn/${name}/Downloads"; to = "/home/${user}/Downloads"; }
  { from = "/home/${user}/.vpn/${name}/.pvpn-cli"; to = "/home/${user}/.pvpn-cli"; }
  { from = "${pkgs.dejavu_fonts}/share/fonts/truetype"; to = "/home/${user}/.local/share/fonts"; }
]
, variables ? [ ]
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

  startCmd = writeScript "" ''
    #!${stdenv.shell}
    set -e
    ${concatMapStringsSep "\n" (c: "${c}") startCmds}
  '';

  stopCmd = writeScript "" ''
    #!${stdenv.shell}
    set -e
    ${concatMapStringsSep "\n" (c: "${c}") stopCmds}
  '';

  runCmd = writeScript "" ''
    #!${stdenv.shell}
    set -e
    ${concatMapStringsSep "\n" (c: "${c} &") runCmds}
    wait $(jobs -p)
  '';

  unshareCmd = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    echo $$ >/tmp/pid

    cat ${resolvConf} >/etc/resolv.conf
    echo 10000000000000000000000000000000 > /etc/machine-id
    sysctl net.ipv6.conf.all.disable_ipv6=1

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done

    trap "exit" INT TERM
    trap "${stopCmd}; kill 0" EXIT

    set +e

    ${startCmd}

    ${runCmd}
  '';

  nixGL = (import (builtins.fetchGit {
    url = git://github.com/guibou/nixGL; ref = "refs/heads/main";
  }) { enable32bits = false; }).auto;

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    mkdir -p /home/${user}/.vpn/${name}/

    ${concatMapStringsSep "\n" (m: "[ -f ${m.from} ] || mkdir -p ${m.from}") mounts}

    echo 'root:!:0:0::/root:${interactiveShell}' > /home/${user}/.vpn/${name}/passwd
    echo '${user}:!:${uid}:${gid}::/home/${user}:${interactiveShell}' >> /home/${user}/.vpn/${name}/passwd
    echo > /home/${user}/.vpn/${name}/pid
    echo "127.0.0.1 RESTRICTED" > /home/${user}/.vpn/${name}/hosts

    for i in {1..50}
    do
      vpnnspid="$(cat /home/${user}/.vpn/${name}/pid)"
      if [ ! -z "$vpnnspid" ] && [ -f "/proc/$vpnnspid/cmdline" ]
      then
        slirp4netns --configure --mtu=65520 --disable-host-loopback --disable-dns $vpnnspid tap0
        break
      fi
      sleep 0.1
    done &

    bwrap --ro-bind /nix /nix \
          --bind /tmp/.X11-unix /tmp/.X11-unix --setenv DISPLAY :0 \
          --tmpfs /var/run \
          --tmpfs /var/cache/fontconfig \
          --tmpfs /run \
          --dir /run/user/${uid} \
          --ro-bind /run/user/${uid}/pulse /run/user/${uid}/pulse \
          --ro-bind /run/user/${uid}/wayland-0 /run/user/${uid}/wayland-0 \
          --ro-bind "/run/user/${uid}/pipewire-0" "/run/user/${uid}/pipewire-0" \
          --ro-bind-try /run/opengl-driver/lib/dri /run/opengl-driver/lib/dri \
          --ro-bind ${mesa_drivers}/lib/dri /run/opengl-driver/lib/dri \
          --ro-bind ${mesa_drivers}/share /run/opengl-driver/share \
          --symlink usr/lib /lib \
          --symlink usr/lib64 /lib64 \
          --ro-bind-try /usr/lib /usr/lib \
          --ro-bind-try /usr/lib64 /usr/lib64 \
          --ro-bind-try /usr/share /usr/share \
          --ro-bind-try $XAUTHORITY $XAUTHORITY \
          --dev /dev \
          --dev-bind /dev/dri /dev/dri \
          --dev-bind /dev/net/tun /dev/net/tun \
          --ro-bind /sys/dev/char /sys/dev/char \
          --ro-bind /sys/devices /sys/devices \
          --proc /proc \
          --dir /tmp \
          --ro-bind-try /tmp/.ICE-unix /tmp/.ICE-unix \
          --bind /home/${user}/.vpn/${name}/pid /tmp/pid \
          ${concatMapStringsSep " " (m: "--bind ${m.from} ${m.to}") mounts} \
          --ro-bind /home/${user}/.vpn/${name}/hosts /etc/hosts \
          --ro-bind /home/${user}/.vpn/${name}/passwd /etc/passwd \
          --ro-bind ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt \
          --ro-bind-try /etc/fonts /etc/fonts \
          --unshare-user-try --unshare-ipc --unshare-net --unshare-uts --unshare-cgroup-try \
          --hostname RESTRICTED \
          --setenv HOME /home/${user} \
          --setenv MOZ_ENABLE_WAYLAND 1 \
          --setenv MOZ_X11_EGL 1 \
          --setenv FAKEROOTDONTTRYCHOWN 1 \
          --setenv FONTCONFIG_FILE /etc/fonts/fonts.conf \
          --setenv XCURSOR_PATH /usr/share/icons \
          --setenv XDG_RUNTIME_DIR "/run/user/${uid}" \
          ${concatMapStringsSep " " (m: "--setenv ${m.name} '${m.value}'") variables} \
          --die-with-parent \
          --new-session \
          --uid 0 --gid 0 \
          --cap-add CAP_NET_ADMIN \
          ${unshareCmd}
  '';

  resolvConf = writeText "resolv.conf" ''
    ${concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
  '';
in
  mkShell {
    name = "${user}-${name}";
    buildInputs = [
      bwrap iproute2 shadow slirp4netns curl fakeroot which sysctl procps kmod
      openvpn pstree utillinux fontconfig coreutils libcap strace less
    ] ++ packages;
    shellHook = ''
      ${script}
      exit $?
    '';
  }
