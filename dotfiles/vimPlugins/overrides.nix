{config, lib, stdenv
, python, cmake, vim, vimUtils, ruby
, which, fetchgit, llvmPackages, rustPlatform
, fzf, skim
, python3, boost, icu, ncurses
, ycmd, rake
, pythonPackages, python3Packages
, substituteAll
, languagetool
, Cocoa, CoreFoundation, CoreServices
, buildVimPluginFrom2Nix

# vim-go denpencies
, asmfmt, delve, errcheck, godef, golint
, gomodifytags, gotags, gotools, go-motion
, gnused, reftools, gogetdoc, gometalinter
, impl, iferr, gocode, gocode-gomod, go-tools
}:

let

  _skim = skim;

in

generated:

with generated;

{

  vim2nix = buildVimPluginFrom2Nix {
    name = "vim2nix";
    src = <nixpkgs/pkgs/misc/vim2nix>;
    dependencies = ["vim-addon-manager"];
  };

  fzfWrapper = buildVimPluginFrom2Nix {
    name = fzf.name;
    src = fzf.src;
    dependencies = [];
  };

  skim = buildVimPluginFrom2Nix {
    name = _skim.name;
    src = _skim.vim;
    dependencies = [];
  };

  LanguageClient-neovim = let
    LanguageClient-neovim-src = fetchgit {
      url = "https://github.com/autozimu/LanguageClient-neovim";
      rev = "59f0299e8f7d7edd0653b5fc005eec74c4bf4aba";
      sha256 = "0x6729w7v3bxlpvm8jz1ybn23qa0zqfgxl88q2j0bbs6rvp0w1jq";
    };
    LanguageClient-neovim-bin = rustPlatform.buildRustPackage {
      name = "LanguageClient-neovim-bin";
      src = LanguageClient-neovim-src;

      cargoSha256 = "1afmz14j7ma2nrsx0njcqbh2wa430dr10hds78c031286ppgwjls";
      buildInputs = stdenv.lib.optionals stdenv.isDarwin [ CoreServices ];

      # FIXME: Use impure version of CoreFoundation because of missing symbols.
      #   Undefined symbols for architecture x86_64: "_CFURLResourceIsReachable"
      preConfigure = stdenv.lib.optionalString stdenv.isDarwin ''
        export NIX_LDFLAGS="-F${CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS"
      '';
    };
  in buildVimPluginFrom2Nix {
    name = "LanguageClient-neovim-2018-09-07";
    src = LanguageClient-neovim-src;

    dependencies = [];
    propogatedBuildInputs = [ LanguageClient-neovim-bin ];

    preFixup = ''
      substituteInPlace "$out"/share/vim-plugins/LanguageClient-neovim/autoload/LanguageClient.vim \
        --replace "let l:path = s:root . '/bin/'" "let l:path = '${LanguageClient-neovim-bin}' . '/bin/'"
    '';
  };

}
