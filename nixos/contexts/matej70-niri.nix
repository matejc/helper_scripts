{ pkgs, lib, config, helper_scripts, inputs, ... }:
let
  homeConfig = config.home-manager.users.matejc.home;

  looking-glass-client = pkgs.callPackage ../../nixes/looking-glass-client.nix {};
  looking-glass-obs = pkgs.obs-studio-plugins.looking-glass-obs.override { inherit looking-glass-client; };
  swiftpoint = pkgs.callPackage ../../nixes/swiftpoint.nix {};

  nixos-artwork-wallpaper = pkgs.fetchurl {
    name = "nix-wallpaper-nineish-dark-gray.png";
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-nineish-dark-gray.png?raw=true";
    hash = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
  };

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/programs.nix"
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/xfce4-terminal.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/nix.nix"
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
      "${helper_scripts}/dotfiles/zed.nix"
      "${helper_scripts}/dotfiles/proton.nix"
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
      wallpaper = "${nixos-artwork-wallpaper}";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      signingkey = "7F71148FAFC9B2EFE02FB9F466FDC7A2EEA1F8A6";
      locale.all = "en_US.UTF-8";
      networkInterface = "eno1";
      wirelessInterfaces = [ "wlp3s0" ];
      ethernetInterfaces = [ self.variables.networkInterface ];
      mounts = [ "/" ];
      # hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
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
      };
      shell = "${self.variables.profileDir}/bin/zsh";
      shellRc = "${self.variables.homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "niri";
        logout = "${self.variables.graphical.exec} msg action quit";
        target = "graphical-session.target";
        waybar.prefix = "wlr";
        exec = "${self.variables.profileDir}/bin/niri";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.binDir}/nvim";
        # n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame none'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "HDMI-A-1";
        position = "0,0";
        output = "HDMI-A-1";
        mode = "1920x1080";
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = self.variables.wallpaper;
        scale = 1.0;
        status = "enable";
      } {
        criteria = "DP-1";
        position = "1920,0";
        output = "DP-1";
        mode = "1920x1080";
        workspaces = [ "5" ];
        wallpaper = self.variables.wallpaper;
        scale = 1.0;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
        "${self.variables.programs.browser}"
        "${self.variables.profileDir}/bin/chromium"
        "${self.variables.programs.terminal}"
        "${pkgs.keepassxc}/bin/keepassxc"
        "${self.variables.profileDir}/bin/logseq"
      ];
    };
    services = [
      # { name = "kanshi"; delay = 1; group = "always"; }
      #{ name = "syncthingtray"; delay = 3; group = "always"; }
      { name = "kdeconnect"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 2; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
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
      boot.kernelPackages = pkgs.linuxPackages_latest;
      nix.package = pkgs.nixVersions.nix_2_21;
      nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"
        "electron-27.3.11"
      ];
      services.flatpak.enable = true;
      services.ipp-usb.enable = true;
    };
    home-configuration = {
      home.stateVersion = "20.09";
      programs.niri.enable = true;
      services.kanshi.enable = true;
      services.swayidle = {
        enable = true;
        events = lib.mkForce [
          { event = "before-sleep"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "lock"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "after-resume"; command = lib.concatMapStringsSep "; " (o: ''${self.variables.graphical.exec} msg output ${o.output} on'') self.variables.outputs; }
          { event = "unlock"; command = lib.concatMapStringsSep "; " (o: ''${self.variables.graphical.exec} msg output ${o.output} on'') self.variables.outputs; }
        ];
        timeouts = lib.mkForce [
            { timeout = 120; command = "${self.variables.binDir}/lockscreen"; }
            {
                timeout = 300;
                command = lib.concatMapStringsSep "; " (o: ''${self.variables.graphical.exec} msg output ${o.output} off'') self.variables.outputs;
                resumeCommand = lib.concatMapStringsSep "; " (o: ''${self.variables.graphical.exec} msg output ${o.output} on'') self.variables.outputs;
            }
        ];
      };
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      #services.syncthing.tray.enable = true;
      programs.waybar.enable = true;
      programs.obs-studio = {
        enable = true;
        plugins = [ looking-glass-obs pkgs.obs-studio-plugins.wlrobs ];
      };
      home.packages = [
        inputs.deploy-rs.packages.${pkgs.system}.deploy-rs
        swiftpoint
      ] ++ (with pkgs; [
          solvespace keepassxc libreoffice aichat vlc
          discord
          lutris protontricks winetricks steamcmd steamtinkerlaunch protonup-qt minigalaxy wineWowPackages.unstableFull
          super-slicer-latest
          uhk-agent
          jq
          scanmem
          caprine-bin
          steam-run
          logseq
      ]);
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      systemd.user.services.kdeconnect.Install.WantedBy = lib.mkForce [ "non-existing-target" ];
      systemd.user.services.kdeconnect-indicator.Install.WantedBy = lib.mkForce [ "non-existing-target" ];
      systemd.user.services.kdeconnect-indicator.Unit.Requires = lib.mkForce [];
      programs.firefox.enable = true;
      home.sessionVariables.SDL_VIDEODRIVER = pkgs.lib.mkForce "x11";
    };
  };
in
  self
