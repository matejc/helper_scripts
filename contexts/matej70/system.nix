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
    ../../nixos/modules/niri.nix
    ../../nixos/modules/physical.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    variables = {
      sleepMode = "deep";
      graphicalSessionCmd = "/home/${defaultUser}/.nix-profile/bin/niri-session";
    };
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    services.scx.enable = true;
    services.scx.scheduler = "scx_bpfland";
    services.scx.extraArgs = [
      "-m"
      "performance"
    ];
    services.scx.package = pkgs.scx.full;
    # boot.kernelParams = [ "mem_sleep_default=s2idle" ];
    boot.kernelModules = [ "ntsync" ];
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess", GROUP="users"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
      (pkgs.writeTextFile {
        name = "keychron-udev-rules";
        text = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess", GROUP="plugdev"
          KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="3434", ENV{ID_INPUT_JOYSTICK}=="*?", ENV{ID_INPUT_JOYSTICK}=""
        '';
        destination = "/etc/udev/rules.d/70-keychron.rules";
      })
      (pkgs.callPackage ../../nixes/swiftpoint.nix { })
    ];

    systemd.services.swiftpoint-suspend-fix = {
      enable = false;
      description = "Disable Swiftpoint USB ports during suspend";

      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      partOf = [ "sleep.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        : > /run/swiftpoint-disabled-ports

        for dev in /sys/bus/usb/devices/*; do
          [ "$(cat "$dev/idVendor" 2>/dev/null)" = "214e" ] || continue

          real="$(readlink -f "$dev")"
          name="$(basename "$real")"
          parent="$(dirname "$real")"

          port="''${name##*.}"

          disable="$(
            find "$parent" -maxdepth 3 -type f \
              -path "*-port$port/disable" \
              -print -quit
          )"

          [ -n "$disable" ] || continue

          echo "Disable: $(cat "$dev/idVendor"):$(cat "$dev/idProduct") via $(basename "$(dirname "$disable")")"
          echo "$disable" >> /run/swiftpoint-disabled-ports
          echo 1 > "$disable"
        done
      '';

      postStop = ''
        [ -f /run/swiftpoint-disabled-ports ] || exit 0

        while read -r disable; do
          [ -e "$disable" ] || continue

          echo "Enable: $(basename "$(dirname "$disable")")"
          echo 0 > "$disable"
        done < /run/swiftpoint-disabled-ports

        rm -f /run/swiftpoint-disabled-ports
      '';
    };

    nixpkgs.config = import ../../dotfiles/nixpkgs-config.nix;
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [ pkgs.xdg-user-dirs ];
      };
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
    hardware.openrazer = {
      # enable = true;
      users = [ defaultUser ];
    };
    users.users.${defaultUser}.extraGroups = [
      "openrazer"
      "gamemode"
      "dialout"
      "vboxusers"
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
    security.pam.u2f = {
      enable = true;
      settings.cue = true;
    };
    security.pam.services.greetd.fprintAuth = true;
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
    services.printing.enable = true;
    services.avahi.enable = true;
    hardware.keyboard.qmk.enable = true;

    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = [
        pkgs.obs-studio-plugins.wlrobs
        pkgs.obs-studio-plugins.obs-vkcapture
        pkgs.obs-studio-plugins.obs-vaapi
      ];
    };

    # virtualisation.virtualbox.host.enable = true;
  };
}
