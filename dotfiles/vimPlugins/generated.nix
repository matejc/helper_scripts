# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub }:

final: prev:
{
  async-vim = buildVimPluginFrom2Nix {
    pname = "async.vim";
    version = "2021-03-21";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "async.vim";
      rev = "0fb846e1eb3c2bf04d52a57f41088afb3395212e";
      sha256 = "1glzg0i53wkm383y1vbddbyp1ivlsx2hivjchiw60sr9gccn8f8l";
    };
    meta.homepage = "https://github.com/prabirshrestha/async.vim/";
  };

  asyncomplete-buffer-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-buffer.vim";
    version = "2020-06-26";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-buffer.vim";
      rev = "018bcf0f712ce0fde3f1f2eaabd7004fccb2d34a";
      sha256 = "0ixc37gzgsf93sl52fa3ywz6bw7cn1406fgimmy5rz0d62b0y8yi";
    };
    meta.homepage = "https://github.com/prabirshrestha/asyncomplete-buffer.vim/";
  };

  asyncomplete-file-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-file.vim";
    version = "2020-10-04";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-file.vim";
      rev = "af59997d19c8f5ee65b448249a9cddc51560e243";
      sha256 = "1fihy0miv41xs1hfzlw4xl57qf0pih7zpp3ca8xc79rvv37ys4d9";
    };
    meta.homepage = "https://github.com/prabirshrestha/asyncomplete-file.vim/";
  };

  asyncomplete-omni-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-omni.vim";
    version = "2021-04-11";
    src = fetchFromGitHub {
      owner = "yami-beta";
      repo = "asyncomplete-omni.vim";
      rev = "f13986b671a37d6320476af6bc066697e71463c1";
      sha256 = "191n7j0m9z5skzzvl6cdlkb7pl7n65g4wiqxdpawbicw5zk80sd4";
    };
    meta.homepage = "https://github.com/yami-beta/asyncomplete-omni.vim/";
  };

  asyncomplete-tags-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-tags.vim";
    version = "2021-04-29";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-tags.vim";
      rev = "041af0565f2c16634277cd29d2429c573af1dac4";
      sha256 = "0i1ahg96j1ixyps0lfzl7w7skd64y6br1zn3bms447341zw4lc0k";
    };
    meta.homepage = "https://github.com/prabirshrestha/asyncomplete-tags.vim/";
  };

  asyncomplete-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete.vim";
    version = "2021-08-19";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete.vim";
      rev = "73ac8e4e4525ba48e82d0f30643987b015233d4e";
      sha256 = "0gbmkxrxcwr5adzp2j7dd64dpzc775m1b9sv0si96gh9pb6119q2";
    };
    meta.homepage = "https://github.com/prabirshrestha/asyncomplete.vim/";
  };

  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline.nvim";
    version = "2021-11-01";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "782fab8a2352e872dc991c42f806dae18e848b2d";
      sha256 = "0j5r0cgcdgnqdd0fd6y9b0nh301xyb6b2vgqc34rdk30gam7h5d1";
    };
    meta.homepage = "https://github.com/akinsho/bufferline.nvim/";
  };

  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2021-11-15";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "274ba7baa2ca74776909cb8eb14e3d4ce36e7958";
      sha256 = "1vfqjskfzdkwjs6gcm3yvff7c37ip3r35p45q97gyr4whn5i78vn";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };

  cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "cmp-cmdline";
    version = "2021-11-08";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "0ca73c3a50b72c2ca168d8904b39aba34d0c4227";
      sha256 = "1777rv9mh3bar8lp5i4af7kip5j3s4ib8a83b67clga8pcdjla4d";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2021-11-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "134117299ff9e34adde30a735cd8ca9cf8f3db81";
      sha256 = "1jnspl08ilz9ggkdddk0saxp3wzf05lll5msdfb4770q3bixddwc";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2021-11-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "98ded32b9c4d95aa95af70b9979b767f39073f0e";
      sha256 = "1axx401sikh9ylji3d6cmgn4xsrzzfmlc1akfv1q709chv0a6r2h";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-vsnip = buildVimPluginFrom2Nix {
    pname = "cmp-vsnip";
    version = "2021-11-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-vsnip";
      rev = "0abfa1860f5e095a07c477da940cfcb0d273b700";
      sha256 = "1vhw2qx8284bskivc2jyijl93g1b1z9hzzbq2l9b4aw6r23frbgc";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-vsnip/";
  };

  ctrlsf-vim = buildVimPluginFrom2Nix {
    pname = "ctrlsf.vim";
    version = "2021-09-14";
    src = fetchFromGitHub {
      owner = "dyng";
      repo = "ctrlsf.vim";
      rev = "253689525fddfcb78731bac2d5125b9579bfffb0";
      sha256 = "1xpff867cj1wyqd4hs7v12p7lsmrihmav2z46452q59f6zby5dp4";
    };
    meta.homepage = "https://github.com/dyng/ctrlsf.vim/";
  };

  galaxyline-nvim = buildVimPluginFrom2Nix {
    pname = "galaxyline.nvim";
    version = "2021-04-25";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "galaxyline.nvim";
      rev = "d544cb9d0b56f6ef271db3b4c3cf19ef665940d5";
      sha256 = "1390lqsqdcj1q89zn6y5qrm1id7p8fnpy07vlz6mm4cki47211mb";
    };
    meta.homepage = "https://github.com/glepnir/galaxyline.nvim/";
  };

  git-blame-vim = buildVimPluginFrom2Nix {
    pname = "git-blame.vim";
    version = "2019-08-02";
    src = fetchFromGitHub {
      owner = "zivyangll";
      repo = "git-blame.vim";
      rev = "9d144b7bed5d8f1c9259551768b7f3b3d1294917";
      sha256 = "06zb5xcc59k25rpwl46j82fcqckiznmj97v6i0mwlb8jhqqrhy9j";
    };
    meta.homepage = "https://github.com/zivyangll/git-blame.vim/";
  };

  gruvbox-material = buildVimPluginFrom2Nix {
    pname = "gruvbox-material";
    version = "2021-11-11";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "gruvbox-material";
      rev = "a25c5294013d58e4fde6b72d94a5f77e3330f0cc";
      sha256 = "0k4baphl8x6fy8hqidr7g8mw6w1cjhwsgjmsd9v72a9ikl4z22vq";
    };
    meta.homepage = "https://github.com/sainnhe/gruvbox-material/";
  };

  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox.nvim";
    version = "2021-11-12";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "dc7c63320c523997610ced545007935c72d81942";
      sha256 = "16nvlli0vmqxdbcx2d8p2nsl0865444l1d3ji23z9cbz4i171rsw";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  lsp_signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp_signature.nvim";
    version = "2021-11-13";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "600111e6249bcc948e2b811ef09adf4ea84ebfc1";
      sha256 = "0w012936d42m2bs2g8mgg72wkf9mvx4w5m01qdh8daksi1wg86hy";
    };
    meta.homepage = "https://github.com/ray-x/lsp_signature.nvim/";
  };

  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga.nvim";
    version = "2021-04-25";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "lspsaga.nvim";
      rev = "cb0e35d2e594ff7a9c408d2e382945d56336c040";
      sha256 = "0ywhdgh6aqs0xlm8a4d9jhkik254ywagang12r5nyqxawjsmjnib";
    };
    meta.homepage = "https://github.com/glepnir/lspsaga.nvim/";
  };

  lush-nvim = buildVimPluginFrom2Nix {
    pname = "lush.nvim";
    version = "2021-11-06";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "57e9f310b7ddde27664c3e1a5ec3517df235124b";
      sha256 = "0y38id1dj15snx79sazh0kvs2c3jb1h6kyzr90zhm0130m7x6nri";
    };
    meta.homepage = "https://github.com/rktjmp/lush.nvim/";
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
    meta.homepage = "https://github.com/Houl/motpat-vim/";
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
    meta.homepage = "https://github.com/thezoq2/neovim-auto-autoread/";
  };

  neovim-gui-shim = buildVimPluginFrom2Nix {
    pname = "neovim-gui-shim";
    version = "2021-03-27";
    src = fetchFromGitHub {
      owner = "equalsraf";
      repo = "neovim-gui-shim";
      rev = "668188542345e682addfc816af38b7073d376a64";
      sha256 = "1s1ws7cfhg0rjfzf5clr2w6k9b8fkd57jzfna3vx1caymwspwrw2";
    };
    meta.homepage = "https://github.com/equalsraf/neovim-gui-shim/";
  };

  nerdtree = buildVimPluginFrom2Nix {
    pname = "nerdtree";
    version = "2021-10-29";
    src = fetchFromGitHub {
      owner = "preservim";
      repo = "nerdtree";
      rev = "eed488b1cd1867bd25f19f90e10440c5cc7d6424";
      sha256 = "0hlyn2l9ppjn92zaiw51i6d15li15z5083m13m0710giqx05qrak";
    };
    meta.homepage = "https://github.com/preservim/nerdtree/";
  };

  nerdtree-git-plugin = buildVimPluginFrom2Nix {
    pname = "nerdtree-git-plugin";
    version = "2021-08-18";
    src = fetchFromGitHub {
      owner = "Xuyuanp";
      repo = "nerdtree-git-plugin";
      rev = "e1fe727127a813095854a5b063c15e955a77eafb";
      sha256 = "0d7xm5rafw5biv8phfyny2haqq50mnh0q4ms7dkhvp9k1k2k2whz";
    };
    meta.homepage = "https://github.com/Xuyuanp/nerdtree-git-plugin/";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2021-11-15";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "2de40ccf49df737ee33430f5952fd7cf539fec31";
      sha256 = "01j9is0p3q80g2yakqzn40yj512c8aiphhs7ksz6mqb9rhissmxp";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2021-11-15";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "c7cef852a6199cb9a8f77785bf5d3153829aba07";
      sha256 = "1pm0baggpr59yl7mlqc8j5v6c9wmsh3k07j21bfq9i3453pgmpmg";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree.lua";
    version = "2021-10-31";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-tree.lua";
      rev = "5d8453dfbd34ab00cb3e8ce39660f9a54cdd35f3";
      sha256 = "1r2qzajbraqv244kqd006f6rz586rdppi94wssvx8b03v56v8nb7";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-tree.lua/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2021-11-12";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-web-devicons";
      rev = "f936ff3e1f9d58ec0caf0bd398e9675b54fe292e";
      sha256 = "1vzrsr2m75nky1nz5hji7chqcc3d601bkx7raq88pjw4qa3s7b1r";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2021-11-11";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "9335b8b22c0eab8400ae7cd83fe393952e7fc600";
      sha256 = "11hf8bm0093q76jwh4kqqya307nl775rp8f3w8sx723cv4xwwj6y";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
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
    meta.homepage = "https://github.com/python-mode/python-mode/";
  };

  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2021-11-11";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "30dd4ae6f844ab0f53ba93eea61068f87886eb03";
      sha256 = "0hwcar6c6n3fvli9pmx1ycvk4128f47hl07c7y7hxzy2rks7s3j8";
    };
    meta.homepage = "https://github.com/sainnhe/sonokai/";
  };

  vim-conque = buildVimPluginFrom2Nix {
    pname = "vim-conque";
    version = "2021-06-25";
    src = fetchFromGitHub {
      owner = "goballooning";
      repo = "vim-conque";
      rev = "a9a9186899974d8aa13732a544322b55aef00cf1";
      sha256 = "0qmvj8mlyvnmm3fzqk7v8nfs5gil9alnmx2i3c63y0w4gyr5axi0";
    };
    meta.homepage = "https://github.com/goballooning/vim-conque/";
  };

  vim-ctrlspace = buildVimPluginFrom2Nix {
    pname = "vim-ctrlspace";
    version = "2021-09-26";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "7ad53ecd905e22751bf3d31aef2db5f411976679";
      sha256 = "1s36m1qjdf70wiz0rgp8q7h1ldanhwmrx74y0b2yx2a66krkn730";
    };
    meta.homepage = "https://github.com/vim-ctrlspace/vim-ctrlspace/";
  };

  vim-fakeclip = buildVimPluginFrom2Nix {
    pname = "vim-fakeclip";
    version = "2020-05-19";
    src = fetchFromGitHub {
      owner = "kana";
      repo = "vim-fakeclip";
      rev = "59858dabdb55787d7f047c4ab26b45f11ebb533b";
      sha256 = "1jrfi1vc7svhypvg2gizx40vracr91m9d912b61j0c7z8swix908";
    };
    meta.homepage = "https://github.com/kana/vim-fakeclip/";
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
    meta.homepage = "https://github.com/hashivim/vim-hashicorp-tools/";
  };

  vim-monokai-tasty = buildVimPluginFrom2Nix {
    pname = "vim-monokai-tasty";
    version = "2021-11-14";
    src = fetchFromGitHub {
      owner = "patstockwell";
      repo = "vim-monokai-tasty";
      rev = "9fc7b8a09d5a31678843ffb3d999369f5514b0be";
      sha256 = "1g2f0v4qyqwvz0w58i2jclabzcyaxzr5hbzfpblz2gq3a936q97l";
    };
    meta.homepage = "https://github.com/patstockwell/vim-monokai-tasty/";
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
    meta.homepage = "https://github.com/sickill/vim-pasta/";
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
    meta.homepage = "https://github.com/nfvs/vim-perforce/";
  };

  vim-solarized8 = buildVimPluginFrom2Nix {
    pname = "vim-solarized8";
    version = "2021-04-24";
    src = fetchFromGitHub {
      owner = "lifepillar";
      repo = "vim-solarized8";
      rev = "28b81a4263054f9584a98f94cca3e42815d44725";
      sha256 = "0vq0fxsdy0mk2zpbd1drrrxnbd44r39gqzp0s71vh9q4bnww7jds";
    };
    meta.homepage = "https://github.com/lifepillar/vim-solarized8/";
  };

  vim-vsnip = buildVimPluginFrom2Nix {
    pname = "vim-vsnip";
    version = "2021-11-15";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vim-vsnip";
      rev = "60ee20318550f4a5b6f7a5a8b827540c2c386898";
      sha256 = "0gl34m17pxgyfbdqghhfcgxhbhxwvjc9r048sim1gf86wga4mq39";
    };
    meta.homepage = "https://github.com/hrsh7th/vim-vsnip/";
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
    meta.homepage = "https://github.com/vim-scripts/Workspace-Manager/";
  };

}
