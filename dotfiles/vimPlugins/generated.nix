# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, overrides ? (self: super: {}) }:

let
  packages = ( self:
{
  async-vim = buildVimPluginFrom2Nix {
    pname = "async-vim";
    version = "2021-03-21";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "async.vim";
      rev = "0fb846e1eb3c2bf04d52a57f41088afb3395212e";
      sha256 = "1glzg0i53wkm383y1vbddbyp1ivlsx2hivjchiw60sr9gccn8f8l";
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
    version = "2021-04-11";
    src = fetchFromGitHub {
      owner = "yami-beta";
      repo = "asyncomplete-omni.vim";
      rev = "f13986b671a37d6320476af6bc066697e71463c1";
      sha256 = "191n7j0m9z5skzzvl6cdlkb7pl7n65g4wiqxdpawbicw5zk80sd4";
    };
  };

  asyncomplete-tags-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-tags-vim";
    version = "2021-04-29";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-tags.vim";
      rev = "041af0565f2c16634277cd29d2429c573af1dac4";
      sha256 = "0i1ahg96j1ixyps0lfzl7w7skd64y6br1zn3bms447341zw4lc0k";
    };
  };

  asyncomplete-vim = buildVimPluginFrom2Nix {
    pname = "asyncomplete-vim";
    version = "2021-05-04";
    src = fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete.vim";
      rev = "6c653c3f8f1c1cf7a34522c9555d5160f36d29ee";
      sha256 = "1zzdybfswlh66gw8a3imkwf7m6g13rlf6dqyg71c6bfmn3zlx2l0";
    };
  };

  ctrlsf-vim = buildVimPluginFrom2Nix {
    pname = "ctrlsf-vim";
    version = "2021-05-21";
    src = fetchFromGitHub {
      owner = "dyng";
      repo = "ctrlsf.vim";
      rev = "51c5b285146f042bd2015278f9b8ad74ae915e00";
      sha256 = "1901cr6sbaa8js4ylirz9p4m0r9q0a06gm71ghl6kp6pw7h5fgmq";
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
    version = "2021-03-27";
    src = fetchFromGitHub {
      owner = "equalsraf";
      repo = "neovim-gui-shim";
      rev = "668188542345e682addfc816af38b7073d376a64";
      sha256 = "1s1ws7cfhg0rjfzf5clr2w6k9b8fkd57jzfna3vx1caymwspwrw2";
    };
  };

  nerdtree = buildVimPluginFrom2Nix {
    pname = "nerdtree";
    version = "2021-03-25";
    src = fetchFromGitHub {
      owner = "preservim";
      repo = "nerdtree";
      rev = "81f3eaba295b3fceb2d032db57e5eae99ae480f8";
      sha256 = "0zws0b20n8ak2s3hffsb0rrwdjh8sx3sgrilmmmvr0d2ivsfqwlb";
    };
  };

  nerdtree-git-plugin = buildVimPluginFrom2Nix {
    pname = "nerdtree-git-plugin";
    version = "2021-05-17";
    src = fetchFromGitHub {
      owner = "Xuyuanp";
      repo = "nerdtree-git-plugin";
      rev = "4524fb465b11881409482636ae716b4965011550";
      sha256 = "0cvb33drkv3rrgbniw9bz8xkxyr4cf0lyay9waw3lczpl2wmfwbm";
    };
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2021-05-23";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "ab94420372ae29d97072051914e85be6a94e6736";
      sha256 = "14kh31dvicdx69fggx2namgbfx8ba3g9f102ncdgla4ps3kgwrb3";
    };
  };

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2021-03-29";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "e847eccc7d1f39ea660a20743cd87c96156cbb6a";
      sha256 = "103rq17qxzvz8j1ncfkgpqc5cf52c2baqq95v3bqa22qy32kjxxi";
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
    version = "2021-04-26";
    src = fetchFromGitHub {
      owner = "vim-ctrlspace";
      repo = "vim-ctrlspace";
      rev = "357b337a3494aae8f9c2075a5c120467833d753d";
      sha256 = "1yjx79yj21dbf746mmw6y3mf9j20yar7vww1isyhi3a3pb4l7wsl";
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
    version = "2021-05-18";
    src = fetchFromGitHub {
      owner = "patstockwell";
      repo = "vim-monokai-tasty";
      rev = "12e02dc98d29bf2ce00522a27bbfebb99d2591ca";
      sha256 = "1y18rq4cildv9sbpi004icgilai9lmr526dsgmbkaiyj4a85gmp6";
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

  vim-solarized8 = buildVimPluginFrom2Nix {
    pname = "vim-solarized8";
    version = "2021-04-24";
    src = fetchFromGitHub {
      owner = "lifepillar";
      repo = "vim-solarized8";
      rev = "28b81a4263054f9584a98f94cca3e42815d44725";
      sha256 = "0vq0fxsdy0mk2zpbd1drrrxnbd44r39gqzp0s71vh9q4bnww7jds";
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
