{ pkgs, lib ? pkgs.lib }:
let

  #goneovim = pkgs.callPackage ../nixes/goneovim.nix { };
  #fvim = pkgs.callPackage ../nixes/fvim.nix { };

  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    font = {
      family = "SauceCodePro Nerd Font Mono";
      style = "Regular";
      size = 10;
    };
    sway = {
      enable = false;
      disabledInputs = [];
      trackpoint = {
        identifier = "";
        accel = "-0.3";
      };
    };
    i3-msg = "swaymsg";
    i3BarEnable = false;
    lockscreen = "${homeDir}/bin/lockscreen";
    monitors = [ ];
    temperatureFiles = [ "/sys/devices/virtual/thermal/thermal_zone1/temp" ];
    wallpaper = "${variables.homeDir}/Pictures/blade-of-grass.jpg";
    lockImage = "${variables.homeDir}/Pictures/blade-of-grass-blur.png";
    terminal = programs.terminal;
    dropDownTerminal = programs.dropdown;
    term = null;
    programs = {
      filemanager = "${pkgs.dolphin}/bin/dolphin";
      terminal = "${pkgs.kitty}/bin/kitty";
      editor = "${pkgs.nano}/bin/nano";
      dropdown = "env PATH=${pkgs.kitty}/bin:${pkgs.xorg.xrandr}/bin ${pkgs.tdrop}/bin/tdrop -ma -w 98% -x 1% -h 90% kitty";
      #dropdown = "${pkgs.xfce.terminal}/bin/xfce4-terminal --drop-down";
      browser = "${pkgs.chromium}/bin/chromium";
      #google-chrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
      #ff = "${pkgs.firefox}/bin/firefox";
      #c = "${pkgs.vscodium}/bin/codium";
      mykeepassxc = "${pkgs.keepassxc}/bin/keepassxc";
      #nextcloud = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.nextcloud-client}/bin/nextcloud";
      launcher = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title Launcher --hide-scrollbar --hide-toolbar --hide-menubar --drop-down -x ${homeDir}/bin/sway-launcher-desktop";
      myweechat = "${pkgs.konsole}/bin/konsole -e ${pkgs.writeScript "weechat" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.mosh}/bin/mosh weechat@fornax -- attach-weechat
      ''}";
      tug = "${pkgs.turbogit}/bin/tug";
    };
    locale.all = "en_US.utf8";
    startup = [
      #"${homeDir}/bin/nextcloud"
      "${homeDir}/bin/mykeepassxc"
      "${homeDir}/bin/browser"
    ];
    inherit startScript;
    inherit restartScript;
    vims = {
      #f = "${fvim}/bin/fvim --nvim ${variables.homeDir}/bin/nvim";
      #o = "${goneovim}/bin/goneovim --nvim ${variables.homeDir}/bin/nvim";
      q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${variables.homeDir}/bin/nvim";
      n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
    };
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./thissession.nix
    ./oath.nix
    ./httpserver.nix
    ./wcontrol.nix
    ./temp.nix
    ./volume.nix
    ./yaml2nix.nix
    ./jstools.nix
    ./zsh.nix
    ./xfce4-terminal.nix
    ./monitor.nix
    ./programs.nix
    ./any2mp3.nix
    ./sublime.nix
    ./vlc.nix
    ./konsole.nix
    ./connman.nix
    ./sshproxy.nix
    ./chrome_cast_allow.nix
    ./castnow.nix
    ./freecad.nix
    ./bcrypt.nix
    ./nvim.nix
    ./mount.nix
    ./scan.nix
    ./screenshooter.nix
    ./xfce-terminal-dropdown.nix
    #./launcher.nix
    ./bemenu.nix
    ./kitty.nix
    ./bash.nix
    ./starship.nix
    ./keepassxc-browser.nix
    ./startup.nix
    ./trace2scad.nix
    ./superslicer.nix
    ./look.nix
    ./i3config.nix
    ./i3_workspace.nix
    ./waybar.nix
    ./swaylockscreen.nix
    ./sway-launcher-desktop.nix
    ./clearprimary.nix
    ./py3-venv.nix
    ./keepassxc-oath.nix
    ./dd.nix
    ./devenv.nix
    ./stream.nix
  ];

    #${pkgs.procps}/bin/pkill dunst
    #${pkgs.dunst}/bin/dunst &

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}

    systemctl --user start waybar

    ${variables.programs.mykeepassxc} &
    ${variables.programs.browser} &

    echo "DONE"
  '';

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
  '';
in {
  inherit variables dotFilePaths activationScript;
}
