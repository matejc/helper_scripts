{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/nix-index-database-download";
  source = pkgs.writeShellScript "nix-index-rebuild.sh" ''
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    # -N will only download a new version if there is an update.
    wget -q -N https://github.com/nix-community/nix-index-database/releases/latest/download/$filename
    ln -f $filename files
  '';
} {
  target = "${variables.homeDir}/bin/,";
  source = pkgs.writeShellScript "comma.sh" ''
    #!${pkgs.stdenv.shell}
    exec ${pkgs.comma}/bin/, $@
  '';
}]
