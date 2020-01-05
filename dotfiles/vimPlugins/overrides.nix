{ lib, stdenv
, python, cmake, meson, vim, ruby
, which, fetchFromGitHub, fetchgit, fetchurl, fetchzip
, llvmPackages, rustPlatform
, xkb-switch, fzf, skim, stylish-haskell
, python3, boost, icu, ncurses
, ycmd, rake
, gobject-introspection, glib, wrapGAppsHook
, substituteAll
, languagetool
, Cocoa, CoreFoundation, CoreServices
, buildVimPluginFrom2Nix

# coc-go dependency
, go

# vim-go denpencies
, asmfmt, delve, errcheck, godef, golint
, gomodifytags, gotags, gotools, go-motion
, gnused, reftools, gogetdoc, gometalinter
, impl, iferr, gocode, gocode-gomod, go-tools

# vCoolor dependency
, gnome3
}:

self: super: {


  omnisharp-vim = super.omnisharp-vim.overrideAttrs (old: {
    preFixup = ''
      substituteInPlace $out/share/vim-plugins/omnisharp-vim/autoload/OmniSharp/stdio.vim \
        --replace "expand('<sfile>:p:h:h:h') . '/log/stdio.log'" "\$HOME . '/.omnisharp-vim/stdio.log'"

      substituteInPlace $out/share/vim-plugins/omnisharp-vim/rplugin/python3/deoplete/sources/deoplete_OmniSharp.py \
        --replace "join(OMNISHARP_ROOT, 'log')" "join(os.environ['HOME'], '.omnisharp-vim')"
    '';
  });

}
