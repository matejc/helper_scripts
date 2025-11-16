{ pkgs, lib, inputs, ... }:
let
  helper_scripts = ../..;
in
{
  imports = [
    ../../nixos/modules/home-manager.nix
    inputs.chaotic.nixosModules.default
  ];
  config = {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
        terminal.vt = lib.mkForce 2;
      };
    };
    programs.niri.enable = true;
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
    chaotic.mesa-git.enable = true;
    services.scx.enable = true;
    services.scx.scheduler = "scx_bpfland";
    services.scx.extraArgs = [
      "-m"
      "performance"
    ];
    services.scx.package = pkgs.scx.full;
    boot.kernelModules = ["ntsync"];
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess", GROUP="matejc"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];
    nixpkgs.config = import ../../dotfiles/nixpkgs-config.nix;
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [ pkgs.xdg-user-dirs ];
      };
    };
    hardware.openrazer = {
      # enable = true;
      users = [ "matejc" ];
    };
    users.users.matejc.extraGroups = [
      "openrazer"
      "gamemode"
      "dialout"
    ];
    systemd.services.after-sleep =
      let
        script = pkgs.writeShellScript "after-sleep.sh" ''
          ${pkgs.kmod}/bin/modprobe -r igc
          ${pkgs.kmod}/bin/modprobe igc
        '';
      in
      {
        enable = true;
        description = "Run after sleep";
        after = [ "suspend.target" ];
        wantedBy = [ "suspend.target" ];
        unitConfig = {
          Type = "oneshot";
        };
        serviceConfig = {
          ExecStart = "${script}";
        };
      };
    services.fprintd.enable = true;
    security.pam.services.greetd.fprintAuth = true;
    # fileSystems."/mnt/games/SteamLibrary/steamapps/compatdata/1716740/pfx/drive_c/users/steamuser/Documents/My Games/Starfield/Data" = {
    #   device = "/mnt/games/SteamLibrary/steamapps/common/Starfield/Data";
    #   options = [ "bind" ];
    # };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    services.pipewire.extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;  # ~12ms
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 512;
      };
    };
  };
}
