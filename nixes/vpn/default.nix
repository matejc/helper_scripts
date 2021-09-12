{ pkgs ? import <nixpkgs> {}, user ? "matejc", uid ? "1000", gid ? "1000" }:
with pkgs;
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

  unshareCmd = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    echo $$ >/home/${user}/.pid

    sysctl net.ipv6.conf.all.disable_ipv6=1

    fakeroot protonvpn connect --fastest

    ${transmission}/bin/transmission-daemon --no-portmap --foreground --no-dht -g /home/${user}/.transmission -w /home/${user}/Downloads &
    nixGL ${firefox}/bin/firefox --no-remote --private-window http://localhost:9091/transmission/web/
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}

    set -e

    trap "fakeroot protonvpn disconnect" EXIT

    for i in {1..50}
    do
      vpnnspid="$(cat /home/${user}/.pid)"
      if [ ! -z "$vpnnspid" ] && [ -f "/proc/$vpnnspid/cmdline" ]
      then
        slirp4netns --configure --mtu=65520 --disable-host-loopback $vpnnspid tap0
        break
      fi
      sleep 0.1
    done &

    unshare --net --map-root-user ${unshareCmd}
  '';

  nixGL = (import (builtins.fetchGit {url = git://github.com/guibou/nixGL; ref = "main";}) {}).auto;
in
  mkShell {
    buildInputs = [ bwrap iproute2 shadow slirp4netns curl protonvpn-cli fakeroot which sysctl procps kmod openvpn pstree utillinux nixGL.nixGLDefault ];
    shellHook = ''
      set -e

      mkdir -p /home/${user}/.vpn/{mozilla,transmission,Downloads}
      echo 'root:!:0:0::/root:${stdenv.shell}' > /home/${user}/.vpn/passwd
      echo '${user}:!:${uid}:${gid}::/home/${user}:${stdenv.shell}' >> /home/${user}/.vpn/passwd
      echo > /home/${user}/.vpn/pid
      cp /etc/resolv.conf /home/${user}/.vpn/resolv.conf
      echo "127.0.0.1 RESTRICTED" > /home/${user}/.vpn/hosts

      bwrap --ro-bind /nix /nix \
          --bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0 --setenv DISPLAY :0 \
          --ro-bind /etc/machine-id /etc/machine-id \
          --dir /run/user/${uid} \
          --ro-bind /run/user/${uid}/pulse /run/user/${uid}/pulse \
          --ro-bind /run/user/${uid}/wayland-0 /run/user/${uid}/wayland-0 \
          --dev /dev \
          --dev-bind /dev/dri /dev/dri \
          --dev-bind /dev/net/tun /dev/net/tun \
          --ro-bind /sys/dev/char /sys/dev/char \
          --proc /proc \
          --tmpfs /tmp \
          --bind /home/${user}/.vpn/mozilla /home/${user}/.mozilla \
          --bind /home/${user}/.vpn/transmission /home/${user}/.config/transmission \
          --bind /home/${user}/.vpn/Downloads /home/${user}/Downloads \
          --bind /home/${user}/.vpn/pid /home/${user}/.pid \
          --bind /home/${user}/.vpn/.pvpn-cli /home/${user}/.pvpn-cli \
          --bind /home/${user}/.vpn/resolv.conf /etc/resolv.conf \
          --ro-bind /home/${user}/.vpn/hosts /etc/hosts \
          --ro-bind /home/${user}/.vpn/passwd /etc/passwd \
          --unshare-all \
          --share-net \
          --hostname RESTRICTED \
          --setenv HOME /home/${user} \
          --setenv MOZ_ENABLE_WAYLAND 1 \
          --setenv FAKEROOTDONTTRYCHOWN 1 \
          --die-with-parent \
          --new-session \
          ${script}
      exit $?
    '';
  }
