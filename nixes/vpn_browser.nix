{ outInterface }:
{ config, pkgs, lib, ... }:
let
  start_xpra = pkgs.writeScriptBin "start_xpra" ''
    #!${pkgs.stdenv.shell}

    set -e

    sudo -iu browser xpra start --video-encoders=rgb24 --daemon=no --exit-with-children=yes --start-child=$1 ''${@:2}
  '';
  start_vpn_container = pkgs.writeScriptBin "start_vpn_container" ''
    #!${pkgs.stdenv.shell}

    set -e

    sudo nixos-container start vpn
    sudo nixos-container run vpn -- protonvpn c -f
    sudo nixos-container run vpn -- start_xpra $@ &

    sleep 5

    ${pkgs.xpra}/bin/xpra attach socket:///run/xpra-vpn/vpn-0

    sudo nixos-container run vpn -- protonvpn d
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
    forwardPorts = [
      {"containerPort" = 10000; "hostPort" = 10000; "protocol" = "udp";}
    ];
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
      users.users.browser = { isNormalUser = true; uid = 1000; };
      environment.systemPackages = with pkgs; [ xpra chromium protonvpn-cli coreutils start_xpra ];
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
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
  system.activationScripts.container_vpn_startup = ''
    mkdir -p /run/xpra-vpn
    chown -R 1000 /run/xpra-vpn
  '';
  environment.systemPackages = with pkgs; [ start_vpn_container ];
}
