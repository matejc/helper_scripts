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

, python3Packages
, tree-sitter
}:

self: super: {

  regexplainer = super.regexplainer.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ tree-sitter ];
  });

  omnisharp-vim = super.omnisharp-vim.overrideAttrs (old: {
    preFixup = ''
      substituteInPlace $out/share/vim-plugins/omnisharp-vim/autoload/OmniSharp/stdio.vim \
        --replace "expand('<sfile>:p:h:h:h') . '/log/stdio.log'" "\$HOME . '/.omnisharp-vim/stdio.log'"

      substituteInPlace $out/share/vim-plugins/omnisharp-vim/rplugin/python3/deoplete/sources/deoplete_OmniSharp.py \
        --replace "join(OMNISHARP_ROOT, 'log')" "join(os.environ['HOME'], '.omnisharp-vim')"
    '';
  });

  python-mode = super.python-mode.overrideAttrs (old: rec {
    version = "0.13.0";
    src = fetchgit {
      url = "git://github.com/python-mode/python-mode";
      rev = "refs/tags/${version}";
      sha256 = "126fr813x0066x6q6303fbsjpixz52c8aa7fh3xygi955h6w92bw";
      deepClone = true;
      fetchSubmodules = true;
    };
    #preFixup = ''
      #substituteInPlace $out/share/vim-plugins/python-mode/pymode/lint.py \
        #--replace "    pass" "    raise"
      #cat $out/share/vim-plugins/python-mode/pymode/lint.py
    #'';
    #preFixup = ''
      #substituteInPlace $out/share/vim-plugins/python-mode/pymode/lint.py \
        #--replace "from pylama.lint.extensions" "import sys; sys.path.append('${python3Packages.setuptools}/lib/${python3Packages.python.libPrefix}/site-packages'); from pylama.lint.extensions"
    #'';
  });

}
