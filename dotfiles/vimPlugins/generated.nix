# This file has been generated by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline.nvim";
    version = "2022-03-29";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "af158e4477a08be3645faf91cfb772f898c132f0";
      sha256 = "17ln4h4n2sfn8ysjl7acsfnrs2hsvhlvff5v448xa0dlz00xpkgm";
    };
    meta.homepage = "https://github.com/akinsho/bufferline.nvim/";
  };

  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2022-02-21";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "d66c4c2d376e5be99db68d2362cd94d250987525";
      sha256 = "0n9mqrf4rzj784zhshxr2wqyhm99d9mzalxqnik7srkghjvc9l4a";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };

  cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "cmp-cmdline";
    version = "2022-02-13";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "f4beb74e8e036f9532bedbcac0b93c7a55a0f8b0";
      sha256 = "0spc5vhrcz2ld1cxf9n27mhhfdwm0v89xbbyzbi9hshzfssndagh";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-01-15";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "ebdfc204afb87f15ce3d3d3f5df0b8181443b5ba";
      sha256 = "0kmaxxdxlp1s5w36khnw0sdrbv1lr3p5n9r90h6h7wv842n4mnca";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2022-02-02";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "466b6b8270f7ba89abd59f402c73f63c7331ff6e";
      sha256 = "15ksxnwxssv1yr1ss66mbl5w0layq0f4baisd9ki192alnkd7365";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-spell = buildVimPluginFrom2Nix {
    pname = "cmp-spell";
    version = "2021-10-19";
    src = fetchFromGitHub {
      owner = "f3fora";
      repo = "cmp-spell";
      rev = "5602f1a0de7831f8dad5b0c6db45328fbd539971";
      sha256 = "1pk6izww8canfqpiyrqd6qx1p3j18pwfzkfx4ynbng8kl9nh6nv5";
    };
    meta.homepage = "https://github.com/f3fora/cmp-spell/";
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
    version = "2022-01-21";
    src = fetchFromGitHub {
      owner = "NTBBloodbath";
      repo = "galaxyline.nvim";
      rev = "4d4f5fc8e20a10824117e5beea7ec6e445466a8f";
      sha256 = "0xgk64d7dyihrjir8mxchwzi65nimm9w23r24m99w6p0f9qr56gk";
    };
    meta.homepage = "https://github.com/NTBBloodbath/galaxyline.nvim/";
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

  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns.nvim";
    version = "2022-03-29";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "709455d2df50243f1d404f78c82d579caa778bfb";
      sha256 = "09vgkn8g65mwkigk0krflw4vd9vayj27ibic24a69fahd24854v0";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox.nvim";
    version = "2022-02-12";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "dc6bae93ded04ac542d429ff5cc87189dde44294";
      sha256 = "06mvdxi1pf9mw0zrk0cib3bi9p82ymdc3acm4r2rr4rqww8mrq4x";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  lsp_signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp_signature.nvim";
    version = "2022-03-05";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "e4f7dad45a1a3bb390977b4e69a528993bcefeac";
      sha256 = "0smxcvgyc575kmz9aw20k47awh5j11ywnc1lpq1hdgkppxm7lnm2";
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
    version = "2022-03-24";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "fa7694fe221ca595d6f8c4f1aab531b4c1d48d7b";
      sha256 = "14cs574nk0hr6mbf80gcjdarwbngbgj73s1grn6yczr2gqqqmhwk";
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

  neo-tree-nvim = buildVimPluginFrom2Nix {
    pname = "neo-tree.nvim";
    version = "2022-03-27";
    src = fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "b500daadd5ff0cce16c2a8e827b6d08a8b16357d";
      sha256 = "1dlk3pgdhqhiyfdq5g0ql5iw1hhqvfnyfbdxpr9hzg4zimm2id8s";
    };
    meta.homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim/";
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

  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui.nvim";
    version = "2022-03-08";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "513ff9bbdde7da53e209232d4328e734ea2bd96a";
      sha256 = "08r2ifkj9zj8c771ahl2i0b8crp3cw2cdshkpq26ci14ypdq0304";
    };
    meta.homepage = "https://github.com/MunifTanjim/nui.nvim/";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-03-28";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "dd6e4d96f9e376c87302fa5414556aa6269bf997";
      sha256 = "098wzfnvpkb29i99mqwm61s8iqk6zj5211ms7mhbf5rx7c227ygd";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-hlslens = buildVimPluginFrom2Nix {
    pname = "nvim-hlslens";
    version = "2022-03-28";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "a89f177a3b2d69e5c06e67711e8f459b2e8f49ea";
      sha256 = "1cg5jp4sgaxx0ydjrphb0ajb288s895x50lag50wfgp5xcj29c72";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-03-28";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "3d1baa811b351078e5711be1a1158e33b074be9e";
      sha256 = "0470h3vaw6zmmayfd9rzlh5myzmdc2wa5qlfmax21k0jna62zzr1";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-regexplainer = buildVimPluginFrom2Nix {
    pname = "nvim-regexplainer";
    version = "2022-03-27";
    src = fetchFromGitHub {
      owner = "bennypowers";
      repo = "nvim-regexplainer";
      rev = "b1ddb572246919034c7af32b172218a4241ec401";
      sha256 = "1fvgzj91gi589fg8radld8jwybalkmip88kivafdf6pgxh000vwr";
    };
    meta.homepage = "https://github.com/bennypowers/nvim-regexplainer/";
  };

  nvim-scrollbar = buildVimPluginFrom2Nix {
    pname = "nvim-scrollbar";
    version = "2022-02-26";
    src = fetchFromGitHub {
      owner = "petertriho";
      repo = "nvim-scrollbar";
      rev = "b10ece8f991e2c096bc2a6a92da2a635f9298d26";
      sha256 = "027v0hyv5bbrig4dlnc16fnrbclnzvijdbvg6dxnd2qqb36i736h";
    };
    meta.homepage = "https://github.com/petertriho/nvim-scrollbar/";
  };

  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree.lua";
    version = "2022-03-28";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-tree.lua";
      rev = "5eef6185b130fcc7b76c4420824c596e4e1fbdef";
      sha256 = "174sk1r1ayx1z28p9bjsbk0br7b5hj5yxkgpr906jyk32vwcgh6s";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-tree.lua/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2022-03-22";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-web-devicons";
      rev = "09e62319974d7d7ec7e53b974724f7942470ef78";
      sha256 = "0f64alh5mf6zjnbxqsx21m3dcldqshx7a7z46qg0pfbnn9fx7swq";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2022-03-13";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "dde6493ee4ffe6a8b70deb628c4a08431d77ecd9";
      sha256 = "144lw2iih1ymqla11xmz0zyakd3l4pjq70wfz5i8zh9ac3jps88i";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary.nvim";
    version = "2022-03-20";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "0d660152000a40d52158c155625865da2aa7aa1b";
      sha256 = "0r8amnlaqxg9jpqk6v4rzlfrc8q161jy1bpy35jrk7gva76kp9hm";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
  };

  searchbox-nvim = buildVimPluginFrom2Nix {
    pname = "searchbox.nvim";
    version = "2022-02-10";
    src = fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "searchbox.nvim";
      rev = "bbb1c08a36d19517633430079ab0c61293e18b91";
      sha256 = "1lq1c6y25m5f1vyjrkr3iawxpjiwx0sxlp2zgcr4nk9ic63jl5xz";
    };
    meta.homepage = "https://github.com/VonHeikemen/searchbox.nvim/";
  };

  smart-splits-nvim = buildVimPluginFrom2Nix {
    pname = "smart-splits.nvim";
    version = "2022-03-29";
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "ae4b8ce9db62a02dc554b23799acabd544a15923";
      sha256 = "16d5bkip4hlp9wv64sgyh8410q94pls21v6x3l58dqq13q0xmhvq";
    };
    meta.homepage = "https://github.com/mrjones2014/smart-splits.nvim/";
  };

  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2022-03-21";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "774ccdb95a04539530be34fa17a34c0f64139aca";
      sha256 = "1myz05j6i7h0yyffbip6a2gpfb61y35w48aa1wlh8i3m9bhy7g4a";
    };
    meta.homepage = "https://github.com/sainnhe/sonokai/";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope.nvim";
    version = "2022-03-26";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "cf2d6d34282afd90f0f5d2aba265a23b068494c2";
      sha256 = "042w0l8hdcxaj3pmbp0w1mqmivfm48pv3vlcz6d423qiljbkrk9k";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";
  };

  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer.lua";
    version = "2022-03-12";
    src = fetchFromGitHub {
      owner = "themercorp";
      repo = "themer.lua";
      rev = "9b6c4080f6725b946b62c7f561ad2e10e63a694a";
      sha256 = "0sfpvv8dx5rl02fixwdkr4wdfc27ksws0pwwz86hn0r8gjs1yb8q";
    };
    meta.homepage = "https://github.com/themercorp/themer.lua/";
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
    version = "2022-03-29";
    src = fetchFromGitHub {
      owner = "lifepillar";
      repo = "vim-solarized8";
      rev = "ed0b0e1bed9bd9bcd715791bb410756588aeb132";
      sha256 = "1nkkjg8x11ig96q8qysgfdcfbfx8xc2f2narfh16zn2yhxc602v7";
    };
    meta.homepage = "https://github.com/lifepillar/vim-solarized8/";
  };

  vim-vsnip = buildVimPluginFrom2Nix {
    pname = "vim-vsnip";
    version = "2022-02-26";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vim-vsnip";
      rev = "70a1131d64d75150ece513b983b0f42939bcb03c";
      sha256 = "042cnznm1p5x3ky7m81q62n3nlgab9fq734hlfwsbwrcdqa849l2";
    };
    meta.homepage = "https://github.com/hrsh7th/vim-vsnip/";
  };

}
