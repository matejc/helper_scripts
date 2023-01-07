# This file has been generated by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2022-12-20";
    src = fetchFromGitHub {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "5570fd797eae0790affb54ea669a150cad76db5d";
      sha256 = "0052rkqyhniz6djz7gkblmdlndllwv9jhcl6kh973qq23pdb00n4";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/L3MON4D3/LuaSnip/";
  };

  alpha-nvim = buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "2022-11-29";
    src = fetchFromGitHub {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "21a0f2520ad3a7c32c0822f943368dc063a569fb";
      sha256 = "1s9ywy69kap0gngpm5xnfkwlrb2apci9xv2ahs2xhhkjncqm38mq";
    };
    meta.homepage = "https://github.com/goolord/alpha-nvim/";
  };

  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline.nvim";
    version = "2022-12-24";
    src = fetchFromGitHub {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "c7492a76ce8218e3335f027af44930576b561013";
      sha256 = "18vfx8mq2gsv2hqy0c0vgbmx5mhr63bb8ixrmzmjgvbx2djz1jdb";
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
    version = "2022-11-27";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "23c51b2a3c00f6abc4e922dbd7c3b9aca6992063";
      sha256 = "0vffivj94736njjhlazrs0jkc1nyvcdjpw64w38d1lhlyflf4cl7";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-11-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "59224771f91b86d1de12570b4070fe4ad7cd1eeb";
      sha256 = "1m8xs7fznf4kk6d96f2fxgwd7i5scd04pfy2s4qsb5gzh7q2ka9j";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-nvim-lsp-signature-help = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp-signature-help";
    version = "2022-10-14";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "d2768cb1b83de649d57d967085fe73c5e01f8fd7";
      sha256 = "13imcdv0yws084z2x2lmdj17zy4ngf126i7djknnwp2jfkca1120";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/";
  };

  cmp-path = buildVimPluginFrom2Nix {
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

  cmp-rg = buildVimPluginFrom2Nix {
    pname = "cmp-rg";
    version = "2022-09-05";
    src = fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "cmp-rg";
      rev = "1cad8eb315643d0df13c37401c03d7986f891011";
      sha256 = "02ij7isp6hzcfkd5zw9inymmpgcmhiz0asjra45w8jkzqlxd322j";
    };
    meta.homepage = "https://github.com/lukas-reineke/cmp-rg/";
  };

  cmp-spell = buildVimPluginFrom2Nix {
    pname = "cmp-spell";
    version = "2022-10-10";
    src = fetchFromGitHub {
      owner = "f3fora";
      repo = "cmp-spell";
      rev = "60584cb75e5e8bba5a0c9e4c3ab0791e0698bffa";
      sha256 = "1lzv8wbq1w45pbig7lcgyj46nmz4gkag7b37j72p04bixr7wgabv";
    };
    meta.homepage = "https://github.com/f3fora/cmp-spell/";
  };

  cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "cmp-treesitter";
    version = "2022-10-28";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "b40178b780d547bcf131c684bc5fd41af17d05f2";
      sha256 = "076x4rfcvy81m28dpjaqcxrl3q9mhfz7qbwgkqsyndrasibsmlzr";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter/";
  };

  cmp-vsnip = buildVimPluginFrom2Nix {
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

  cmp_luasnip = buildVimPluginFrom2Nix {
    pname = "cmp_luasnip";
    version = "2022-10-28";
    src = fetchFromGitHub {
      owner = "saadparwaiz1";
      repo = "cmp_luasnip";
      rev = "18095520391186d634a0045dacaa346291096566";
      sha256 = "0b91ap1l3nph46r7b5hcn7413yj3zhrz1jmn4xqp387ng35qz537";
    };
    meta.homepage = "https://github.com/saadparwaiz1/cmp_luasnip/";
  };

  friendly-snippets = buildVimPluginFrom2Nix {
    pname = "friendly-snippets";
    version = "2023-01-03";
    src = fetchFromGitHub {
      owner = "rafamadriz";
      repo = "friendly-snippets";
      rev = "484fb38b8f493ceeebf4e6fc499ebe41e10aae25";
      sha256 = "1kjcc0gsn12zrd2bn19w54b4a5ww6g5vsv4rfrw6wk67bk1ckfkf";
    };
    meta.homepage = "https://github.com/rafamadriz/friendly-snippets/";
  };

  galaxyline-nvim = buildVimPluginFrom2Nix {
    pname = "galaxyline.nvim";
    version = "2022-12-25";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "galaxyline.nvim";
      rev = "be96f3dc257edd0eff57ea99777264ae26f1038f";
      sha256 = "1205bvn5adxf8s2cwxqiyy4ar30iq7vcswyyk53j85j7cfqglp9k";
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
    version = "2023-01-04";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "d4f8c01280413919349f5df7daccd0c172143d7c";
      sha256 = "114c7yjgi6d9mhr1c94n73msr3204idvcbh6y7i8y0853aan0jiz";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox.nvim";
    version = "2023-01-04";
    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "e863942494d7c72a7c8d2c54cf651f28fc5a76ab";
      sha256 = "0xh1y64bn274f7rm597gqgqjrra5fafydqcm127ikdiqsa948psy";
    };
    meta.homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
  };

  image-nvim = buildVimPluginFrom2Nix {
    pname = "image.nvim";
    version = "2022-11-23";
    src = fetchFromGitHub {
      owner = "samodostal";
      repo = "image.nvim";
      rev = "dc11753ba86afdabff3e0d3f73925424e391bc00";
      sha256 = "0qsypqx2afi2qs97z4d3187rsd8nljwgcn8gki7c91yk4iahlsrm";
    };
    meta.homepage = "https://github.com/samodostal/image.nvim/";
  };

  lsp_signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp_signature.nvim";
    version = "2022-12-24";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "lsp_signature.nvim";
      rev = "1979f1118e2b38084e7c148f279eed6e9300a342";
      sha256 = "0di84pidxf0mx2gcna3lhisx3drc1i2wajcrrc2dv7n122fv17yy";
    };
    meta.homepage = "https://github.com/ray-x/lsp_signature.nvim/";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind.nvim";
    version = "2022-09-22";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind.nvim";
      rev = "c68b3a003483cf382428a43035079f78474cd11e";
      sha256 = "0qrfqajpbkb757vbcjz1g7v5rihsyhg1f1jxrbwg08dbxpw101av";
    };
    meta.homepage = "https://github.com/onsails/lspkind.nvim/";
  };

  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga.nvim";
    version = "2022-12-13";
    src = fetchFromGitHub {
      owner = "glepnir";
      repo = "lspsaga.nvim";
      rev = "b7b4777369b441341b2dcd45c738ea4167c11c9e";
      sha256 = "16gygs2dggjv2kfapm9r5qrdssnagqyqxw8m7dc8vk9iygyrgj5i";
    };
    meta.homepage = "https://github.com/glepnir/lspsaga.nvim/";
  };

  lush-nvim = buildNeovimPluginFrom2Nix {
    pname = "lush.nvim";
    version = "2023-01-02";
    src = fetchFromGitHub {
      owner = "rktjmp";
      repo = "lush.nvim";
      rev = "b1e8eb1da3fee95ef31515a73c9eff9bf251088d";
      sha256 = "0q3prq4fm9rpczl7b1lgqnhs0z5jgvpdy0cp45jfpw4bvcy6vkpq";
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
    version = "2022-12-26";
    src = fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "3b41f0d17139bb156f1acd907608f63e0e307caf";
      sha256 = "1lvhkqvzrlw6fskbrpgy5mf110jjibc1r2g67pfi12ppcmxpzqry";
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
    version = "2022-12-09";
    src = fetchFromGitHub {
      owner = "Shatur";
      repo = "neovim-session-manager";
      rev = "f8c85da390c5d1ad3bfd229ac2ed805c5742263d";
      sha256 = "1vlrv9k26zw29xa481y41dy1bjr0ykpd0vxsmvhvq2rkp8pzrmml";
    };
    meta.homepage = "https://github.com/Shatur/neovim-session-manager/";
  };

  noice-nvim = buildVimPluginFrom2Nix {
    pname = "noice.nvim";
    version = "2023-01-04";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "noice.nvim";
      rev = "eadc279a27abc34ffcde84596e24e7780add11b1";
      sha256 = "1dww1rzbakznxjbcfa8gck02m7fli64ym8i00rr16gri6drp5hkm";
    };
    meta.homepage = "https://github.com/folke/noice.nvim/";
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
    version = "2023-01-03";
    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "257da38029d3859ed111804f9d4e95b0fa993a31";
      sha256 = "0vdibc6qa1l82nzryin9f9hnx6v99nwnpfvzlh2w419y3f9i6sfk";
    };
    meta.homepage = "https://github.com/MunifTanjim/nui.nvim/";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls.nvim";
    version = "2023-01-05";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "6830a1ed04f89e6d556cb6bcc200433173004307";
      sha256 = "0kgb5j4xxh7s0zwrhcz8gl9y8bai25cl9ix5anizma6rvr5x42il";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim/";
  };

  nvim-cmp = buildNeovimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2023-01-06";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "11a95792a5be0f5a40bab5fc5b670e5b1399a939";
      sha256 = "178r1v9p7mcwg8xgl3jr4ibjsh9wiq0y81mps0nhx8q2dgnx8cyz";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-colorizer-lua = buildVimPluginFrom2Nix {
    pname = "nvim-colorizer.lua";
    version = "2022-10-29";
    src = fetchFromGitHub {
      owner = "NvChad";
      repo = "nvim-colorizer.lua";
      rev = "760e27df4dd966607e8fb7fd8b6b93e3c7d2e193";
      sha256 = "0zqwdj7qk8sldz99c3f5m2xmvl2kj7n18f9jr9q17nb70rz490xn";
    };
    meta.homepage = "https://github.com/NvChad/nvim-colorizer.lua/";
  };

  nvim-hlslens = buildVimPluginFrom2Nix {
    pname = "nvim-hlslens";
    version = "2023-01-05";
    src = fetchFromGitHub {
      owner = "kevinhwang91";
      repo = "nvim-hlslens";
      rev = "9234f0fd7ec6042e8b4c70d41d25478a6cbf3a8e";
      sha256 = "1qlwhfdlg55pfx883k95i914myn509p69wkdjlv44asad36qhij4";
    };
    meta.homepage = "https://github.com/kevinhwang91/nvim-hlslens/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2023-01-04";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "e69978a39e4d3262b09ce6a316beff384f443e3b";
      sha256 = "0dz6l7kd2jzdg9a7b8zi718rvsdpa885asif7ncx9yf7b6f12mk6";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-notify = buildVimPluginFrom2Nix {
    pname = "nvim-notify";
    version = "2022-12-06";
    src = fetchFromGitHub {
      owner = "rcarriga";
      repo = "nvim-notify";
      rev = "b005821516f1f37801a73067afd1cef2dbc4dfe8";
      sha256 = "06y5akjhrnnsdkjxbcci7fxar8qj37qsl5i18xyx4lzzslxf7nvy";
    };
    meta.homepage = "https://github.com/rcarriga/nvim-notify/";
  };

  nvim-scrollbar = buildVimPluginFrom2Nix {
    pname = "nvim-scrollbar";
    version = "2023-01-04";
    src = fetchFromGitHub {
      owner = "petertriho";
      repo = "nvim-scrollbar";
      rev = "6e704cdeb7114385b4b19f9dc4b8f0c442019edc";
      sha256 = "0pw3x1k5r0z2g5bxfgvaafh6jzc2zfw3v7f69p2jn9yzbg5afchy";
    };
    meta.homepage = "https://github.com/petertriho/nvim-scrollbar/";
  };

  nvim-surround = buildVimPluginFrom2Nix {
    pname = "nvim-surround";
    version = "2023-01-01";
    src = fetchFromGitHub {
      owner = "kylechui";
      repo = "nvim-surround";
      rev = "ad56e6234bf42fb7f7e4dccc7752e25abd5ec80e";
      sha256 = "1fi5lk3iacjdbq1p4wm0bia93awwqfn7jiy019vpg4gngi41azrz";
    };
    meta.homepage = "https://github.com/kylechui/nvim-surround/";
  };

  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree.lua";
    version = "2023-01-03";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-tree.lua";
      rev = "bac962caf472a4404ed3ce1ba2fcaf32f8002951";
      sha256 = "1nzyxf05a420cyjz1844sjkc8yw4ihnv2f2ig014gqgj3spijxpx";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-tree.lua/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2022-12-09";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "05e1072f63f6c194ac6e867b567e6b437d3d4622";
      sha256 = "1b53nrmzga6bkf6cdck3hdwjyrlslyrsa7jv55198jy153y8qq2z";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-web-devicons/";
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2022-12-03";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "0b643d4564207e85d19b94180e6ab2e89e7f9c50";
      sha256 = "0bxh4rijypxs1rahvb5h2fk3w8wjifz92dj1whlgf5srm1mvgdcj";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/OmniSharp/omnisharp-vim/";
  };

  plantuml-previewer-vim = buildVimPluginFrom2Nix {
    pname = "plantuml-previewer.vim";
    version = "2022-12-09";
    src = fetchFromGitHub {
      owner = "weirongxu";
      repo = "plantuml-previewer.vim";
      rev = "74483d5d01042db5de6f89aaba64376d87effaff";
      sha256 = "1xna71n2ikm75vp9bvyhbrjhndlrs3kalqz71d9dz3w9b4x95a82";
    };
    meta.homepage = "https://github.com/weirongxu/plantuml-previewer.vim/";
  };

  plenary-nvim = buildNeovimPluginFrom2Nix {
    pname = "plenary.nvim";
    version = "2023-01-06";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "95fb27dfcf6330ac482a99545d7440ac6729851b";
      sha256 = "1dvslfyjccjpdcca1566bp7y3fqn6f3cqkp1b44cw3gzz5kaf78s";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
  };

  previm = buildVimPluginFrom2Nix {
    pname = "previm";
    version = "2022-12-28";
    src = fetchFromGitHub {
      owner = "previm";
      repo = "previm";
      rev = "dcda34b72f6b224602b02a179d4f35e06e53d465";
      sha256 = "12v7y6i1ag4w5c7bi65fdqk64phahdglnz7457rnsxz9184z5a81";
    };
    meta.homepage = "https://github.com/previm/previm/";
  };

  searchbox-nvim = buildVimPluginFrom2Nix {
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

  smart-splits-nvim = buildVimPluginFrom2Nix {
    pname = "smart-splits.nvim";
    version = "2022-12-21";
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "fdd158ce7554dc830fb86e0fe952cd9476cdf726";
      sha256 = "17xjcfjfzmy4crs6ks8drdjcygdnri776gf3vmnssjyvmzab3mdl";
    };
    meta.homepage = "https://github.com/mrjones2014/smart-splits.nvim/";
  };

  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2023-01-03";
    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "sonokai";
      rev = "27b72e7f7d842d8f22d635a5f4bbc8d00f2463a6";
      sha256 = "1mj9llas4bnh3bxxj8fc94c6gwxfqc1gqiqg6q6xpwsa7iffjp1x";
    };
    meta.homepage = "https://github.com/sainnhe/sonokai/";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope.nvim";
    version = "2023-01-06";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "18fc02b499b368287e3aa267ec0b0d22afc0f19b";
      sha256 = "01g6pfy13bp9ms5ccx62myxxzqzy9rwmrp8aclc2biylrlh9jg27";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";
  };

  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer.lua";
    version = "2022-11-10";
    src = fetchFromGitHub {
      owner = "themercorp";
      repo = "themer.lua";
      rev = "ec1e098eb81b8fe33befa40ddfd78b98fc6455d4";
      sha256 = "1j5qb5dg0dzbb9fjybw62qvrckxz6ynbm5q2ldpjqfb4r0hn5zfc";
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
    version = "2022-10-30";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "5e444c6af06de58d5ed7d7bd0dcbb958f292cd2e";
      sha256 = "0hxmi2d6844spdypks7ypnf0rs0hyiafvsh3gd00maag6mcmm48h";
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


}
