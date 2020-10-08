{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = {
      family = "Source Code Pro";
      extra = "Semibold";
      size = "10";
    };
    sway.enable = false;
    terminal = programs.terminal;
    dropDownTerminal = programs.dropdown;
    term = null;
    browser = programs.chromium;
    programs = {
      filemanager = "${pkgs.dolphin}/bin/dolphin";
      terminal = "${pkgs.konsole}/bin/konsole";
      dropdown = "${pkgs.tdrop}/bin/tdrop -ma -w 98% -x 1% -h 90% terminal";
      chromium = "${pkgs.chromium}/bin/chromium";
      ff = "${pkgs.firefox}/bin/firefox";
      c = "${pkgs.vscodium}/bin/codium";
      mykeepassxc = "${pkgs.keepassx-community}/bin/keepassxc ${homeDir}/.secure/p.kdbx";
      nextcloud-client = "${pkgs.nextcloud-client}/bin/nextcloud";
      myweechat = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title WeeChat '${pkgs.writeScript "weechat" "${pkgs.mosh}/bin/mosh weechat@fornax -- attach-weechat"}' &";
    };
    startup = [
      "${homeDir}/bin/nextcloud-client"
      "${homeDir}/bin/mykeepassxc"
      "${homeDir}/bin/chromium"
      "${pkgs.qownnotes}/bin/QOwnNotes"
    ];
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
    ./launcher.nix
    ./bemenu.nix
    ./kitty.nix
    ./bash.nix
    ./starship.nix
    ./keepassxc-browser.nix
    ./startup.nix
  ];

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
  '';
in {
  inherit variables dotFilePaths activationScript;
}