{ callPackage, config, lib, vimUtils, vim, darwin, llvmPackages, luaPackages, neovimUtils }:

let

  inherit (vimUtils.override {inherit vim;})
    buildVimPlugin vimGenDocHook vimCommandCheckHook;

  inherit (lib) extends;

  initialPackages = self: {
    # Convert derivation to a vim plugin.
    toVimPlugin = drv:
      drv.overrideAttrs(oldAttrs: {

        nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [
          vimGenDocHook
          vimCommandCheckHook
        ];
        passthru = (oldAttrs.passthru or {}) // {
          vimPlugin = true;
        };
      });
  };

  plugins = callPackage ./generated.nix {
    inherit buildVimPlugin;
    inherit (neovimUtils) buildNeovimPlugin;
  };

  # TL;DR
  # * Add your plugin to ./vim-plugin-names
  # * run ~/workarea/nixpkgs/pkgs/applications/editors/vim/plugins/update.py -p 1 -n -i ./dotfiles/vimPlugins/vim-plugin-names -o ./dotfiles/vimPlugins/generated.nix
  #
  # If additional modifications to the build process are required,
  # add to ./overrides.nix.
  overrides = callPackage ./overrides.nix {
    inherit (darwin.apple_sdk.frameworks) Cocoa CoreFoundation CoreServices;
    inherit buildVimPlugin;
    inherit llvmPackages luaPackages;
  };

  aliases = if config.allowAliases then (import ./aliases.nix lib) else final: prev: {};

  extensible-self = lib.makeExtensible
    (extends aliases
      (extends overrides
        (extends plugins initialPackages)
      )
    );
in
  extensible-self
