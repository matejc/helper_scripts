{ config, pkgs, ... }:

let
   pkgs2storeContents = l : map (x: { object = x; symlink = "none"; }) l;

   nixpkgs = pkgs.lib.cleanSource pkgs.path;

   channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}"
     { preferLocalBuild = true; }
     ''
      mkdir -p $out
      cp -prd ${nixpkgs.outPath} $out/nixos
      chmod -R u+w $out/nixos
      if [ ! -e $out/nixos/nixpkgs ]; then
        ln -s . $out/nixos/nixpkgs
      fi
      echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
    '';

   preparer = pkgs.writeShellScriptBin "wsl-prepare" ''
     set -e

     mkdir -m 0755 ./bin ./etc
     mkdir -m 1777 ./tmp

     # WSL requires a /bin/sh - only temporary, NixOS's activate will overwrite
     ln -s ${pkgs.stdenv.shell} ./bin/sh

     # WSL also requires a /bin/mount, otherwise the host fs isn't accessible
     ln -s /nix/var/nix/profiles/system/sw/bin/mount ./bin/mount

     # Set system profile
     system=${config.system.build.toplevel}
     ./$system/sw/bin/nix-store --store `pwd` --load-db < ./nix-path-registration
     rm ./nix-path-registration
     ./$system/sw/bin/nix-env --store `pwd` -p ./nix/var/nix/profiles/system --set $system

     # Set channel
     mkdir -p ./nix/var/nix/profiles/per-user/root
     ./$system/sw/bin/nix-env --store `pwd` -p ./nix/var/nix/profiles/per-user/root/channels --set ${channelSources}
     mkdir -m 0700 -p ./root/.nix-defexpr
     ln -s /nix/var/nix/profiles/per-user/root/channels ./root/.nix-defexpr/channels

     # It's now a NixOS!
     touch ./etc/NIXOS
   '';
in
{  system.build.tarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" {
    contents = [];

    storeContents = pkgs2storeContents [
      config.system.build.toplevel
      pkgs.stdenv
      channelSources
    ];

    # Use gzip
    compressCommand = "gzip";
    compressionExtension = ".gz";
  };
}
