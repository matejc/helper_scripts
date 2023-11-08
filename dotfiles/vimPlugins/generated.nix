# GENERATED by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPlugin, buildNeovimPlugin, fetchFromGitHub, fetchgit }:

final: prev:
{
  ChatGPT-nvim = buildVimPlugin {
    pname = "ChatGPT.nvim";
    version = "2023-10-16";
    src = fetchFromGitHub {
      owner = "jackMort";
      repo = "ChatGPT.nvim";
      rev = "9f8062c7c40ec082c49f10e20818333a972b8063";
      sha256 = "0k8y48rrzqf8r1mbyi370grgxa28612qwm67mwsk3zhnm3496060";
    };
    meta.homepage = "https://github.com/jackMort/ChatGPT.nvim/";
  };

  LuaSnip = buildVimPlugin {
    pname = "LuaSnip";
    version = "2023-11-04";
    src = fetchFromGitHub {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "a4de64570b9620875c8ea04175cd07ed8e32ac99";
      sha256 = "0k6ql48hm0z9ii5p07cs217wz376fz8q1syl65xjcfnlvbdxb6x8";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/L3MON4D3/LuaSnip/";
  };

  alpha-nvim = buildVimPlugin {
    pname = "alpha-nvim";
    version = "2023-09-14";
    src = fetchFromGitHub {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "234822140b265ec4ba3203e3e0be0e0bb826dff5";
      sha256 = "15iq6wkcij0sxngs3y221nffk3rk215frifklxzc2db5s9na4w5d";
    };
    meta.homepage = "https://github.com/goolord/alpha-nvim/";
  };

  bufferline-nvim = buildVimPlugin {
    pname = "bufferline.nvim";
    version = "2023-11-01";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "9e8d2f695dd50ab6821a6a53a840c32d2067a78a";
      sha256 = "08k2b8i269c50gq3nl2s08izwl2p454xshl3yslcwwi3hsg25blm";
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
    version = "2023-06-23";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "44b16d11215dce86f253ce0c30949813c0a90765";
      sha256 = "1ny64ls3z9pcflsg3sd7xnd795mcfbqhyan3bk4ymxgv5jh2qkcr";
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
    version = "2023-10-06";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "b8bc760dfcc624edd5454f0982b63786a822eed9";
      sha256 = "01fz8hj7qadg2h8q0d3xv7x9q0qsykbbvv6bdnw71j74rid4xw7k";
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

  friendly-snippets = buildVimPlugin {
    pname = "friendly-snippets";
    version = "2023-10-01";
    src = fetchFromGitHub {
      owner = "rafamadriz";
      repo = "friendly-snippets";
      rev = "43727c2ff84240e55d4069ec3e6158d74cb534b6";
      sha256 = "1sjk17gn919aa84dkjfagwwjsas9zfkbrk840bjf580k8m83d9m8";
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
    version = "2023-10-26";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "af0f583cd35286dd6f0e3ed52622728703237e50";
      sha256 = "04qr0zm8cfrsf306jswah4cja8dsih3b41ikakcbvgq08qsngj86";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  gruvbox-nvim = buildVimPlugin {
    pname = "gruvbox.nvim";
    version = "2023-10-07";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "477c62493c82684ed510c4f70eaf83802e398898";
      sha256 = "0250c24c6n6yri48l288irdawhqs16qna3y74rdkgjd2jvh66vdm";
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
    version = "2023-11-07";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "9ed85616b772a07f8db56c26e8fff2d962f1f211";
      sha256 = "0vymhx89wzmqw9xzvqj9sni0a86wql88ibn07h08qinqcnsg8kb3";
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
    version = "2023-11-07";
    src = fetchFromGitHub {
      owner = "nvimdev";
      repo = "lspsaga.nvim";
      rev = "8b027966d1d5845831107a2505999d380cb18669";
      sha256 = "10nnrm2ijjycl95r0k01kgamvrai9w4pi1hcy24i01yc0nm8r234";
    };
    meta.homepage = "https://github.com/nvimdev/lspsaga.nvim/";
  };

  lush-nvim = buildNeovimPlugin {
    pname = "lush.nvim";
    version = "2023-09-23";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "966aad1accd47fa11fbe2539234f81f678fef2de";
      sha256 = "0g1xib2k42py9qqccjz11qk52ri0drgdk5rb0ls7wzx4v636k15h";
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
    version = "2023-11-07";
    src = fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "f053f09962819c1558cd93639aa80edf7c314c17";
      sha256 = "0s3v754nc661b772h4n5r5yzwk3a3bph5gq93c3fpld8w7zj1bl0";
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
    version = "2023-10-09";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "c0c8e347ceac53030f5c1ece1c5a5b6a17a25b32";
      sha256 = "0x3bf63d4xblpvjirnhsk4ifb58rw6wprmj86dsfqjzls37fw6m5";
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
    version = "2023-11-06";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "0b751f6beef40fd47375eaf53d3057e0bfa317e4";
      sha256 = "1qp7s2iam9zzdlw5sgkk6c623z7vjgga0rcg63ja0f836l90grba";
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
    version = "2023-08-06";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "f0281591a59e95400babf61a96e59ba20e5c9533";
      sha256 = "1ih4zkb025wvns0bgk3g9ps9krwj5jfzi49qqvg5v3v707ypq2kj";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPlugin {
    pname = "nvim-lspconfig";
    version = "2023-11-06";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "37457f268af5cd6765e589b0dcd7cbd192d8da00";
      sha256 = "0pspyr4ppvy2zv6iqa4lnicivrhivmky00y28zkkpchji14ybm36";
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
    version = "2023-10-22";
    src = fetchFromGitHub {
      owner = "kylechui";
      repo = "nvim-surround";
      rev = "4f0e1f470595af067eca9b872778d83c7f52f134";
      sha256 = "16q85dd79rdn1v7wqshzhjgrsgbnzk04l4vjgp6g9hbj8p8sna4k";
    };
    meta.homepage = "https://github.com/kylechui/nvim-surround/";
  };

  nvim-tree-lua = buildVimPlugin {
    pname = "nvim-tree.lua";
    version = "2023-11-07";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-tree.lua";
      rev = "4ee6366ff1fc5d66231516ed05beffb50004261b";
      sha256 = "0bx2aw0x631dpcq6jix3dfvzf6f2mnshnzr3pvvbqxqifin9bxc7";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-tree.lua/";
  };

  nvim-treesitter = buildVimPlugin {
    pname = "nvim-treesitter";
    version = "2023-11-08";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "7b26b085880f5c99c9e6109c81ed3b08db90ce50";
      sha256 = "0plpx75ky3l71lf0n1i1xrk3lkhh7rbjbhf0wbz51brg8c8g52jz";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter/";
  };

  nvim-treesitter-context = buildVimPlugin {
    pname = "nvim-treesitter-context";
    version = "2023-10-28";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "2806d83e3965017382ce08792ee527e708fa1bd4";
      sha256 = "0pk6pvqq8xm3jspq7zpkh7rpqdammq1np3gc5x1kjly0q11rf5pn";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context/";
  };

  nvim-treesitter-textobjects = buildVimPlugin {
    pname = "nvim-treesitter-textobjects";
    version = "2023-11-07";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "e1e670a86274d5cb681e475d4891ea1afe605ced";
      sha256 = "1msfr6y7hssfjyrjk66zvmq5pkh9lpkw85wfrxz9fi568ks3n7fn";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/";
  };

  nvim-web-devicons = buildVimPlugin {
    pname = "nvim-web-devicons";
    version = "2023-10-24";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "5de460ca7595806044eced31e3c36c159a493857";
      sha256 = "1ncwiha8ldxzx1g1hfisrgsvnqv05p7c19glbjp5bwbm5ihfsv04";
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
    version = "2023-10-11";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "50012918b2fc8357b87cff2a7f7f0446e47da174";
      sha256 = "1sn7vpsbwpyndsjyxb4af8fvz4sfhlbavvw6jjsv3h18sdvkh7nd";
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
    version = "2023-10-17";
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "c8a9173d70cbbd1f6e4a414e49e31df2b32a1362";
      sha256 = "0hxy3fv6qp7shwh9wgf20q5i8ba2pzng2dd1dvw27aabibk43ba3";
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
    version = "2023-10-10";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-frecency.nvim";
      rev = "daf59744f60e34cbb48a40a092e9e735553b6f21";
      sha256 = "0mlfnhyz1daxmrfvvqmwpcqpqkl4nd5dqwz4ac539ffaca2mf6zb";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-frecency.nvim/";
  };

  telescope-nvim = buildNeovimPlugin {
    pname = "telescope.nvim";
    version = "2023-11-06";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "20bf20500c95208c3ac0ef07245065bf94dcab15";
      sha256 = "096vv98xxdqy96ipz6lbricfr74bkc3r58x1si1816lnm0j896r5";
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
