{
  pkgs,
  inputs,
  defaultUser,
  ...
}:
{
  imports = [
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/misc-gui.nix
    ../../nixos/modules/physical.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    variables = {
      sleepMode = "deep";
      graphicalSessionCmd = "/home/${defaultUser}/.nix-profile/bin/niri-session";
    };
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    services.scx.enable = true;
    services.scx.scheduler = "scx_bpfland";
    services.scx.extraArgs = [
      "-m"
      "performance"
    ];
    services.scx.package = pkgs.scx.full;
    boot.kernelModules = [ "ntsync" ];
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess", GROUP="${defaultUser}"'';
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
      users = [ defaultUser ];
    };
    users.users.${defaultUser}.extraGroups = [
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
    security.pam.services.quickshell.fprintAuth = true;
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
        "default.clock.quantum" = 512; # ~12ms
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 512;
      };
    };
  };
}
