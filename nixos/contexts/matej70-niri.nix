{ pkgs, lib, config, helper_scripts, inputs, ... }:
let
  homeConfig = config.home-manager.users.matejc.home;

  # looking-glass-client = pkgs.callPackage ../../nixes/looking-glass-client.nix {};
  # looking-glass-obs = pkgs.obs-studio-plugins.looking-glass-obs.override { inherit looking-glass-client; };

  nixos-artwork-wallpaper = pkgs.fetchurl {
    name = "nix-wallpaper-nineish-dark-gray.png";
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-nineish-dark-gray.png?raw=true";
    hash = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
  };

  wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://images.pexels.com/photos/2680270/pexels-photo-2680270.jpeg?cs=srgb&dl=pexels-pixelcop-2680270.jpg&fm=jpg&w=1920&h=2562";
    hash = "sha256-DEkplqXqS9hpwHRSg7BucEmSdzu1Un7UhWSgG9Hpc94=";
  };

  witcher4-wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://cdn-l-thewitcher.cdprojektred.com/media/wallpaper/1399/2560x1600/Witcher_IV_Wallpaper_01_12560x1600_EN.jpeg";
    hash = "sha256-45NayKMOauWh/tKRJ7wPju0SSz/eYiBZAe6OADMcE6Q=";
  };

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/xfce4-terminal.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/oath.nix"
      "${helper_scripts}/dotfiles/jstools.nix"
      "${helper_scripts}/dotfiles/superslicer.nix"
      "${helper_scripts}/dotfiles/scan.nix"
      "${helper_scripts}/dotfiles/swaylockscreen.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/vlc.nix"
      "${helper_scripts}/dotfiles/mac.nix"
      "${helper_scripts}/dotfiles/steam.nix"
      "${helper_scripts}/dotfiles/zed.nix"
    ];
    activationScript = ''
      rm -vf ${self.variables.homeDir}/.zshrc.zwc
    '';
    variables = {
      homeDir = homeConfig.homeDirectory;
      user = homeConfig.username;
      profileDir = homeConfig.profileDirectory;
      prefix = "${self.variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${self.variables.homeDir}/workarea/nixpkgs";
      binDir = "${self.variables.homeDir}/bin";
      lockscreen = "${self.variables.binDir}/lockscreen";
      lockImage = "";
      wallpaper = "${wallpaper}";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      signingkey = "7F71148FAFC9B2EFE02FB9F466FDC7A2EEA1F8A6";
      locale.all = "en_US.UTF-8";
      wirelessInterfaces = [ "wlp0s20f3" ];
      ethernetInterfaces = [ "eno1" ];
      mounts = [ "/" "/mnt/games" ];
      # hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      temperatures = [
          { device = "coretemp-isa-0000"; group = "Package id 0"; field_prefix = "temp1"; }
          { device = "amdgpu-pci-0300"; group = "junction"; field_prefix = "temp2"; }
      ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        style = "Bold";
        size = 10.0;
      };
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.kitty}/bin/kitty";
        # terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        #dropdown = "env WAYLAND_DISPLAY=no  ${pkgs.tdrop}/bin/tdrop -mta -w -4 -y 90% terminal";
        #dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        #dropdown = "${sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.wezterm}/bin/wezterm -a 'start --always-new-process' -m terminal";
        #browser = "${profileDir}/bin/chromium";
        browser = "${self.variables.profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        #window-center = dotFileAt "i3config.nix" 4;
        #window-size = dotFileAt "i3config.nix" 5;
        #i3-msg = "${profileDir}/bin/swaymsg";
        #nextcloud = "${nextcloud-client}/bin/nextcloud";
        #keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
        #tmux = "${pkgs.tmux}/bin/tmux";
        caprine = "${pkgs.caprine}/bin/caprine --ozone-platform-hint=auto";
      };
      shell = "${self.variables.profileDir}/bin/zsh";
      shellRc = "${self.variables.homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "niri";
        logout = "${self.variables.graphical.exec} msg action quit --skip-confirmation";
        target = "graphical-session.target";
        waybar.prefix = "niri";
        exec = "${config.programs.niri.package}/bin/niri";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.binDir}/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${self.variables.homeDir}/bin/nvim" --frame none'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "DP-2";
        position = "0,0";
        output = "DP-2";
        mode = "1920x1080";
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = self.variables.wallpaper;
        scale = 1.0;
        status = "enable";
      } {
        criteria = "DP-1";
        position = "2000,0";
        output = "DP-1";
        mode = "2560x1440";
        workspaces = [ "5" ];
        wallpaper = "${witcher4-wallpaper}";
        scale = 1.0;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${self.variables.programs.browser}"
        "${pkgs.keepassxc}/bin/keepassxc"
        "${self.variables.profileDir}/bin/logseq"
      ];
      steam = {
        xrun = [
          "swiftpoint"
        ];
        library = "/mnt/games/SteamLibrary";
        run = {
          # "2420110".compatibilityTool = "SteamTinkerLaunch";
          # "1898300".compatibilityTool = "GE-Proton9-11";
          # "2074920".compatibilityTool = "GE-Proton9-11";
          # "1716740".compatibilityTool = "SteamTinkerLaunch";
        };
      };
    };
    services = [
      # { name = "kanshi"; delay = 1; group = "always"; }
      #{ name = "syncthingtray"; delay = 3; group = "always"; }
      # { name = "kdeconnect"; delay = 4; group = "always"; }
      # { name = "wireplumber"; delay = 4; group = "always"; }
      # { name = "swayidle"; delay = 5; group = "always"; }
      { name = "xdg-desktop-portal"; delay = 5; group = "always"; }
      { name = "network-manager-applet"; delay = 5; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
        vt = 2;
      };
      programs.niri.enable = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      # https://gitlab.freedesktop.org/drm/amd/-/issues/3693#note_2715822
      # boot.kernelPatches = [
      #   {
      #     name = "issue-3693_1";
      #     patch = pkgs.fetchurl {
      #       url = "https://gitlab.freedesktop.org/agd5f/linux/-/commit/1c86c81a86c60f9b15d3e3f43af0363cf56063e7.patch";
      #       hash = "sha256-pv2IABCcBbWhPGLXW8C6bIvZdIl5nabNrM0vdkSIvCc=";
      #     };
      #   }
      #   {
      #     name = "issue-3693_2";
      #     patch = pkgs.fetchurl {
      #       url = "https://gitlab.freedesktop.org/agd5f/linux/-/commit/b8d6daffc871a42026c3c20bff7b8fa0302298c1.patch";
      #       hash = "sha256-GCoR9q0PuD/TuR6w9B2fC0U5QdA/8PCcLTUxi1kJLig=";
      #     };
      #   }
      #   {
      #     name = "issue-3693_3";
      #     patch = pkgs.fetchurl {
      #       url = "https://gitlab.freedesktop.org/agd5f/linux/-/commit/ab75a0d2e07942ae15d32c0a5092fd336451378c.patch";
      #       hash = "sha256-lSjY8J2655yKPJZoieEnVaorCFzV/+rYyH9vaLN8Wcg=";
      #     };
      #   }
      # ];
      # hardware.firmware = let
      #   vcn = pkgs.stdenv.mkDerivation {
      #     name = "vcn";
      #     src = pkgs.fetchurl {
      #       url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/amdgpu/navy_flounder_vcn.bin?id=3e78bb66e604d2140ea3628d27024266a181ca14";
      #       hash = "sha256-OheYiOhZyCsUPyTCPGRIqAiJrePdKk+2RIzKYmPd5es=";
      #       name = "navy_flounder_vcn.bin";
      #     };
      #     unpackPhase = "true";
      #     installPhase = ''
      #       mkdir -p $out/lib/firmware/amdgpu
      #       cp $src $out/lib/firmware/amdgpu/navy_flounder_vcn.bin
      #     '';
      #   };
      # in [
      #   pkgs.linux-firmware
      # ];

      # nix.package = pkgs.nixVersions.nix_2_21;
      nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"
        "electron-27.3.11"
        "olm-3.2.16"
      ];
      services.ipp-usb.enable = true;
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
      programs.gamemode.enable = true;
      hardware.openrazer = {
        # enable = true;
        users = [ "matejc" ];
      };
      users.users.matejc.extraGroups = [ "openrazer" "gamemode" ];
      systemd.services.after-sleep = let
        script = pkgs.writeShellScript "after-sleep.sh" ''
          ${pkgs.kmod}/bin/modprobe -r igc
          ${pkgs.kmod}/bin/modprobe igc
        '';
      in {
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
      security.pam.services.login.fprintAuth = false;
      # fileSystems."/mnt/games/SteamLibrary/steamapps/compatdata/1716740/pfx/drive_c/users/steamuser/Documents/My Games/Starfield/Data" = {
      #   device = "/mnt/games/SteamLibrary/steamapps/common/Starfield/Data";
      #   options = [ "bind" ];
      # };
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      hardware.amdgpu.amdvlk = {
        enable = true;
        support32Bit.enable = true;
      };
    };
    home-configuration = {
      home.stateVersion = "20.09";
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      # services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      #services.syncthing.tray.enable = true;
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-studio-plugins.wlrobs pkgs.obs-studio-plugins.obs-vkcapture ];
      };
      home.packages = [
        inputs.deploy-rs.packages.${pkgs.system}.deploy-rs
      ] ++ (with pkgs; [
          solvespace keepassxc libreoffice aichat mpv
          legcord nheko cinny-desktop
          steamcmd
          jq
          scanmem
          steam-run steamtinkerlaunch yad xwayland-run cage winetricks
          swiftpoint
          logseq
          eog
          file-roller
          wf-recorder
      ]);
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      programs.firefox.enable = true;
      home.sessionVariables.VK_ICD_FILENAMES = "${pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json";
    };
  };
in
  self
