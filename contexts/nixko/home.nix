{
  pkgs,
  config,
  defaultUser,
  ...
}:
let
  variables = config.variables;
  nixos-wallpaper = pkgs.fetchurl {
    name = "nix-wallpaper.png";
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-nineish-solarized-dark.png";
    hash = "sha256-ZBrk9izKvsY4Hzsr7YovocCbkRVgUN9i/y1B5IzOOKo=";
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
      ../../dotfiles/gitconfig.nix
      ../../dotfiles/gitignore.nix
      ../../dotfiles/noctalialockscreen.nix
      ../../dotfiles/dd.nix
      ../../dotfiles/sync.nix
      ../../dotfiles/mypassgen.nix
      ../../dotfiles/wofi.nix
      ../../dotfiles/nwgbar.nix
      ../../dotfiles/countdown.nix
      ../../dotfiles/zed.nix
      ../../dotfiles/work.nix
      ../../dotfiles/jwt.nix
      ../../dotfiles/helix.nix
      ../../dotfiles/kitty.nix
      ../../dotfiles/zellij.nix
      ../../dotfiles/tmux.nix
      ../../dotfiles/batstatus.nix
      ../../dotfiles/gravatar.nix
    ];
    variables = {
      homeDir = "/home/${variables.user}";
      user = defaultUser;
      profileDir = "${variables.homeDir}/.nix-profile";
      prefix = "${variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${variables.homeDir}/workarea/nixpkgs";
      binDir = "${variables.profileDir}/bin";
      lockscreen = "${variables.profileDir}/bin/lockscreen";
      wallpaper = "${nixos-wallpaper}";
      temperatures = [
        {
          device = "k10temp-pci-00c3";
          group = "Tctl";
          field_prefix = "temp1";
        }
      ];
      temperatureFiles = [ ];
      batteries = [ "1" ];
      fullName = "Matej Cotman";
      email = "matej.cotman@kumorion.com";
      gravatar = {
        id = "4da2b4fbe517560a41393bc38a9f2b40a05226ff1adf0840a6a0b841b20fc32f";
        hash = "sha256-bUa7RrA6M+NUqX7OZJ2khUoBrU0iGEzIZSflK4fPKOg=";
      };
      signingkey = "429264DEEB7036EE8B426AA9E97E56DFA314778A";
      locale.all = "en_GB.UTF-8";
      wirelessInterfaces = [ "wlp192s0" ];
      ethernetInterfaces = [ ];
      mounts = [ "/" ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        size = 12.0;
        style = "Bold";
      };
      i3-msg = "${variables.graphical.exec} msg";
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.kitty}/bin/kitty";
        browser = "${variables.profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
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
        # neo = ''${pkgs.neovide}/bin/neovide --neovim-bin "${variables.profileDir}/bin/nvim" --frame none'';
      };
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          output = "eDP-1";
          mode = "2256x1504";
          scale = 1.2;
          workspaces = [ ];
          wallpaper = variables.wallpaper;
          status = "enable";
        }
      ];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "${variables.nixpkgs}";
      };
      startup = [
        "${variables.profileDir}/bin/logseq"
        "${variables.profileDir}/bin/slack"
        "${variables.profileDir}/bin/browser"
        "${variables.profileDir}/bin/keepassxc"
      ];
      services = [
        {
          name = "kdeconnect-indicator";
          delay = 5;
          group = "always";
        }
      ];
    };
    home.stateVersion = "25.05";
    services.swayidle.enable = true;
    services.kanshi.enable = true;
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
    # services.network-manager-applet.enable = true;
    home.packages = with pkgs; [
      slack
      teams-for-linux
      logseq
      keepassxc
      pulseaudio
      networkmanagerapplet
      git-crypt
      jq
      yq-go
      proxychains-ng
      cproxy
      graftcp
      file-roller
      eog
      minikube
      kubectl
      docker-machine-kvm2
      ttyd
      unzip
      stdenv.cc
      gnumake
      # asdf-vm
      python312Packages.python
      devenv
      tmux
      kitty
      neovim-qt
      quickemu
      spice-gtk
      sshfs
      docker
      podman-compose
      docker-compose
    ];
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.chromium.enable = true;
    programs.firefox.enable = true;
    # programs.zsh.initContent = ''
    #   . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
    #   autoload -Uz bashcompinit && bashcompinit
    #   . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
    # '';
    home.sessionVariables = {
      SSH_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    };
  };
}
