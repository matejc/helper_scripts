{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "${variables.homeDir}/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/${variables.user}";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    font = {
      family = "SauceCodePro NF Mono";
      style = "Regular";
      size = "11";
    };
    term = null;
    terminal = null;
    sway.enable = false;
    programs = {
      browser = "Chrome.exe";
      editor = "${pkgs.nano}/bin/nano";
      terminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal";
      shell = "${pkgs.zsh}/bin/zsh";
      zsh = "${pkgs.zsh}/bin/zsh";
    };
    locale.all = "en_US.utf8";
    alacritty.path = "/mnt/c/Program\\ Files/Alacritty/alacritty.exe";
    alacritty.args = ''-o "shell.program='wsl.exe'" -o "shell.args=['-d Ubuntu-20.04 /home/matejc/bin/shell']"'';
    vims.n-dev = "/mnt/c/tools/neovide.exe --wsl";
    vims.n = "/mnt/c/ProgramData/chocolatey/bin/neovide.exe --wsl";
    vims.q = "env NVIM_FRONTEND_PATH=/mnt/c/tools/neovim-qt/bin/nvim-qt.exe ${homeDir}/bin/guinvim";
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./jstools.nix
    ./zsh.nix
    ./programs.nix
    ./starship.nix
    ./nvim.nix
    ./oath.nix
    ./mypassgen.nix
    ./keepassxc-oath.nix
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
