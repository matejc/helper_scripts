{ config, pkgs, lib, disko, ... }:
let
  system = pkgs.system;

  disko_luks_nix = ./luks.nix;

  disko_luks = pkgs.writeShellScriptBin "partition-with-disko" ''
    set -e
    if [ -z "$1" ]
    then
      echo "Usage: $0 <disk>"
      exit 1
    fi
    read -s -p "Enter disk encryption password: " password
    mkdir -p /tmp/installer
    echo -n "$password" > /tmp/installer/secret.key
    trap 'rm -rf /tmp/installer' EXIT
    sed "s|/dev/vdb|$1|" "${disko_luks_nix}" > /tmp/installer/disko.nix

    echo "Review disko configuration ..."
    cat /tmp/installer/disko.nix
    echo
    read -p "Partition now? (type yes to continue): " confirmation
    if [[ "$confirmation" == "yes" ]]
    then
      sudo ${disko.packages."${system}".disko}/bin/disko --mode disko /tmp/installer/disko.nix
    fi
  '';
in {
  services.getty.autologinUser = lib.mkForce "root";
  # users.users.root.openssh.authorizedKeys.keys = [ ... ];
  # console.keyMap = "de";
  # hardware.video.hidpi.enable = true;

  environment.systemPackages = [
    disko_luks
  ];

  system.stateVersion = config.system.nixos.release;
}
