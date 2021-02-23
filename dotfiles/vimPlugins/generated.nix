# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, overrides ? (self: super: {}) }:

let
  packages = ( self:
{
  async-vim = buildVimPluginFrom2Nix {
    pname = "async-vim";
    version = "2020-12-30";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "async.vim";
      rev = "236debf1a68d69a74f1f6647c273b0477e1ec1bf";
      sha256 = "12xz71182shfj8l300j7wnngxm5zkx2g1c2d4l6dvbk5z1dbzlj6";
    };
  };

  asyncomplete-buffer-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-buffer-vim";
    version = "2020-06-26";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-buffer.vim";
      rev = "018bcf0f712ce0fde3f1f2eaabd7004fccb2d34a";
      sha256 = "0ixc37gzgsf93sl52fa3ywz6bw7cn1406fgimmy5rz0d62b0y8yi";
    };
  };

  asyncomplete-file-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-file-vim";
    version = "2020-10-04";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-file.vim";
      rev = "af59997d19c8f5ee65b448249a9cddc51560e243";
      sha256 = "1fihy0miv41xs1hfzlw4xl57qf0pih7zpp3ca8xc79rvv37ys4d9";
    };
  };

  asyncomplete-omni-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-omni-vim";
    version = "2020-10-17";
    src = fetchFromGitHub {
      owner = "yami-beta";
      repo = "asyncomplete-omni.vim";
      rev = "c9873fb643d5dd4c43b392efdd18a801e9f12fa0";
      sha256 = "0gz48ijwpm7khsynx38pmj88qi4g2c2l9qikk7pj5x143fsvsd4v";
    };
  };

  asyncomplete-tags-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-tags-vim";
    version = "2020-10-04";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-tags.vim";
      rev = "fb48ae7faeb77a1d741616c8fc89b26cb712c6e3";
      sha256 = "1r81dpzfb0h2jf51fkvpw6wgvr2sxphiiipfp17rq6rxh8fl4bk0";
    };
  };

  asyncomplete-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-vim";
    version = "2021-01-28";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete.vim";
      rev = "4be3c16b33c27fce5372bf8bc74e42126c76fe61";
      sha256 = "1y5xlisby7a41naas7r09ins3k9arn5xc5bb6w8k7am6xz3vc3r6";
    };
  };

  ctrlsf-vim = buildVimPluginFrom2Nix {
    pname = "ctrlsf-vim";
    version = "2020-12-19";
    src = fetchFromGitHub {
      owner = "dyng";
      repo = "ctrlsf.vim";
      rev = "c90632e6a27bfd525a2a4c6e108981d4558202c0";
      sha256 = "0lala73xl4gm5nvrmyd2p6qjq8d3k3d28awn8byl7z1bdgii41c9";
    };
  };

  motpat-vim = buildVimPluginFrom2Nix {
    pname = "motpat-vim";
    version = "2017-11-10";
    src = fetchFromGitHub {
      owner = "Houl";
      repo = "motpat-vim";
      rev = "b127e978555282ea13b918edac2ee9ada9a4e0ec";
      sha256 = "0yjx57id4gc8bcjz3y31k77970jcpnkrghr9whb32kb85dxjrg3d";
    };
  };

  neovim-auto-autoread = buildVimPluginFrom2Nix {
    pname = "neovim-auto-autoread";
    version = "2020-07-11";
    src = fetchFromGitHub {
      owner = "thezoq2";
      repo = "neovim-auto-autoread";
      rev = "21fc7d47eaaec03f4e5ab76abacc00d8702e4590";
      sha256 = "0wyzzda5pc58xnq5rb1ik24gb5zvrzlblnb304wp7k6sqb2z21rk";
    };
  };

  neovim-gui-shim = buildVimPluginFrom2Nix {
    pname = "neovim-gui-shim";
    version = "2019-08-06";
    src = fetchFromGitHub {
      owner = "equalsraf";
      repo = "neovim-gui-shim";
      rev = "a2dce90891339b0fbf05700146263adbcb713207";
      sha256 = "0ykx6c7bdcfpc59p6vkphnf8abd0q733rvdrmla5d0xix56scjb9";
    };
  };

  nerdtree = buildVimPluginFrom2Nix {
    pname = "nerdtree";
    version = "2021-02-13";
    src = fetchFromGitHub {
      owner = "preservim";
      repo = "nerdtree";
      rev = "a1fa4a33bf16b6661e502080fc97788bb98afd35";
      sha256 = "1qi2jzrps2c2h8c91rxma445yj8knl41sb5yfg37wjnsbig6jcxl";
    };
  };

  nerdtree-git-plugin = buildVimPluginFrom2Nix {
    pname = "nerdtree-git-plugin";
    version = "2020-12-05";
    src = fetchFromGitHub {
      owner = "Xuyuanp";
      repo = "nerdtree-git-plugin";
      rev = "5fa0e3e1487b17f8a23fc2674ebde5f55ce6a816";
      sha256 = "0nwb3jla0rsg9vb52n24gjis9k4fwn38iqk13ixxd6w5pnn8ax9j";
    };
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2021-02-20";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "a21a509417aa530fb7b54020f590fa5ccc67de77";
      sha256 = "1xlksbcv6va3ih9zg6yw5x6q2d76pr5cs942lh5gcypkx9m2f6r5";
    };
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2021-02-04";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "1bd3dfb77055347d9048cb6661823e9139ac8ce7";
      sha256 = "1d4nrwc3pxdiwisl2wprm0basl66v15kqmmiva68vxl4l46yca3f";
      fetchSubmodules = true;
    };
  };

  python-mode = buildVimPluginFrom2Nix {
    pname = "python-mode";
    version = "2018-04-29";
    src = fetchFromGitHub {
      owner = "python-mode";
      repo = "python-mode";
      rev = "f94b0d7b21714f950f5878b430fbfde21c3b7ad9";
      sha256 = "0zxsa1agigzb9adrwq54pdyl984drdqzz3kkixaijkq77kkdvj0n";
    };
  };

  vim-conque = buildVimPluginFrom2Nix {
    pname = "vim-conque";
    version = "2019-08-14";
    src = fetchFromGitHub {
      owner = "goballooning";
      repo = "vim-conque";
      rev = "d9b35abf0a6c16e93094e243487159fc25b66da4";
      sha256 = "1dk7y1n9gmiwnjpm9k9l5nvjaz6nvinbf6r7w9jnrv20h1giqbdd";
    };
  };

  vim-ctrlspace = buildVimPluginFrom2Nix {
    pname = "vim-ctrlspace";
    version = "2021-01-07";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "6737bfabee7ed99a97c0067227fb8905eaf7853c";
      sha256 = "172wymy9893ygaywnja6fph4zjd787731rwp6p8bm27nydi3vlr2";
    };
  };

  vim-hashicorp-tools = buildVimPluginFrom2Nix {
    pname = "vim-hashicorp-tools";
    version = "2021-02-11";
    src = fetchFromGitHub {
      owner = "hashivim";
      repo = "vim-hashicorp-tools";
      rev = "4a81618e15abe90448aa62284f71992135a98131";
      sha256 = "1yad6spf0lidkgpxz8xf1xwgyar4w83qmb10yp1wprs8l8dyan04";
    };
  };

  vim-monokai-tasty = buildVimPluginFrom2Nix {
    pname = "vim-monokai-tasty";
    version = "2020-12-02";
    src = fetchFromGitHub {
      owner = "patstockwell";
      repo = "vim-monokai-tasty";
      rev = "dd306b0007692f1c0726343ecc008d38b66a8c9b";
      sha256 = "1ljhwi7l70yws1w9j1igdi8prd6z5zq2al8a1p0mix1l6a8pv94z";
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

  vim-perforce = buildVimPluginFrom2Nix {
    pname = "vim-perforce";
    version = "2020-02-05";
    src = fetchFromGitHub {
      owner = "nfvs";
      repo = "vim-perforce";
      rev = "d1dcbe8aca797976678200f42cc2994b7f6c86c2";
      sha256 = "027qcj4y8iywy90izdwifk76rf2wsvhg2iv16f906ya6jxfmkd09";
    };
  };

  Workspace-Manager = buildVimPluginFrom2Nix {
    pname = "Workspace-Manager";
    version = "2010-10-18";
    src = fetchFromGitHub {
      owner = "vim-scripts";
      repo = "Workspace-Manager";
      rev = "f16076629c8d382fbd9b1f136f31209ba6602d68";
      sha256 = "06z1z8q1jkdqaz7gsfwcl2rndxcgqacsawhs84w0p9wvmsqra5c9";
    };
  };

});
in lib.fix' (lib.extends overrides packages)
