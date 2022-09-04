# This file has been generated by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  alpha-nvim = buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "2022-08-29";
    src = fetchFromGitHub {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "09e5374465810d71c33e9b097214adcdebeee49a";
      sha256 = "16a55mjc78yiv9a66cckxhdqbabk4k4sim3rcyvs2h7m54rwgj31";
    };
    meta.homepage = "https://github.com/goolord/alpha-nvim/";
  };

  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline.nvim";
    version = "2022-09-01";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "938908fc8db120d907bda23f6744202f534f63e4";
      sha256 = "1wvd7k7xn3lb7fzqhag0mgyjjg50v31qfcdlmbn54dwbf684ra98";
    };
    meta.homepage = "https://github.com/akinsho/bufferline.nvim/";
  };

  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2022-08-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "3022dbc9166796b644a841a02de8dd1cc1d311fa";
      sha256 = "1cwx8ky74633y0bmqmvq1lqzmphadnhzmhzkddl3hpb7rgn18vkl";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };

  cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "cmp-cmdline";
    version = "2022-08-05";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "9c0e331fe78cab7ede1c051c065ee2fc3cf9432e";
      sha256 = "0aadafmcbf23pw6swwfmbj4hcp4gawshz2ddhzagxflw398c0n9x";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-05-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "affe808a5c56b71630f17aa7c38e15c59fd648a8";
      sha256 = "1v88bw8ri8w4s8yn7jw5anyiwyw8swwzrjf843zqzai18kh9mlnp";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-nvim-lsp-signature-help = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp-signature-help";
    version = "2022-08-20";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "3dd40097196bdffe5f868d5dddcc0aa146ae41eb";
      sha256 = "0kfa0pw5yx961inirqwi0fjvgdbmsgw16703mw2w9km8313x17zw";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/";
  };

  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2022-07-26";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "447c87cdd6e6d6a1d2488b1d43108bfa217f56e1";
      sha256 = "0nmxwfn0gp70z26w9x03dk2myx9bbjxqw7zywzvdm28lgr43dwhv";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-rg = buildVimPluginFrom2Nix {
    pname = "cmp-rg";
    version = "2022-07-27";
    src = fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "cmp-rg";
      rev = "7cf6ddc0046591b8a95c737826edf683489c3a66";
      sha256 = "1xi3vygr5czjx904314ny2pgyxz9s8s7m27cl74ii05np7i27nnz";
    };
    meta.homepage = "https://github.com/lukas-reineke/cmp-rg/";
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

  cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "cmp-treesitter";
    version = "2022-06-09";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "c2886bbb09ef6daf996a258db29546cc1e7c12a7";
      sha256 = "1ar6d6pqybn4vqynbh18mc7fy1ybv0s9mi1r2j1nfcmgvh4wsvwk";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter/";
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

  friendly-snippets = buildVimPluginFrom2Nix {
    pname = "friendly-snippets";
    version = "2022-08-29";
    src = fetchFromGitHub {
      owner = "rafamadriz";
      repo = "friendly-snippets";
      rev = "e5a16f9346e1fa24147d6d23460ca9b41528ab7e";
      sha256 = "13syv5p0fhyyhv3djfn9zxlnqmw8h38caml0lxb1y3205xw4awwp";
    };
    meta.homepage = "https://github.com/rafamadriz/friendly-snippets/";
  };

  galaxyline-nvim = buildVimPluginFrom2Nix {
    pname = "galaxyline.nvim";
    version = "2022-06-05";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "galaxyline.nvim";
      rev = "eb81be07bf690c5ef7474ace72920b32ad089585";
      sha256 = "1i4khr7nigmnxxsbrnas3aw3fw56p5pgnfchg36q2yzv5mr0mpzg";
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

  gitsigns-nvim = buildNeovimPluginFrom2Nix {
    pname = "gitsigns.nvim";
    version = "2022-09-01";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "d7e0bcbe45bd9d5d106a7b2e11dc15917d272c7a";
      sha256 = "1h4gxyamynwygxpqfib2a7sd1xbi6sh8ixg85j6qiaqqpahr0a4k";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox.nvim";
    version = "2022-08-29";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "c7aaa3ec3f431d90b0b9382cb52bebffc0e4283a";
      sha256 = "1srz8gxghahsjqngwicgg4si3lc1c2707imi2pfk4a76j39s56fw";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  image-nvim = buildVimPluginFrom2Nix {
    pname = "image.nvim";
    version = "2022-08-20";
    src = fetchFromGitHub {
      owner = "samodostal";
      repo = "image.nvim";
      rev = "b0c6c37a5add9982ca61ba828e92105fd997f9d3";
      sha256 = "168rfllr6ayd2j067l9h29z0yn3zikqpqy4f36nr31g1407374b0";
    };
    meta.homepage = "https://github.com/samodostal/image.nvim/";
  };

  lsp_signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp_signature.nvim";
    version = "2022-08-15";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "e65a63858771db3f086c8d904ff5f80705fd962b";
      sha256 = "17qxn2ldvh1gas3i55vigqsz4mm7sxfl721v7lix9xs9bqgm73n1";
    };
    meta.homepage = "https://github.com/ray-x/lsp_signature.nvim/";
  };

  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga.nvim";
    version = "2022-09-04";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "lspsaga.nvim";
      rev = "551811a33f26040ae217d27f212a9b88165e4633";
      sha256 = "0v9g61gzzx0swb4davphflcr0b4cf6h1smg92941dda3ggk8bx6b";
    };
    meta.homepage = "https://github.com/glepnir/lspsaga.nvim/";
  };

  lush-nvim = buildVimPluginFrom2Nix {
    pname = "lush.nvim";
    version = "2022-08-09";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "6b9f399245de7bea8dac2c3bf91096ffdedfcbb7";
      sha256 = "0rb77rwmbm438bmbjfk5hwrrcn5sihsa1413bdpc27rw3rrn8v8z";
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
    version = "2022-08-19";
    src = fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "a7d6f05e57487326fd70b24195c3b7a86a88b156";
      sha256 = "02v0jski9h89q310ja2f54jgssa4pd79fsg22ngkgd4s3hf5g9n8";
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

  neovim-session-manager = buildVimPluginFrom2Nix {
    pname = "neovim-session-manager";
    version = "2022-08-06";
    src = fetchFromGitHub {
      owner = "Shatur";
      repo = "neovim-session-manager";
      rev = "6604857365b13bfbcaa7ef377d4e60d2acb0be02";
      sha256 = "14gcgayy1cvfk19ay56pqy0cvqd16khyx2xhdc0a3aqxkskmwhnr";
    };
    meta.homepage = "https://github.com/Shatur/neovim-session-manager/";
  };

  novim-mode = buildVimPluginFrom2Nix {
    pname = "novim-mode";
    version = "2022-05-23";
    src = fetchFromGitHub {
      owner = "tombh";
      repo = "novim-mode";
      rev = "0e8e37a6c7b6f0ff2bbb27593d0b7c83c8ab91b9";
      sha256 = "1hnc0ryhxr5bqv9h30nbpryzgnabhwnnc8gich3426n1qir6j3x8";
    };
    meta.homepage = "https://github.com/tombh/novim-mode/";
  };

  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui.nvim";
    version = "2022-08-25";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "62facd37e0dd8196212399a897374f689886f500";
      sha256 = "19krk2n4ndrmx1kp99zdm6hh3pbhbdz8yhf2lsm83h0267f5k993";
    };
    meta.homepage = "https://github.com/MunifTanjim/nui.nvim/";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-09-02";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "33fbb2c3d2c512bd79ea03cf11fea405cbe618a9";
      sha256 = "1bjrmgppafs9bps33vapb3vbgg3mg8azk4lfp40q5wcxg5s9xsvl";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-colorizer-lua = buildVimPluginFrom2Nix {
    pname = "nvim-colorizer.lua";
    version = "2022-09-03";
    src = fetchFromGitHub {
      owner = "NvChad";
      repo = "nvim-colorizer.lua";
      rev = "84aa4ad6a09d74fbafea842115b368aa314dfe0e";
      sha256 = "14bmbphr4ahm29qjbbawgrdkckm9l031ia4c5l8z7hh63dz43pzn";
    };
    meta.homepage = "https://github.com/NvChad/nvim-colorizer.lua/";
  };

  nvim-hlslens = buildVimPluginFrom2Nix {
    pname = "nvim-hlslens";
    version = "2022-07-07";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "75b20ce89908bc56eeab5c7b4d0a77e9e054d2e4";
      sha256 = "0hyz660mlffgwgmnrxp5h11b121dxszjmsaagnxp5qibnn1gjpll";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-09-02";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "0fafc3ef648bd612757630097c96b725a36a0476";
      sha256 = "1ivgc2awb6j9y3rb5zv5ar0s7m0qdq15xalgmcf7d159jphdnql9";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-scrollbar = buildVimPluginFrom2Nix {
    pname = "nvim-scrollbar";
    version = "2022-07-11";
    src = fetchFromGitHub {
      owner = "petertriho";
      repo = "nvim-scrollbar";
      rev = "ce0df6954a69d61315452f23f427566dc1e937ae";
      sha256 = "1x6qwssz38822b4kkiyak1zwlm9551006sz8vv6zm2fxzd3yi88j";
    };
    meta.homepage = "https://github.com/petertriho/nvim-scrollbar/";
  };

  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree.lua";
    version = "2022-09-04";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-tree.lua";
      rev = "951e10a64e0b03069f0f50ddc79d6a8ed8d23dec";
      sha256 = "192bsw0q8z7zwynwjq1163hrd4cfzy3fnq98nk22z80f5z4f3kf4";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-tree.lua/";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-09-04";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "1506334ebeeae860f4304541bfc2dc20e7b6613a";
      sha256 = "1s2wiq8l56wyk8qvsrwbyn58f8sf0fpbp5sbs8synmxwh3jvw8zq";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2022-07-05";
    src = fetchFromGitHub {
      owner = "kyazdani42";
      repo = "nvim-web-devicons";
      rev = "2d02a56189e2bde11edd4712fea16f08a6656944";
      sha256 = "0f7r7xza28aaf60nbzaw9fcsjjff5c67jmgbci0jz21v2ib89pps";
    };
    meta.homepage = "https://github.com/kyazdani42/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2022-07-13";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "7e88f137ad7b74b0beb7034e592bcd07922be5e8";
      sha256 = "10d21a9svv7kspzpw7gna82dwgmmd5jkz1hxf6rny1j098ggll1k";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
  };

  plantuml-previewer-vim = buildVimPluginFrom2Nix {
    pname = "plantuml-previewer.vim";
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "weirongxu";
      repo = "plantuml-previewer.vim";
      rev = "887d55f912be965e9a24aa61d744fc8b9ed0d7d1";
      sha256 = "1asi0kjl09k903a6xka653l4jzvq45gjh77kdya7my1nhfwgim59";
    };
    meta.homepage = "https://github.com/weirongxu/plantuml-previewer.vim/";
  };

  plenary-nvim = buildNeovimPluginFrom2Nix {
    pname = "plenary.nvim";
    version = "2022-09-03";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "4b66054e75356ac0b909bbfee9c682e703f535c2";
      sha256 = "1yl5m7is35bk30swr5m1pcl2i0wf8gjcnas6bpahlxqa4x0yr1x8";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
  };

  previm = buildVimPluginFrom2Nix {
    pname = "previm";
    version = "2022-08-31";
    src = fetchFromGitHub {
      owner = "previm";
      repo = "previm";
      rev = "3f96f82af0ab3998c39a64e51c2e8fe50ed2ecd1";
      sha256 = "1zpa7mv0lfs4d6p41ds5ybzwfa6fws4zqj8idhvg3qbw2m5qjrf9";
    };
    meta.homepage = "https://github.com/previm/previm/";
  };

  searchbox-nvim = buildVimPluginFrom2Nix {
    pname = "searchbox.nvim";
    version = "2022-08-06";
    src = fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "searchbox.nvim";
      rev = "642437be29a5976a747904a124c79e55714b46e3";
      sha256 = "1z2s598nrgn7xin1rsgz9z6fhxj5vi5fd335anvkc8v40r2dqmr6";
    };
    meta.homepage = "https://github.com/VonHeikemen/searchbox.nvim/";
  };

  smart-splits-nvim = buildVimPluginFrom2Nix {
    pname = "smart-splits.nvim";
    version = "2022-08-07";
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "c8d80d90f3c783ac0ea21f256c74d541a7b66a72";
      sha256 = "0vchzaflnrbxnmq2j2zfms8a6xadj75sq0jpxvgmngry5fyb6r1z";
    };
    meta.homepage = "https://github.com/mrjones2014/smart-splits.nvim/";
  };

  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2022-08-28";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "17b5a8e085c13b650dc34c3b81b27374b5ea1439";
      sha256 = "0ssmn8lr4mgi8wcckaym3qnjg3m3l67a5avbsc3yj6igavv7c7mb";
    };
    meta.homepage = "https://github.com/sainnhe/sonokai/";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope.nvim";
    version = "2022-09-03";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "49b043e2a3e63cdd50bcde752e3b32dae22d8a3a";
      sha256 = "0bxkyqlkha0h2l6gmm9svmqblpwji7nl98x7h2z6yl1cgnl66vnv";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";
  };

  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer.lua";
    version = "2022-09-04";
    src = fetchFromGitHub {
      owner = "themercorp";
      repo = "themer.lua";
      rev = "38f11ad63a03cfbabb035d899443a1591a3b0fec";
      sha256 = "14lcyy7zbzwqq048vcib03rgxasqqdamkb12xz9lx9gbq7j7rgvf";
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
    version = "2022-04-13";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "05b58e916cea62577462d36bbb88933e8454f2d3";
      sha256 = "1v5prf16ria8gvsil2hrmq6ra1jda9m57s4x82ispmllv56902y1";
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
    version = "2022-05-03";
    src = fetchFromGitHub {
      owner = "lifepillar";
      repo = "vim-solarized8";
      rev = "9f9b7951975012ce51766356c7c28ba56294f9e8";
      sha256 = "1qg9n6c70jyyh38fjs41j9vcj54qmhkkyzna0la7bwsycqfxbs2x";
    };
    meta.homepage = "https://github.com/lifepillar/vim-solarized8/";
  };

  vim-vsnip = buildVimPluginFrom2Nix {
    pname = "vim-vsnip";
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vim-vsnip";
      rev = "8f199ef690ed26dcbb8973d9a6760d1332449ac9";
      sha256 = "1d9wr97a02j717sbh55xk7xam6d97l5ggi0ymc67q64hrq8nsaai";
    };
    meta.homepage = "https://github.com/hrsh7th/vim-vsnip/";
  };

  nvim-surround = buildVimPluginFrom2Nix {
    pname = "nvim-surround";
    version = "2022-08-29";
    src = fetchFromGitHub {
      owner = "kylechui";
      repo = "nvim-surround";
      rev = "01e17311bddffd65cc191bbefb845dba46780859";
      sha256 = "0hhfmxmcqi0bmrv19jr9qs8751gwg6bpxljjyyasbgd37hp3vgqb";
    };
    meta.homepage = "https://github.com/kylechui/nvim-surround/";
  };


}
