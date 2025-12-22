{
  pkgs,
  config,
  inputs,
  defaultUser,
  ...
}:
let
  variables = config.variables;

  wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://images.pexels.com/photos/11805050/pexels-photo-11805050.jpeg?cs=srgb&dl=pexels-alfomedeiros-11805050.jpg&fm=jpg&w=1920&h=1277";
    hash = "sha256-QyDRY2aawDsFvXqZpL+o8XlsstEau4bmu2xm9ldcmH0=";
  };

  witcher4-wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://cdn-l-thewitcher.cdprojektred.com/media/wallpaper/1399/2560x1600/Witcher_IV_Wallpaper_01_12560x1600_EN.jpeg";
    hash = "sha256-45NayKMOauWh/tKRJ7wPju0SSz/eYiBZAe6OADMcE6Q=";
  };
in
{
  imports = [
    ../../home/variables.nix
    ../../home/misc.nix
    ../../home/misc-gui.nix
    ../../home/dotfiles.nix
    ../../home/nixmy.nix
    ../../home/nix-index-database.nix
    ../../home/niri.nix
  ];

  config = {
    dotfiles.paths = [
      ../../dotfiles/nvim.nix
      ../../dotfiles/xfce4-terminal.nix
      ../../dotfiles/gitconfig.nix
      ../../dotfiles/gitignore.nix
      ../../dotfiles/oath.nix
      ../../dotfiles/jstools.nix
      ../../dotfiles/superslicer.nix
      ../../dotfiles/scan.nix
      ../../dotfiles/noctalialockscreen.nix
      ../../dotfiles/kitty.nix
      ../../dotfiles/dd.nix
      ../../dotfiles/sync.nix
      ../../dotfiles/mypassgen.nix
      ../../dotfiles/wofi.nix
      ../../dotfiles/nwgbar.nix
      ../../dotfiles/helix.nix
      ../../dotfiles/vlc.nix
      ../../dotfiles/mac.nix
      ../../dotfiles/steam.nix
      ../../dotfiles/zed.nix
      ../../dotfiles/caprine.nix
      ../../dotfiles/tmux.nix
      ../../dotfiles/gravatar.nix
    ];

    variables = {
      homeDir = "/home/${variables.user}";
      user = defaultUser;
      profileDir = "${variables.homeDir}/.nix-profile";
      prefix = "${variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${variables.homeDir}/workarea/nixpkgs";
      binDir = "${variables.homeDir}/bin";
      lockscreen = "${variables.profileDir}/bin/lockscreen";
      lockImage = "";
      wallpaper = "${wallpaper}";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      gravatar = {
        id = "4da2b4fbe517560a41393bc38a9f2b40a05226ff1adf0840a6a0b841b20fc32f";
        hash = "sha256-bUa7RrA6M+NUqX7OZJ2khUoBrU0iGEzIZSflK4fPKOg=";
      };
      signingkey = "7F71148FAFC9B2EFE02FB9F466FDC7A2EEA1F8A6";
      locale.all = "en_US.UTF-8";
      wirelessInterfaces = [ "wlp0s20f3" ];
      ethernetInterfaces = [ "eno1" ];
      mounts = [
        "/"
        "/mnt/games"
      ];
      # hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      temperatures = [
        {
          device = "coretemp-isa-0000";
          group = "Package id 0";
          field_prefix = "temp1";
        }
        {
          device = "amdgpu-pci-0300";
          group = "junction";
          field_prefix = "temp2";
        }
      ];
      batteries = [ ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        style = "Bold";
        size = 10.0;
      };
      term = null;
      programs = {
        filemanager = "${pkgs.nemo-with-extensions}/bin/nemo";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.kitty}/bin/kitty";
        # terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        #dropdown = "env WAYLAND_DISPLAY=no  ${pkgs.tdrop}/bin/tdrop -mta -w -4 -y 90% terminal";
        #dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        #dropdown = "${sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.wezterm}/bin/wezterm -a 'start --always-new-process' -m terminal";
        #browser = "${profileDir}/bin/chromium";
        browser = "${variables.profileDir}/bin/firefox";
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
      shell = "${variables.profileDir}/bin/zsh";
      shellRc = "${variables.homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "niri";
        logout = "${variables.graphical.exec} msg action quit --skip-confirmation";
        target = "graphical-session.target";
        waybar.prefix = "niri";
        exec = "${config.programs.niri.package}/bin/niri";
      };
      vims = {
        q = "${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${variables.profileDir}/bin/nvim";
        # n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${variables.profileDir}/bin/nvim" --frame none --no-vsync'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [
        {
          criteria = "DP-2";
          position = "0,0";
          output = "DP-2";
          mode = "1920x1080";
          workspaces = [
            "1"
            "2"
            "3"
            "4"
          ];
          wallpaper = variables.wallpaper;
          scale = 1.0;
          status = "enable";
        }
        {
          criteria = "DP-1";
          position = "2000,0";
          output = "DP-1";
          mode = "2560x1440";
          workspaces = [ "5" ];
          wallpaper = "${witcher4-wallpaper}";
          scale = 1.0;
          status = "enable";
        }
      ];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${variables.profileDir}/bin/browser"
        "${variables.profileDir}/bin/keepassxc"
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
      services = [
        {
          name = "kdeconnect-indicator";
          delay = 5;
          group = "always";
        }
      ];
    };

    home.stateVersion = "20.09";
    services.kanshi.enable = true;
    services.swayidle.enable = true;
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
    services.syncthing.enable = true;
    programs.obs-studio = {
      enable = true;
      plugins = [
        pkgs.obs-studio-plugins.wlrobs
        pkgs.obs-studio-plugins.obs-vkcapture
      ];
    };
    home.packages = [
      inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
    ]
    ++ (with pkgs; [
      keepassxc
      mpv
      logseq
      element-desktop
      steamcmd
      jq
      scanmem
      steam-run
      steamtinkerlaunch
      xwayland-run
      winetricks
      umu-launcher
      nexusmods-app-unfree
      heroic
      swiftpoint
      eog
      file-roller
      wf-recorder
      tmux
      kitty
      networkmanagerapplet
      freecad-wayland
      movemaster
      quickemu
    ]);
    programs.chromium.enable = true;
    # services.network-manager-applet.enable = true;
    programs.firefox.enable = true;
  };
}
