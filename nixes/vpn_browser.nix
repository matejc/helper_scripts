{ outInterface, nameserver ? null, extraPackages ? [] }:
{ config, pkgs, lib, ... }:
let
  xpra = pkgs.xpra.overrideDerivation (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.python3Packages.pyinotify ];
  });
  start_xpra = pkgs.writeScriptBin "start_xpra" ''
    #!${pkgs.stdenv.shell}

    set -e

    su -l -c "${xpra}/bin/xpra start --printing=no --mdns=no --daemon=no --exit-with-children=yes --start-child=$1 ''${@:2}" browser
  '';
  start_vpn_container = pkgs.writeScriptBin "start_vpn_container" ''
    #!${pkgs.stdenv.shell}

    set -e

    sudo nixos-container start vpn
    sudo nixos-container run vpn -- protonvpn c -f

    sudo nixos-container run vpn -- start_xpra "$1" &

    all=("$@")
    for arg in "''${all[@]:1}"
    do
      echo "Starting $arg ..."
      sudo nixos-container run vpn -- su -l -c "$arg" browser &
    done

    while ! ${pkgs.socat}/bin/socat -u OPEN:/dev/null UNIX-CONNECT:/run/xpra-vpn/vpn-0
    do
      echo "Waiting for /run/xpra-vpn/vpn-0 ..."
      sleep 1
    done

    ${xpra}/bin/xpra attach --opengl=yes --video-encoders=rgb24 socket:///run/xpra-vpn/vpn-0 &
    xpra_pid="$!"

    sudo -E bash -c "while [ -d \"/proc/$xpra_pid\" ]; do sleep 1; done; nixos-container run vpn -- su -c 'kill -TERM -1' browser; nixos-container run vpn -- protonvpn d; nixos-container stop vpn"
  '';
in
{
  networking.firewall.extraCommands = ''
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${outInterface} -j MASQUERADE
  '';
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  containers.vpn = {
    enableTun = true;
    privateNetwork = true;
    hostAddress = "192.168.10.10";
    localAddress = "192.168.10.11";
    allowedDevices = [
      { modifier = "rw"; node = "/dev/vga_arbiter"; }
    ];
    bindMounts."/dev/snd" = {
      hostPath = "/dev/snd";
      isReadOnly = false;
    };
    bindMounts."/dev/dri" = {
      hostPath = "/dev/dri";
      isReadOnly = false;
    };
    bindMounts."/run/xpra" = {
      hostPath = "/run/xpra-vpn";
      isReadOnly = false;
    };
    config = {
      users.users.browser = { isNormalUser = true; uid = 1000; extraGroups = [ "video" "audio" ]; };
      environment.systemPackages = with pkgs; [ chromium protonvpn-cli coreutils start_xpra ] ++ extraPackages;
      system.activationScripts.startup = ''
        mkdir -p /run/user/1000
        chown 1000 /run/user/1000
        mkdir -p /run/xpra
        chown -R 1000 /run/xpra
      '';
      environment.loginShellInit = ''
        export XDG_RUNTIME_DIR="/run/user/$(id --user)"
        mkdir -p "$XDG_RUNTIME_DIR"
      '';
      services.xserver.enable = true;
      services.xserver.layout = "us";
      services.xserver.xkbOptions = "eurosign:e";
      services.xserver.videoDrivers = config.services.xserver.videoDrivers;
      hardware.opengl.enable = true;
      hardware.opengl.extraPackages = config.hardware.opengl.extraPackages;
      networking.firewall.enable = false;
      networking.nameservers = lib.optionals (nameserver != null) [ nameserver ];
      boot.kernelPackages = pkgs.linuxPackages_latest;
      programs.chromium = {
        enable = true;
        extensions = [
          "gcbommkclmclpchllfjekcdonpmejbdp"  # https everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # ublock origin
        ];
      };
    };
  };
  system.activationScripts.container_vpn_startup = ''
    mkdir -p /run/xpra-vpn
    chown -R 1000 /run/xpra-vpn
  '';
  environment.systemPackages = with pkgs; [ start_vpn_container ];
}
