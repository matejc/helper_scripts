{
  pkgs,
  lib,
  config,
  inputs,
  defaultUser,
  ...
}:
let
  variables = config.variables;

  wallpaper = pkgs.fetchurl {
    name = "pexels.jpg";
    url = "https://images.pexels.com/photos/4245826/pexels-photo-4245826.jpeg?cs=srgb&dl=pexels-riccardo-bertolo-2587816-4245826.jpg&fm=jpg&h=1080&w=1920&fit=crop";
    hash = "sha256-SI4ul1AqRaPDEjKMKUlDTk6fvq1VTCXhQLrnSVIy8Dc=";
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
      ../../dotfiles/helix.nix
      ../../dotfiles/mac.nix
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
      signingkey = "E05DF91D31D5B667B0DDAB4B5F456C729CD54863";
      locale.all = "en_US.UTF-8";
      wirelessInterfaces = [ "wlp0s20f3" ];
      ethernetInterfaces = [ ];
      mounts = [ "/" ];
      # hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      temperatures = [
        {
          device = "coretemp-isa-0000";
          group = "Package id 0";
          field_prefix = "temp1";
        }
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
        #q = "${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${variables.profileDir}/bin/nvim";
        #n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${variables.profileDir}/bin/nvim" --frame none'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          output = "eDP-1";
          mode = "1920x1080";
          workspaces = [ ];
          wallpaper = variables.wallpaper;
          scale = 1.0;
          status = "enable";
        }
      ];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "${inputs.nixpkgs}";
      };
      startup = [
        "${variables.profileDir}/bin/browser"
        "${variables.profileDir}/bin/keepassxc"
        "${variables.profileDir}/bin/logseq"
      ];
      services = [
        {
          name = "network-manager-applet";
          delay = 5;
          group = "always";
        }
        {
          name = "kdeconnect-indicator";
          delay = 5;
          group = "always";
        }
      ];
    };

    home.stateVersion = "23.05";
    services.swayidle.enable = true;
    services.kanshi.enable = true;
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
    services.syncthing.enable = true;
    services.syncthing.extraOptions = [
      "-home=${config.variables.homeDir}/Syncthing/.config/syncthing"
    ];
    programs.waybar.enable = true;
    home.packages = with pkgs; [
      networkmanagerapplet
      deploy-rs
      logseq
      nheko
      keepassxc
      kitty
    ];
    programs.firefox.enable = true;
    programs.chromium.enable = true;
    services.network-manager-applet.enable = true;
    systemd.user.services.network-manager-applet.Service.ExecStart =
      lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
  };
}
