# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, overrides ? (self: super: {}) }:

let
  packages = ( self:
{
  async-vim = buildVimPluginFrom2Nix {
    pname = "async-vim";
    version = "2020-01-02";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "async.vim";
      rev = "f67ecb5a1120d0d0fb9312afcf262c829b218ca2";
      sha256 = "13rf9f345rv86chv5sfbnisq3zkwkfxg903wa1xy1ka1kk6hpr7w";
    };
  };

  asyncomplete-lsp-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-lsp-vim";
    version = "2019-11-20";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-lsp.vim";
      rev = "9e7b2492578dca86ed12b6352cb56d9fc8ac9a6e";
      sha256 = "1wbc3znsw7b2x3d2w4wy84bhzggwzsww896x26zl079kpr0szq38";
    };
  };

  asyncomplete-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-vim";
    version = "2019-10-02";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete.vim";
      rev = "db3ab51ef6d42ac410afaea53fc0513afd0d5e25";
      sha256 = "1wc4ksym06ppw5yc245fpnvzpm1738nhf11r5db94icfxxjw4zv6";
    };
  };

  ctrlsf-vim = buildVimPluginFrom2Nix {
    pname = "ctrlsf-vim";
    version = "2020-01-09";
    src = fetchFromGitHub {
      owner = "dyng";
      repo = "ctrlsf.vim";
      rev = "0b29a4deba29fc46f3e5d212f96a0426cb814e69";
      sha256 = "12aib3r8rzvz1iq569x4d36rfmh4ls3ny2sss0liiwpqg62spmv0";
    };
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2019-12-14";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "33b320df0e9fac3433203de3b1df2af6979b0da3";
      sha256 = "0wkpy2byiqkix76yr7jjbppasa759jvppiapyh1w99zj9rqylkmm";
      fetchSubmodules = true;
    };
  };

  vim-lsp = buildVimPluginFrom2Nix {
    pname = "vim-lsp";
    version = "2020-01-09";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "vim-lsp";
      rev = "70234feca47ce355482d1734b66a78de92edd0d1";
      sha256 = "118cn05jzp3ww1bkp5651zs8lirka6qjrfmsjib1amp9lk7c1vjc";
    };
  };

  vim-lsp-settings = buildVimPluginFrom2Nix {
    pname = "vim-lsp-settings";
    version = "2020-01-10";
    src = fetchFromGitHub {
      owner = "mattn";
      repo = "vim-lsp-settings";
      rev = "32c4f9952e0d8ef73a18a969abb89dcca7828516";
      sha256 = "1nqc57b38zsmmjhhcl7jpaxxnl7ya5inxl9n325lj1wv7bcx7cab";
    };
  };

  vim-pasta = buildVimPluginFrom2Nix {
    pname = "vim-pasta";
    version = "2018-09-08";
    src = fetchFromGitHub {
      owner = "sickill";
      repo = "vim-pasta";
      rev = "cb4501a123d74fc7d66ac9f10b80c9d393746c66";
      sha256 = "14rswwx24i75xzgkbx1hywan1msn2ki26353ly2pyvznnqss1pwq";
    };
  };

});
in lib.fix' (lib.extends overrides packages)
