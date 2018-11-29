{
  packageOverrides = pkgs:
  rec {

    myNeovim = pkgs.neovim.override {
      configure = {
        customRC = ''
          let mapleader=","
          syntax enable
          set termguicolors
          colorscheme monokai_pro

          set shell=sh

          filetype plugin on
          if has ("autocmd")
            filetype plugin indent on
          endif

          set clipboard=unnamedplus

          set number
          set mouse=a

          set colorcolumn=80

          function TrimEndLines()
            let save_cursor = getpos(".")
            :silent! %s#\($\n\s*\)\+\%$##
            call setpos('.', save_cursor)
          endfunction

          if &binary == 0
            au BufWritePre <buffer> call TrimEndLines()
          endif
          set fixendofline

          autocmd FileType markdown set spell spelllang=en_us

          let g:NERDTreeDirArrowExpandable = '▸'
          let g:NERDTreeDirArrowCollapsible = '▾'

          autocmd StdinReadPre * let s:std_in=1
          autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
          map <C-\> :NERDTreeToggle<CR>

          let g:ctrlp_cmd = 'CtrlPMixed'

          let g:airline#extensions#tabline#enabled = 1
          let g:airline_powerline_fonts = 1
          let g:airline_theme='base16_monokai'

          " Add spaces after comment delimiters by default
          let g:NERDSpaceDelims = 1

          " Use compact syntax for prettified multi-line comments
          let g:NERDCompactSexyComs = 1

          " Align line-wise comment delimiters flush left instead of following code indentation
          let g:NERDDefaultAlign = 'left'

          " Allow commenting and inverting empty lines (useful when commenting a region)
          let g:NERDCommentEmptyLines = 0

          " Enable trimming of trailing whitespace when uncommenting
          let g:NERDTrimTrailingWhitespace = 1

          " Enable NERDCommenterToggle to check all selected lines is commented or not
          let g:NERDToggleCheckAllLines = 1

          let g:better_whitespace_enabled=1
          let g:strip_whitespace_on_save=1

          set cursorline

          if has("persistent_undo")
            set undodir=~/.undodir/
            set undofile
          endif

          set ai
          set smartindent
          set copyindent
          set tabstop=4 shiftwidth=4 expandtab softtabstop=4

          let loaded_matchit = 1

          let g:deoplete#enable_at_startup = 1

          nmap <PageUp> 10<up>
          imap <PageUp> <esc>10<up>i
          nmap <PageDown> 10<down>
          imap <PageDown> <esc>10<down>i

          nmap <C-s> :w<CR>
          imap <C-s> <esc>:w<cr>li

          map <C-z> u
          map! <C-z> <esc>u
          map <C-y> <C-R>
          map! <C-y> <esc><C-R>

          nmap <C-k> "_dd
          imap <C-k> <esc>"_ddi
          vmap <C-k> "_d

          nmap <C-x> dd
          imap <C-x> <esc>ddi
          vmap <C-x> d

          map <C-q> <ESC>:qall<Return>
          map! <C-q> <ESC>:qall<Return>

          map <C-w> <ESC>:bd<Return>
          map! <C-w> <ESC>:bd<Return>

          map <A-d> Yp
          map <C-d> Yp
          imap <A-d> <esc>Ypi
          imap <C-d> <esc>Ypi

          map <C-u> <esc>:UndotreeToggle<CR>

          map <S-PageUp> :bprev<Return>
          map! <S-PageUp> <esc>:bprev<Return>
          map <S-PageDown> :bnext<Return>
          map! <S-PageDown> <esc>:bnext<Return>

          imap <C-p> <esc>:CtrlPMixed<Return>

          vmap <Tab> >gv
          vmap <S-Tab> <gv
          imap <S-Tab> <esc>v<i
          nmap <Tab> v><esc>
          nmap <S-Tab> v<<esc>

          nmap <S-Up> :m-2<CR>
          imap <S-Up> <Esc>:m-2<CR>i
          nmap <S-Down> :m+<CR>
          imap <S-Down> <Esc>:m+<CR>i

          imap <A-b> <esc>mzgg=G`zi
          map <A-b> mzgg=G`z

          autocmd FileType javascript map <buffer> <C-b> :call JsBeautify()<cr>
          autocmd FileType javascript imap <buffer> <C-b> <esc>:call JsBeautify()<cr>i

          nmap <A-/> <leader>c<space>j
          imap <A-/> <esc><leader>c<space>ji

          nmap <A-m> %
          imap <A-m> <esc>%i
          vmap <A-m> %

          imap <A-Right> <S-Right>
          nmap <A-Right> <S-Right>
          vmap <A-Right> <S-Right>
          imap <A-Left> <S-Left>
          nmap <A-Left> <S-Left>
          vmap <A-Left> <S-Left>

          imap <C-Right> <S-Right>
          nmap <C-Right> <S-Right>
          vmap <C-Right> <S-Right>
          imap <C-Left> <S-Left>
          nmap <C-Left> <S-Left>
          vmap <C-Left> <S-Left>

          nmap <A-BS> ld<S-Left>
          imap <A-BS> <esc>ld<S-Left>i
          nmap <A-Delete> d<S-Right>
          imap <A-Delete> <esc>d<S-Right>i

          imap <CR> <CR>
          nmap <CR> o

          nmap <C-g> :Gitv<cr>
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          # see examples below how to use custom packages
          start = [ vim-monokai-pro ale vim-nix The_NERD_tree surround
          ctrlp vim-airline vim-airline-themes The_NERD_Commenter
          vim-better-whitespace vim-expand-region undotree multiple-cursors
          vim-jsbeautify nerdtree-git-plugin deoplete-nvim deoplete-jedi
          deoplete-ternjs deoplete-go vim-signify fugitive gitv ];
          opt = [ ];
        };
      };
    };

    mypidgin = (pkgs.pidgin.override {
      plugins = with pkgs; [ purple-matrix pidginotr telegram-purple purple-facebook ];
    });

    dockerenv = pkgs.buildEnv {
      name = "dockerenv";
      paths = [ pkgs.bashInteractive pkgs.docker pkgs.which
      pkgs.docker_compose ];
    };

    py3env = pkgs.buildEnv {
      name = "py3env";
      paths = with pkgs; [
        python3
        python3Packages.virtualenv
        python3Packages.pydbus
        python3Packages.pygobject3
        python3Packages.tkinter
        pypi2nix
        gcc
      ];
    };

    atomenv = pkgs.buildEnv {
      name = "atomenv";
      paths = with pkgs; [
        python3
        python3Packages.pylama
        python3Packages.pep8
        python3Packages.pep257
        python3Packages.mccabe
        python3Packages.pyflakes

        python3Packages.pycodestyle
        python3Packages.isort
      ];
    };

    homeEnv = pkgs.buildEnv {
      name = "homeEnv";
      paths = [ pkgs.emacs24 pkgs.bsdgames ];
    };

    workEnv = pkgs.buildEnv {
      name = "workEnv";
      paths = [ pkgs.perl ];
    };

    nixenv = pkgs.buildEnv {
      name = "nixenv";
      paths = [ pkgs.nixUnstable ];
    };

    texenv = pkgs.buildEnv {
      name = "texenv";
      paths = with pkgs; [
        texstudio
        texlive.combined.scheme-full
      ];
    };

    envPythonPlonedev = pkgs.buildEnv {
      name = "env-python-plonedev-1.0";
      paths = with pkgs; [
        cyrus_sasl
        db4
        gitAndTools.gitFull
        groff
        libxml2
        libxslt
        openssh
        openssl
        python27Full
        python27Packages.ipython
        subversionClient
        stdenv
      ];
    };

    # we want ipython with custom modules!
    ipythonenv = pkgs.buildEnv {
      name = "ipythonenv";
      paths = with pkgs; [
        python27Packages.ipython
      ];
    };


    # we want virtualenv with custom modules!
    venv = pkgs.buildEnv {
      name = "venv";
      paths = with pkgs; [
        python27Packages.virtualenv
      ];
    };

    aerofs = pkgs.buildEnv {
      name = "aerofs";
      paths = with pkgs; [
        coreutils
        #oraclejre7
        procps
        which
        openssl
        stdenv
      ];
    };
    lxcenv = pkgs.buildEnv {
      name = "lxcenv";
      paths = with pkgs; [
        debootstrap
        lxc
        coreutils
        which
        utillinux
        gnused
        rsync
      ];
      ignoreCollisions = true;
    };

    py27 = pkgs.buildEnv {
      name = "py27";
      paths = with pkgs; [
        # stdenv.cc gnumake bashInteractive
        # busybox
        cyrus_sasl
        db4
        file
        # gitAndTools.gitFull
        groff
        #jdk
        libxml2
        libxslt
        #mercurial
        openssh
        openssl
        pkgconfig
        #postgresql
        (python27Full.withPackages (ps: with ps; [ urllib3 ]))
        python27Packages.pyyaml
        python27Packages.virtualenv
        subversionClient
        # stdenv
        # wget
        zlib
        #w3m
        # poppler
        # vimprobable2
        gettext
        # python27Packages.libarchive
        # rsync
        python27Packages.setuptools
        # nano
        python27Packages.pysqlite

        # youtubeDL ffmpeg
        # postgresql openldap libjpeg optipng

        #nodePackages.jshint

        #vimHugeX
        # lessc  # searx
        # libffi  # searx

        # python27Packages.pyopenssl
        # python27Packages.ndg-httpsclient
        # python27Packages.pyasn1

        # python27Packages.pyflakes
        python27Packages.pep8
        # python27Packages.pillow
        # python27Packages.wxPython

        # which

        #python27Packages.pyudev

        # for robottests
        #phantomjs2-bin
        python27Packages.pyperclip
        python27Packages.requests

        /*opencv pkgconfig imagemagick python27Packages.wand python27Packages.numpy
        python27Packages.flask python27Packages.sqlite3 python27Packages.werkzeug
        python27Packages.jinja2 python27Packages.markupsafe python27Packages.itsdangerous
        strace python27Packages.opencv*/

        pypi2nix gcc.cc gcc.cc.lib

        libpulseaudio libusb1

        (ansible.overrideDerivation (oldDrv: { propagatedBuildInputs = with python27Packages; [ urllib3 idna chardet certifi dopy ] ++ oldDrv.propagatedBuildInputs;}))
      ];
      pathsToLink = [ "/" ];
      ignoreCollisions = true;
    };

    wwwenv = pkgs.buildEnv {
      name = "wwwenv";
      paths = with pkgs; [
        gitFull
        python27
      ];
      pathsToLink = [ "/" ];
      ignoreCollisions = true;
    };

    # ruby environment
    rubyenv = pkgs.buildEnv {
      name = "rubyenv";
      paths = with pkgs; [
        stdenv busybox
        git
        ruby
        #rubyLibs.nix
        nix

        bundler bundix
        jekyll
        gnumake stdenv.cc pkgconfig

        libxslt.dev

        #rubyLibs.heroku rubyLibs.rb_readline
        #rubyLibs.travis
        /* nodejs which python2 pythonPackages.pygments */
      ];
      ignoreCollisions = true;
    };

    ruby2env = pkgs.buildEnv {
      name = "ruby2env";
      paths = with pkgs; [
        stdenv gnumake coreutils strace
        git
        ruby bundler libffi.dev stdenv.cc gnugrep gawk pkgconfig libxml2.dev libxslt.dev zlib zlib.dev
        readline
        gnused
        nodejs
        nix-prefetch-scripts
      ];
      ignoreCollisions = true;
    };

    makeenv = pkgs.buildEnv {
      name = "makeenv";
      paths = with pkgs; [
        stdenv gnumake coreutils strace
        git
        pkgconfig
        autoconf
        intltool
        automake
        bash
        gnome3.gnome_common
        which
        gnused
        gnugrep
        autoconf-archive
        gettext
        gawk
        perl perlPackages.XMLParser
      ];
      ignoreCollisions = true;
    };

    # for robot tests
    robotenv = pkgs.buildEnv {
      name = "robotenv";
      paths = with pkgs; [
        python27Full
        xorg.xorgserver
        xorg.libXfont
        firefoxWrapper
        xlibs.libX11
        stdenv
        tightvnc
        git
      ];
    };

    nodeenv = pkgs.buildEnv {
      name = "nodeenv";
      paths = with pkgs; [
        stdenv.cc git nix gnumake unzip which bashInteractive ruby busybox
        nodejs-9_x
        #(yarn.override { nodejs = nodejs-8_x; })
        (npm2nix.override { nodejs = nodejs-9_x; })
        #((import /home/matejc/workarea/yarn2nix { inherit pkgs; nodejs = nodejs-8_x; }).yarn2nix)
        python
        utillinux

        graphicsmagick
        imagemagick

        bzip2
        libpng nasm libtool autoconf automake
        libarchive
        busybox

        flow

        libpcap

        (with nodePackages; [ grunt-cli bower ])

        sqlite

        # electron libnotify

        # nwjs_0_21
      ];
      ignoreCollisions = true;
    };

    nodestableenv = pkgs.buildEnv {
      name = "nodestableenv";
      paths = with pkgs; [
        stdenv.cc git nix gnumake unzip which bashInteractive ruby busybox
        nodejs
        yarn
        python
        utillinux

        bzip2
        libpng nasm libtool autoconf automake
        libarchive
        busybox
      ];
      ignoreCollisions = true;
    };

    blackenv = pkgs.buildEnv {
      name = "blackenv";
      paths = with pkgs; [
        stdenv.cc git nix gnumake unzip which bashInteractive
        nodejs-5_x
        busybox
        python

        electron libnotify
        (with nodePackages; [ bower ])
      ];
      ignoreCollisions = true;
    };

    goenv = pkgs.buildEnv {
      name = "goenv";
      paths = with pkgs; [
        stdenv.cc
        go
        go2nix
        dep
        /*oniguruma*/
      ];
      ignoreCollisions = true;
    };

    gstenv = pkgs.buildEnv {
      name = "gstenv";
      paths = with pkgs; [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ];
    };

    test = pkgs.buildEnv {
      name = "test";
      paths = with pkgs; [
        #sqlite3
      ];
    };

    emptyenv = pkgs.buildEnv {
      name = "emptyenv";
      paths = with pkgs; [
        stdenv
        bash
        git
      ];
    };

    starenv = pkgs.buildEnv {
      name = "starenv";
      paths = with pkgs; [
        autoconf
        cyrus_sasl
        db4
        file
        ghostscript
        gitAndTools.gitFull
        groff
        jdk
        libtiff
        libxml2
        libxslt
        lynx
        mercurial
        openldap
        openssh
        openssl
        pcre
        #pdftk
        pkgconfig
        postgresql
        readline
        sqlite
        subversionClient
        stdenv
        tesseract
        wget
        xpdf
        zlib
      ];
    };

    androidenv = pkgs.buildEnv {
      name = "androidenv";
      paths = [
        # jdk strace gcc.cc.lib

        /* ((import <nixpkgs/pkgs/development/mobile/androidenv> {
        inherit pkgs;
        pkgs_i686 = pkgs.pkgsi686Linux;
        })) */

        pkgs.androidenv.platformTools

        /* ((import <nixpkgs/pkgs/development/mobile/androidenv> {
        inherit pkgs;
        pkgs_i686 = pkgs.pkgsi686Linux;
        }).androidsdk {
        platformVersions = [ ];
        abiVersions = [ ];
        useGoogleAPIs = false;
        }) */
      ];
    };

    javaenv = pkgs.buildEnv {
      name = "javaenv";
      paths = with pkgs; [
        stdenv
        bash
        git
        jdk strace gcc.cc.lib maven coreutils
      ];
    };

    restyenv = let
      openidc_src = pkgs.fetchurl {
        url = "https://github.com/zmartzone/lua-resty-openidc/archive/15a6110626bc355047e98ac48fcc9953eef034c3.tar.gz";
        name = "openidc.tar.gz";
        sha256 = "1v2ljjdv19bf1b0651hdbhm1q7hqp58smzjbd2avn84akf5gcv2b";
      };

      http_src = pkgs.fetchurl {
        url = "https://github.com/pintsized/lua-resty-http/archive/fe5c10a47cf40440845c140a5d29cd0e0cd0208f.tar.gz";
        name = "http.tar.gz";
        sha256 = "1zvahgyigs24cypnrxr6cmf5r7j9372c8a46j1fk6pri1c90z2s6";
      };

      session_src = pkgs.fetchurl {
        url = "https://github.com/bungle/lua-resty-session/archive/4429a06ffac1724a056fafa954c0394d437b261f.tar.gz";
        name = "session.tar.gz";
        sha256 = "0a9avrr3hyj8ibpm5c6ifrmnhfw727hm2v46rd0ldw237cljixgl";
      };

      jwt_src = pkgs.fetchurl {
        url = "https://github.com/cdbattags/lua-resty-jwt/archive/f17d7c6ed45d59beb9fbf3bd5f50e89ead395b98.tar.gz";
        name = "jwt.tar.gz";
        sha256 = "09z425namy84888a8ca5lsmyp4c3xkdg0i8yx682bg8c2mimkxgx";
      };

      hmac_src = pkgs.fetchurl {
        url = "https://github.com/jkeys089/lua-resty-hmac/archive/989f601acbe74dee71c1a48f3e140a427f2d03ae.tar.gz";
        name = "hmac.tar.gz";
        sha256 = "164ad4i4vxa8cmrm6vw2vdlsq4idg75cbl59imwg764s4l9ii79n";
      };

      openidc = pkgs.stdenv.mkDerivation {
        name = "openidc";
        srcs = [openidc_src http_src session_src jwt_src hmac_src];
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/lib/{openidc,http,session,jwt,hmac}/
          cp -r lua-resty-openidc-*/lib/resty $out/lib/openidc/
          cp -r lua-resty-http-*/lib/resty $out/lib/http/
          cp -r lua-resty-session-*/lib/resty $out/lib/session/
          cp -r lua-resty-jwt-*/lib/resty $out/lib/jwt/
          cp -r lua-resty-hmac-*/lib/resty $out/lib/hmac/
        '';
      };
    in pkgs.buildEnv {
      name = "restyenv";
      paths = [
        openidc
      ];
    };

  };
  allowUnfree = true;
  mpv.vaapiSupport = true;
  nixui.dataDir = "/home/matejc/.nixui";
  nixui.NIX_PATH = "nixpkgs=/home/matejc/workarea/nixpkgs:nixos=/home/matejc/workarea/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix:services=/etc/nixos/services";
  nixmy = {
    NIX_MY_PKGS = "/home/matejc/workarea/nixpkgs";
    NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/matejc";
    NIX_MY_GITHUB = "git://github.com/matejc/nixpkgs.git";
  };
}
