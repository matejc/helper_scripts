# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub }:

final: prev:
{
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline.nvim";
    version = "2022-01-02";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "17efb4c834daf4eea96f18753541485ed05baa6e";
      sha256 = "0wm7dl8f5ng9g7xz593dxnadc7wg46ggdrmjy4d9vg8yl62rzsmc";
    };
    meta.homepage = "https://github.com/akinsho/bufferline.nvim/";
  };

  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "f83773e2f433a923997c5faad7ea689ec24d1785";
      sha256 = "0z1c0x60hz3khgpp7nfj0i579sgi4vsnhhcqb02i7a8jx685qwrd";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };

  cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "cmp-cmdline";
    version = "2021-12-01";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "29ca81a6f0f288e6311b3377d9d9684d22eac2ec";
      sha256 = "0yzh0jdys1bn1c2mqm410c0ndyyyxpmigzdrkhnkv78b16vjyhq6";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "b4251f0fca1daeb6db5d60a23ca81507acf858c2";
      sha256 = "0qaz5rb062qyk1zn5ahx6f49yk0r0n0a4mnrlpdcil4kc9j6mfy6";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2021-12-30";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "4d58224e315426e5ac4c5b218ca86cab85f80c79";
      sha256 = "01bn7a04cnljsfls5v9yba6vz4wd2zvbi5jj063gasvqb7yq9kbp";
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

  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox.nvim";
    version = "2021-12-17";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "b0a1c4bd71aa58e02809632fbc00fa6dce6d1213";
      sha256 = "006r99is1x9k4z8y3gycrlczm964gl9gipri2qq7ihjnbsxbkjg3";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  lsp_signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp_signature.nvim";
    version = "2022-01-07";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "49297b6666c88cf6e8aa55a8433a0ab15edf1301";
      sha256 = "1dwnvmiw3zbq3ywpq9fh8c5lizwrq9vjqina22slzyzj7rpacp0k";
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

  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui.nvim";
    version = "2022-01-07";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "4d2036214513b356ccb89058e23e9ef581b66e58";
      sha256 = "0vrzg86q3vkwfyq31wzf0h4dj3972hsd0n69xw1b3ln1fg6idwz3";
    };
    meta.homepage = "https://github.com/MunifTanjim/nui.nvim/";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-01-08";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "9f6d2b42253dda8db950ab38795978e5420a93aa";
      sha256 = "1zqkwxr97hscapcc401k7jazk56yjy03wdy6plwq4p5j9gk0ckcy";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-hlslens = buildVimPluginFrom2Nix {
    pname = "nvim-hlslens";
    version = "2022-01-07";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "d18fbcd9be71ff85e0d6f5beadbeda5339774269";
      sha256 = "1l2s8k3b24a2niamfib4fzs50zl8jf7snw2v2bc8n8kxcw18x4xg";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-01-06";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "c7081e00fa8100ee099c16e375f3e5e838cbf1db";
      sha256 = "00wm3hyrwy7x33g5sv9k1vl3hfs4jn5mglbn9y593y1f8w9a2q45";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-scrollbar = buildVimPluginFrom2Nix {
    pname = "nvim-scrollbar";
    version = "2022-01-07";
    src = fetchFromGitHub {
      owner = "petertriho";
      repo = "nvim-scrollbar";
      rev = "bbe23a2ef14df13538ab54c741dc07557fa86782";
      sha256 = "0h66480a1cqrfb5735s84akc381mr35ngjvkhz3bgn2j38v2l1bx";
    };
    meta.homepage = "https://github.com/petertriho/nvim-scrollbar/";
  };

  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree.lua";
    version = "2021-12-24";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-tree.lua";
      rev = "0a2f6b0b6ba558a88c77a6b262af647760e6eca8";
      sha256 = "0svxndakxlin4jgmzmx7xj9ysbiy94hfszq89bv2qcxlkfxa78l0";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-tree.lua/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2021-12-20";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-web-devicons";
      rev = "ac71ca88b1136e1ecb2aefef4948130f31aa40d1";
      sha256 = "1fgl4cyichzlrl6dc2mp362kncc4aiy10svzzcqad168aj2x8rhd";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2021-12-28";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "d3e830aaf89e4f0fe3ee9dfba2c5bf6596d4ac22";
      sha256 = "1cgdgbdg75ksk2igy82kq43pbg9b23ir1dji5c714l2r10q1b67j";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
  };

  searchbox-nvim = buildVimPluginFrom2Nix {
    pname = "searchbox.nvim";
    version = "2022-01-02";
    src = fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "searchbox.nvim";
      rev = "2169e725b9c9d2d4fb0a8959654115ab6d89cbf9";
      sha256 = "0rbf41nm3xbawrkj2zkmpdmqd5irz89kfw0fa56imrj3csndmgyx";
    };
    meta.homepage = "https://github.com/VonHeikemen/searchbox.nvim/";
  };

  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2022-01-05";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "7560b4d00978a2c1bbca20636c3385e2623533f0";
      sha256 = "0ppcbcycv4pinr9v1r49vxlpxlkjlnpy04qj7vca5y5z8zzhzixz";
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
    version = "2022-01-06";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vim-vsnip";
      rev = "7fde9c0b6878a62bcc6d2d29f9a85a6616032f02";
      sha256 = "1f0p9pk2a2fxcdf4p35vm0jyrxkkxkqgn1v8fyd622vmcrbrj860";
    };
    meta.homepage = "https://github.com/hrsh7th/vim-vsnip/";
  };

}
