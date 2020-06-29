{pkgs?import <nixpkgs> {}}:
let
  variables = { font.family = "Fira Code"; font.size = "13"; homeDir = "/home/matejc"; };
  nvim = import ../dotfiles/nvim.nix { inherit pkgs variables; lib = pkgs.lib; config = pkgs.config; };
in
  {
    nvim-lsp-install = (pkgs.lib.elemAt nvim 0).source;
    nvim = (pkgs.lib.elemAt nvim 1).source;
  }
