# GENERATED by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPlugin, buildNeovimPlugin, fetchFromGitHub, fetchgit }:

final: prev:
{
  ChatGPT-nvim = buildVimPlugin {
    pname = "ChatGPT.nvim";
    version = "2023-11-14";
    src = fetchFromGitHub {
      owner = "jackMort";
      repo = "ChatGPT.nvim";
      rev = "b50fdaf7836c18e0de2f1def0c1f39d56ef8bced";
      sha256 = "1xmnzr1hccgdaadjc8i207bz44272ng5aaaypdacaag2pciapq3s";
    };
    meta.homepage = "https://github.com/jackMort/ChatGPT.nvim/";
  };

  LuaSnip = buildVimPlugin {
    pname = "LuaSnip";
    version = "2023-12-05";
    src = fetchFromGitHub {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "954c81b53989097faaff0fabc11c29575288c3e1";
      sha256 = "1a7yz1clg750fbhkv81c5igqd90b9sa9y8c6dy6prcmkyyn1756a";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/L3MON4D3/LuaSnip/";
  };

  alpha-nvim = buildVimPlugin {
    pname = "alpha-nvim";
    version = "2023-11-28";
    src = fetchFromGitHub {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "29074eeb869a6cbac9ce1fbbd04f5f5940311b32";
      sha256 = "13my49r11s0mm7q7cri7c0ymmasippp9wcfplsg1pmg73j9a6i27";
    };
    meta.homepage = "https://github.com/goolord/alpha-nvim/";
  };

  bufferline-nvim = buildVimPlugin {
    pname = "bufferline.nvim";
    version = "2023-12-08";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "ac788fbc493839c1e76daa8d119934b715fdb90e";
      sha256 = "0zy8z80s32hqa6jsffh9wygb77dnp7zhsp2zqgbl63lpyy0ffrvc";
    };
    meta.homepage = "https://github.com/akinsho/bufferline.nvim/";
  };

  cmp-buffer = buildVimPlugin {
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

  cmp-cmdline = buildVimPlugin {
    pname = "cmp-cmdline";
    version = "2023-06-08";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "8ee981b4a91f536f52add291594e89fb6645e451";
      sha256 = "03j79ncxnnpilx17x70my7s8vvc4w81kipraq29g4vp32dggzjsv";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPlugin {
    pname = "cmp-nvim-lsp";
    version = "2023-12-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "5af77f54de1b16c34b23cba810150689a3a90312";
      sha256 = "03q0v6wgi1lphcfjjdsc26zhnmj3ab9xxsiyp1adl3s1ybv22jzz";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-nvim-lsp-signature-help = buildVimPlugin {
    pname = "cmp-nvim-lsp-signature-help";
    version = "2023-02-03";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "3d8912ebeb56e5ae08ef0906e3a54de1c66b92f1";
      sha256 = "0bkviamzpkw6yv4cyqa9pqm1g2gsvzk87v8xc4574yf86jz5hg68";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/";
  };

  cmp-path = buildVimPlugin {
    pname = "cmp-path";
    version = "2022-10-03";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "91ff86cd9c29299a64f968ebb45846c485725f23";
      sha256 = "18ixx14ibc7qrv32nj0ylxrx8w4ggg49l5vhcqd35hkp4n56j6mn";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-rg = buildVimPlugin {
    pname = "cmp-rg";
    version = "2023-09-01";
    src = fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "cmp-rg";
      rev = "677a7874ee8f1afc648c2e7d63a97bc21a7663c5";
      sha256 = "0cahyz5i6iyjqb4cklrkimw5pjajfnlazpmky617ysl3m1b6pwk3";
    };
    meta.homepage = "https://github.com/lukas-reineke/cmp-rg/";
  };

  cmp-spell = buildVimPlugin {
    pname = "cmp-spell";
    version = "2023-09-20";
    src = fetchFromGitHub {
      owner = "f3fora";
      repo = "cmp-spell";
      rev = "32a0867efa59b43edbb2db67b0871cfad90c9b66";
      sha256 = "1yr2cq1b6di4k93pjlshkkf4phhd3lzmkm0s679j35crzgwhxnbd";
    };
    meta.homepage = "https://github.com/f3fora/cmp-spell/";
  };

  cmp-treesitter = buildVimPlugin {
    pname = "cmp-treesitter";
    version = "2023-12-09";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "13e4ef8f4dd5639fca2eb9150e68f47639a9b37d";
      sha256 = "10375kviak1wxklha79g8gbk8pph8finsb3wga6p7mw1m657vc9b";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter/";
  };

  cmp-vsnip = buildVimPlugin {
    pname = "cmp-vsnip";
    version = "2022-11-22";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-vsnip";
      rev = "989a8a73c44e926199bfd05fa7a516d51f2d2752";
      sha256 = "1hs1gv7q0vfn82pwdwpy46nsi4n5z6yljnzl0rpvwfp8g79hssfs";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-vsnip/";
  };

  cmp_luasnip = buildVimPlugin {
    pname = "cmp_luasnip";
    version = "2023-10-09";
    src = fetchFromGitHub {
      owner = "saadparwaiz1";
      repo = "cmp_luasnip";
      rev = "05a9ab28b53f71d1aece421ef32fee2cb857a843";
      sha256 = "0gw3jz65dnxkc618j26zj37gs1yycf7wql9yqc9glazjdjbljhlx";
    };
    meta.homepage = "https://github.com/saadparwaiz1/cmp_luasnip/";
  };

  filetype-nvim = buildVimPlugin {
    pname = "filetype.nvim";
    version = "2022-06-02";
    src = fetchFromGitHub {
      owner = "nathom";
      repo = "filetype.nvim";
      rev = "b522628a45a17d58fc0073ffd64f9dc9530a8027";
      sha256 = "0l2cg7r78qbsbc6n5cvwl5m5lrzyfvazs5z3gf54hspw120nzr87";
    };
    meta.homepage = "https://github.com/nathom/filetype.nvim/";
  };

  friendly-snippets = buildVimPlugin {
    pname = "friendly-snippets";
    version = "2023-11-27";
    src = fetchFromGitHub {
      owner = "rafamadriz";
      repo = "friendly-snippets";
      rev = "53d3df271d031c405255e99410628c26a8f0d2b0";
      sha256 = "07zggsby7v2migmc314nd1dsga9ixwp89ibwlsl3lrm2dwqlkbg9";
    };
    meta.homepage = "https://github.com/rafamadriz/friendly-snippets/";
  };

  galaxyline-nvim = buildVimPlugin {
    pname = "galaxyline.nvim";
    version = "2023-01-08";
    src = fetchFromGitHub {
      owner = "nvimdev";
      repo = "galaxyline.nvim";
      rev = "20f5f750002532a35193f55cd499074fc97d933d";
      sha256 = "06f7q8c3izvzv5alsxdpx6afrn7bq8g3d4z4am3c3zrsbggfa02a";
    };
    meta.homepage = "https://github.com/nvimdev/galaxyline.nvim/";
  };

  git-blame-vim = buildVimPlugin {
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

  gitsigns-nvim = buildNeovimPlugin {
    pname = "gitsigns.nvim";
    version = "2023-12-10";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "6e05045fb1a4845fe44f5c54aafe024444c422ba";
      sha256 = "0wj7cbh9rf77zzzylnx6fahvs7ygnjmqpkm95vaixbg5v5f0hdwj";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  gruvbox-nvim = buildVimPlugin {
    pname = "gruvbox.nvim";
    version = "2023-11-29";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "0940564208a490c173216c3b7d2188b0a5ad3491";
      sha256 = "15vlr7wh9grfn2s4vhmi5a2pap00366irvyglc1g0wvj3w7n520z";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  image-nvim = buildVimPlugin {
    pname = "image.nvim";
    version = "2023-06-08";
    src = fetchFromGitHub {
      owner = "samodostal";
      repo = "image.nvim";
      rev = "dcabdf47b0b974b61d08eeafa2c519927e37cf27";
      sha256 = "1c0s460nzw1imvvzj6b9hsalv60jmcyrfga5gldbskz58hyj739m";
    };
    meta.homepage = "https://github.com/samodostal/image.nvim/";
  };

  lsp_signature-nvim = buildVimPlugin {
    pname = "lsp_signature.nvim";
    version = "2023-11-28";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "fed2c8389c148ff1dfdcdca63c2b48d08a50dea0";
      sha256 = "18cwrdww4yxl597d95yixhwxlavmkl37nslpida9cincxrz16rz0";
    };
    meta.homepage = "https://github.com/ray-x/lsp_signature.nvim/";
  };

  lspkind-nvim = buildVimPlugin {
    pname = "lspkind.nvim";
    version = "2023-05-05";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind.nvim";
      rev = "57610d5ab560c073c465d6faf0c19f200cb67e6e";
      sha256 = "18lpp3ng52ylp8s79qc84b4dhmy7ymgis7rjp88zghv1kndrksjb";
    };
    meta.homepage = "https://github.com/onsails/lspkind.nvim/";
  };

  lspsaga-nvim = buildVimPlugin {
    pname = "lspsaga.nvim";
    version = "2023-12-11";
    src = fetchFromGitHub {
      owner = "nvimdev";
      repo = "lspsaga.nvim";
      rev = "335805d4f591f5bb71cabb6aa4dc58ccef8e8617";
      sha256 = "0b4z2br4w8gh7yxgdnr6700pp7wm479d83bgglgbfvz7v97xjj25";
    };
    meta.homepage = "https://github.com/nvimdev/lspsaga.nvim/";
  };

  lush-nvim = buildNeovimPlugin {
    pname = "lush.nvim";
    version = "2023-12-05";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "f76741886b356586f9dfe8e312fbd1ab0fd1084f";
      sha256 = "1jvfycqg5s72gmib8038kzyy8fyanl06mkz74rjy878zv8r6nf59";
    };
    meta.homepage = "https://github.com/rktjmp/lush.nvim/";
  };

  motpat-vim = buildVimPlugin {
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

  neo-tree-nvim = buildVimPlugin {
    pname = "neo-tree.nvim";
    version = "2023-11-18";
    src = fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "230ff118613fa07138ba579b89d13ec2201530b9";
      sha256 = "13ma0zh6jbh8dbinczbanwf1jy20sac9qxx7v9h174gbyzpc079m";
    };
    meta.homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim/";
  };

  neovim-auto-autoread = buildVimPlugin {
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

  neovim-gui-shim = buildVimPlugin {
    pname = "neovim-gui-shim";
    version = "2023-08-08";
    src = fetchFromGitHub {
      owner = "equalsraf";
      repo = "neovim-gui-shim";
      rev = "2e561a0931e08e4620c3a968e27d3745e9eaf2fd";
      sha256 = "1aa23n0nw3fjhgwylw31vb2gg4pisk87wn7671hq8jgn67wyhyka";
    };
    meta.homepage = "https://github.com/equalsraf/neovim-gui-shim/";
  };

  neovim-session-manager = buildVimPlugin {
    pname = "neovim-session-manager";
    version = "2023-10-09";
    src = fetchFromGitHub {
      owner = "Shatur";
      repo = "neovim-session-manager";
      rev = "68dde355a4304d83b40cf073f53915604bdd8e70";
      sha256 = "0jqa8ji40y28bbl5maxb44sgdi6522lszczrz3rfcv122blm1qjq";
    };
    meta.homepage = "https://github.com/Shatur/neovim-session-manager/";
  };

  noice-nvim = buildVimPlugin {
    pname = "noice.nvim";
    version = "2023-10-25";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "noice.nvim";
      rev = "92433164e2f7118d4122c7674c3834d9511722ba";
      sha256 = "0cs7hnjgv1np3pmz0li9g4m01i87z360x0fpbh4aqck4k8mhjn7f";
    };
    meta.homepage = "https://github.com/folke/noice.nvim/";
  };

  novim-mode = buildVimPlugin {
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

  nui-nvim = buildNeovimPlugin {
    pname = "nui.nvim";
    version = "2023-12-06";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "c9b4de623d19a85b353ff70d2ae9c77143abe69c";
      sha256 = "1km9qyl54kysyiq2kz8f52gyqcri545k4rb68kfm45kfcn7l7wrc";
    };
    meta.homepage = "https://github.com/MunifTanjim/nui.nvim/";
  };

  null-ls-nvim = buildVimPlugin {
    pname = "null-ls.nvim";
    version = "2023-08-12";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "0010ea927ab7c09ef0ce9bf28c2b573fc302f5a7";
      sha256 = "00nkg77y9mp7ac46bdcaga36bbbrwbp7k1d6ajjgg9qf76pk8q3i";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim/";
  };

  nvim-cmp = buildNeovimPlugin {
    pname = "nvim-cmp";
    version = "2023-12-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "41d7633e4146dce1072de32cea31ee31b056a131";
      sha256 = "0l72vrylmw8zv9hvl8rhiycn69s50fn5064h3ydhpf432b8b65sb";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-colorizer-lua = buildVimPlugin {
    pname = "nvim-colorizer.lua";
    version = "2023-02-27";
    src = fetchFromGitHub {
      owner = "NvChad";
      repo = "nvim-colorizer.lua";
      rev = "dde3084106a70b9a79d48f426f6d6fec6fd203f7";
      sha256 = "1nk72p1lqs5gl5lr8fp1nd6qpif90xlp38pc7znaflgyp9lm0a45";
    };
    meta.homepage = "https://github.com/NvChad/nvim-colorizer.lua/";
  };

  nvim-hlslens = buildVimPlugin {
    pname = "nvim-hlslens";
    version = "2023-11-30";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "9bd8d6b155fafc59da18291858c39f115464287c";
      sha256 = "0d3dxc0v347z6dz7zmnf845kzv6j2yca94pgakaac4x6m3lcy5xl";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPlugin {
    pname = "nvim-lspconfig";
    version = "2023-12-10";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "bd405e45c5fb122c16af8f87fa2dd7ab1981b243";
      sha256 = "1jfjy8j91b66i2kkzikkybl56b62ybj8kshxyjjwlvlz9vaqd06j";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-notify = buildVimPlugin {
    pname = "nvim-notify";
    version = "2023-09-28";
    src = fetchFromGitHub {
      owner = "rcarriga";
      repo = "nvim-notify";
      rev = "e4a2022f4fec2d5ebc79afa612f96d8b11c627b3";
      sha256 = "1a7s4y8xd1plcidnzs29rhqw7mfbj1q01bqffqjmimii9v6azmfn";
    };
    meta.homepage = "https://github.com/rcarriga/nvim-notify/";
  };

  nvim-scrollbar = buildVimPlugin {
    pname = "nvim-scrollbar";
    version = "2023-05-23";
    src = fetchFromGitHub {
      owner = "petertriho";
      repo = "nvim-scrollbar";
      rev = "35f99d559041c7c0eff3a41f9093581ceea534e8";
      sha256 = "1hyi8x7w8gb2sybqv12jbva4y8jh7zf6nf4d7m3py2jh5k2mxc6c";
    };
    meta.homepage = "https://github.com/petertriho/nvim-scrollbar/";
  };

  nvim-surround = buildVimPlugin {
    pname = "nvim-surround";
    version = "2023-12-04";
    src = fetchFromGitHub {
      owner = "kylechui";
      repo = "nvim-surround";
      rev = "633a0ab03159569a66b65671b0ffb1a6aed6cf18";
      sha256 = "0svcw6rjrnjxh6i54a4nq8af5n3634gf30cycv3f95xywmn2h7m6";
    };
    meta.homepage = "https://github.com/kylechui/nvim-surround/";
  };

  nvim-tree-lua = buildVimPlugin {
    pname = "nvim-tree.lua";
    version = "2023-12-11";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-tree.lua";
      rev = "141c0f97c35f274031294267808ada59bb5fb08e";
      sha256 = "0n41viq9pi9x6rc89lhrrb5vxq26vm4rzgqp36mafjfw5y86rq3n";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-tree.lua/";
  };

  nvim-treesitter = buildVimPlugin {
    pname = "nvim-treesitter";
    version = "2023-12-11";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "a6c655629cad421e432aa84af32cbfe35375113a";
      sha256 = "0cpnn155y1ygqkk18929mn7iq4hd0naxxdb8nh5z7621w0w8nanf";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter/";
  };

  nvim-treesitter-context = buildVimPlugin {
    pname = "nvim-treesitter-context";
    version = "2023-12-08";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "cfa8ee19ac9bae9b7fb2958eabe2b45b70c56ccb";
      sha256 = "1qz089qfmn1ksv82jmjl5flgkfspmsjn0midwb3jvgdn56x58ypc";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context/";
  };

  nvim-treesitter-textobjects = buildVimPlugin {
    pname = "nvim-treesitter-textobjects";
    version = "2023-12-01";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "ec1c5bdb3d87ac971749fa6c7dbc2b14884f1f6a";
      sha256 = "1kdfwihk8ci827aq4w6xv7vn2740qpmh6dk892cd6yi0ab4zxvxn";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/";
  };

  nvim-web-devicons = buildVimPlugin {
    pname = "nvim-web-devicons";
    version = "2023-12-08";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "8b2e5ef9eb8a717221bd96cb8422686d65a09ed5";
      sha256 = "0s7vhlr71f3n8in2dnpqj1p1jgncn0mdl1y6a7ksl8yx2vrxqdyl";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPlugin {
    pname = "omnisharp-vim";
    version = "2023-10-15";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "f9c5d3e3375e8b5688a4506e813cb21bdc7329b1";
      sha256 = "0y4ajbipdcvdxxb4vcknkxisjfpi9qgrhkr8glpnjdb9dypf0w6g";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
  };

  plantuml-previewer-vim = buildVimPlugin {
    pname = "plantuml-previewer.vim";
    version = "2023-03-07";
    src = fetchFromGitHub {
      owner = "weirongxu";
      repo = "plantuml-previewer.vim";
      rev = "1dd4d0f2b09cd80a217f76d82f93830dbbe689b3";
      sha256 = "0pvdiyyqd9j65q9wf3y6jxgry4lxvnbd2ah1761a4vbn02zdrr2v";
    };
    meta.homepage = "https://github.com/weirongxu/plantuml-previewer.vim/";
  };

  plenary-nvim = buildNeovimPlugin {
    pname = "plenary.nvim";
    version = "2023-11-30";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "55d9fe89e33efd26f532ef20223e5f9430c8b0c0";
      sha256 = "1f6vqqafk78njpl47xgsf8p199mmvw4h4b9axab9rl86fdlibikz";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
  };

  previm = buildVimPlugin {
    pname = "previm";
    version = "2023-09-15";
    src = fetchFromGitHub {
      owner = "previm";
      repo = "previm";
      rev = "2b2e4a8002877741e9f584b9b3751ed0d47e5952";
      sha256 = "0sh2sj3wiw93h26rvkfi1q9xb9q5r4k6gbl9iqycb87c9qhp4lqw";
    };
    meta.homepage = "https://github.com/previm/previm/";
  };

  searchbox-nvim = buildVimPlugin {
    pname = "searchbox.nvim";
    version = "2022-10-31";
    src = fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "searchbox.nvim";
      rev = "110949af8963185b4e732b45ae57beb731bfcede";
      sha256 = "1dahiggnc8hqfgd9akxlsyck7gxz05w0phrvahc5g1kskyr0q7h7";
    };
    meta.homepage = "https://github.com/VonHeikemen/searchbox.nvim/";
  };

  smart-splits-nvim = buildVimPlugin {
    pname = "smart-splits.nvim";
    version = "2023-12-02";
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "c970c7a3cc7ba635fd73d43c81b40f04c00f5058";
      sha256 = "0ri4b6q4qqy1cwyhknysnldbrg2yx4cfi2ddgvnn6snq8jhkmjbw";
    };
    meta.homepage = "https://github.com/mrjones2014/smart-splits.nvim/";
  };

  sonokai = buildVimPlugin {
    pname = "sonokai";
    version = "2023-10-24";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "bdce098fc9e7202d3c555e2dc98c755ca1c23835";
      sha256 = "09brv393ccqgvg0xwg55lh6ss5c16qs1as2hrrqh8952c1kqzxig";
    };
    meta.homepage = "https://github.com/sainnhe/sonokai/";
  };

  telescope-frecency-nvim = buildVimPlugin {
    pname = "telescope-frecency.nvim";
    version = "2023-12-03";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-frecency.nvim";
      rev = "de410701811f4142315ce89183256a969a08ff9d";
      sha256 = "1wcbkqlwy6k8jsz0sqk0mqhlm6d0j8l3rdxw8vlwby00fbscs0is";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-frecency.nvim/";
  };

  telescope-nvim = buildNeovimPlugin {
    pname = "telescope.nvim";
    version = "2023-12-06";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "6213322ab56eb27356fdc09a5078e41e3ea7f3bc";
      sha256 = "074bq8p1bkyr12z1wy31bipb97vmqia4lsmdp2aj1v1r5x5ph736";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";
  };

  themer-lua = buildVimPlugin {
    pname = "themer.lua";
    version = "2023-10-16";
    src = fetchFromGitHub {
      owner = "themercorp";
      repo = "themer.lua";
      rev = "625510cfec70b55fe42d04b1256c5f93c92a4202";
      sha256 = "0lxkqdv4mn20pk0sn55vg543y2qfszgqbl6avypriih5j43ql77x";
    };
    meta.homepage = "https://github.com/themercorp/themer.lua/";
  };

  vim-conque = buildVimPlugin {
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

  vim-ctrlspace = buildVimPlugin {
    pname = "vim-ctrlspace";
    version = "2023-09-11";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "38266fba90e5bcc5db026522f5ade0e0e0a9a17f";
      sha256 = "11hf1wk13f18pa8qmiqs15v85jjy3ifsx4p3a7j2w2kl11hsb7s7";
    };
    meta.homepage = "https://github.com/vim-ctrlspace/vim-ctrlspace/";
  };

  vim-fakeclip = buildVimPlugin {
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

  vim-hashicorp-tools = buildVimPlugin {
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

  vim-jinja2-syntax = buildVimPlugin {
    pname = "vim-jinja2-syntax";
    version = "2021-06-22";
    src = fetchFromGitHub {
      owner = "glench";
      repo = "vim-jinja2-syntax";
      rev = "2c17843b074b06a835f88587e1023ceff7e2c7d1";
      sha256 = "13mfzsw3kr3r826wkpd3jhh1sy2j10hlj1bv8n8r01hpbngikfg7";
    };
    meta.homepage = "https://github.com/glench/vim-jinja2-syntax/";
  };

  vim-pasta = buildVimPlugin {
    pname = "vim-pasta";
    version = "2023-08-12";
    src = fetchFromGitHub {
      owner = "ku1ik";
      repo = "vim-pasta";
      rev = "2b786703eef9f82ae7a56f3de4ee43e1e5efaaa5";
      sha256 = "1q4d512rq57awasb441slqp29mkzi3jxmy8clrp2s9ydwdbndwlx";
    };
    meta.homepage = "https://github.com/ku1ik/vim-pasta/";
  };

  vim-perforce = buildVimPlugin {
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

  which-key-nvim = buildVimPlugin {
    pname = "which-key.nvim";
    version = "2023-10-20";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "4433e5ec9a507e5097571ed55c02ea9658fb268a";
      sha256 = "1inm7szfhji6l9k4khq9fvddbwj348gilgbd6b8nlygd7wz23y5s";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim/";
  };


}
