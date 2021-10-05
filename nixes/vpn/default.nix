{ pkgs ? import <nixpkgs> {}
, user ? "matejc"
, uid ? "1000"
, gid ? "1000"
, nameservers ? [ "1.1.1.1" ]
, startCmds ? [ "fakeroot protonvpn connect --fastest" ]
, stopCmds ? [ "fakeroot protonvpn disconnect" ]
, runCmds ? [
  "transmission-daemon --no-portmap --foreground --no-dht -g /home/${user}/.transmission -w /home/${user}/Downloads &"
  "firefox --no-remote --private-window http://localhost:9091/transmission/web/"
]
, packages ? [ pkgs.protonvpn-cli pkgs.transmission pkgs.firefox ]
, mounts ? [
  { from = "/home/${user}/.vpn/mozilla"; to = "/home/${user}/.mozilla"; }
  { from = "/home/${user}/.vpn/transmission"; to = "/home/${user}/.config/transmission"; }
  { from = "/home/${user}/.vpn/Downloads"; to = "/home/${user}/Downloads"; }
  { from = "/home/${user}/.vpn/.pvpn-cli"; to = "/home/${user}/.pvpn-cli"; }
] }:
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
    ${concatMapStringsSep "\n" (c: "${c}") runCmds}
  '';

  unshareCmd = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

    echo $$ >/home/${user}/.pid

    sysctl net.ipv6.conf.all.disable_ipv6=1

    sleep 1

    trap "${stopCmd}" EXIT

    ${startCmd}

    ${runCmd}
  '';

  script = writeScript "script.sh" ''
    #!${stdenv.shell}
    set -e

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

  resolvConf = writeText "resolv.conf" ''
    ${concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
  '';
in
  mkShell {
    buildInputs = [ bwrap iproute2 shadow slirp4netns curl fakeroot which sysctl procps kmod openvpn pstree utillinux fontconfig ] ++ packages;
    shellHook = ''
      set -e

      ${concatMapStringsSep "\n" (m: "mkdir -p ${m.from}") mounts}

      echo 'root:!:0:0::/root:${stdenv.shell}' > /home/${user}/.vpn/passwd
      echo '${user}:!:${uid}:${gid}::/home/${user}:${stdenv.shell}' >> /home/${user}/.vpn/passwd
      echo > /home/${user}/.vpn/pid
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
          --bind /home/${user}/.vpn/pid /home/${user}/.pid \
          ${concatMapStringsSep " " (m: "--bind ${m.from} ${m.to}") mounts} \
          --ro-bind ${dejavu_fonts}/share/fonts/truetype /home/${user}/.local/share/fonts \
          --bind ${resolvConf} /etc/resolv.conf \
          --ro-bind /home/${user}/.vpn/hosts /etc/hosts \
          --ro-bind /home/${user}/.vpn/passwd /etc/passwd \
          --unshare-all \
          --share-net \
          --hostname RESTRICTED \
          --setenv HOME /home/${user} \
          --setenv MOZ_ENABLE_WAYLAND 1 \
          --setenv FAKEROOTDONTTRYCHOWN 1 \
          --setenv FONTCONFIG_FILE ${fontconfig.out}/etc/fonts/fonts.conf \
          --die-with-parent \
          --new-session \
          ${script}
      exit $?
    '';
  }
