rec {
  packageOverrides = pkgs:
  rec {
    mypidgin = pkgs.pidgin-with-plugins.override {
      plugins = with pkgs; [
        pidgin-otr pidgin-opensteamworks pidgin-skypeweb pidgin-window-merge
        pidgin-xmpp-receipts purple-discord purple-hangouts purple-matrix
        telegram-purple toxprpl purple-facebook purple-xmpp-http-upload
        purple-slack
      ];
    };

    dockerenv = pkgs.buildEnv {
      name = "dockerenv";
      paths = [ pkgs.bashInteractive pkgs.docker pkgs.which
      pkgs.docker_compose ];
    };

    py3env = pkgs.buildEnv {
      name = "py3env";
      paths = with pkgs; [
        python3Full.out
        pypi2nix
        libxslt.dev libxml2.dev zlib

        chromedriver
        postgresql libmysqlclient
        scrot

        # required by opencv-python
        gcc.cc.lib
        glib.out
        xorg.libSM
        xorg.libICE
        xorg.libXext
        xorg.libXrender
        xorg.libX11

        chromium
        python3Packages.tox
        python3Packages.virtualenv

        python3Packages.tkinter
        python3Packages.pycairo
        python3Packages.pygobject2

        pkg-config
        cairo.dev
        xorg.libxcb.dev
        xorg.libX11.dev
        xorg.xorgproto
        glib.dev
        gobjectIntrospection.dev
        libffi.dev
        libglvnd

        python3Packages.robotframework

        (ansible.overrideDerivation (oldDrv: { propagatedBuildInputs = with python37Packages; [ urllib3 idna chardet certifi dopy ] ++ oldDrv.propagatedBuildInputs;}))
        python3Packages.pyyaml

        makeenv
      ];
      ignoreCollisions = true;
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
        pkg-config
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
        python2Packages.pep8
        # python27Packages.pillow
        # python27Packages.wxPython
        python2Packages.pylint

        # which

        #python27Packages.pyudev

        # for robottests
        #phantomjs2-bin
        python2Packages.pyperclip
        python2Packages.requests

        /*opencv pkgconfig imagemagick python27Packages.wand python27Packages.numpy
        python27Packages.flask python27Packages.sqlite3 python27Packages.werkzeug
        python27Packages.jinja2 python27Packages.markupsafe python27Packages.itsdangerous
        strace python27Packages.opencv*/

        pypi2nix gcc.cc gcc.cc.lib

        libpulseaudio libusb1

        (ansible.overrideDerivation (oldDrv: { propagatedBuildInputs = with python27Packages; [ urllib3 idna chardet certifi dopy ] ++ oldDrv.propagatedBuildInputs;}))

        makeenv
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

        bundler bundix
        rubyPackages.jekyll
        rubyPackages.jekyll-watch
        gnumake stdenv.cc pkg-config

        zlib.dev
        zlib

        libxslt.dev
        libxml2.dev

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
        ruby bundler libffi.dev stdenv.cc gnugrep gawk pkg-config libxml2.dev libxslt.dev zlib zlib.dev
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
        stdenv gnumake strace
        stdenv.cc
        git
        pkg-config
        autoconf
        intltool
        automake
        which
        gettext
        perl

        zlib.dev
        zlib.out
        pciutils
        stdenv.glibc.out

        ncurses
      ];
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
        xorg.libX11.dev
        # (npm2nix.override { nodejs = nodejs-9_x; })
        nodejs-10_x
        #(yarn.override { nodejs = nodejs-8_x; })
        nodePackages.node2nix
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

        sqlite sqlite.dev

        binutils

        # electron libnotify

        openjdk openapi-generator-cli python37Packages.yapf
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
        go
        go2nix
        dep
        dep2nix
        vgo2nix
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
        pkg-config
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

    aenv = pkgs.buildEnv {
      name = "aenv";
      paths = [
        # jdk strace gcc.cc.lib

        /* ((import <nixpkgs/pkgs/development/mobile/androidenv> {
        inherit pkgs;
        pkgs_i686 = pkgs.pkgsi686Linux;
        })) */

        pkgs.adb-sync

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

    monoenv = pkgs.buildEnv {
      name = "monoenv";
      paths = with pkgs; [
        mono msbuild dotnet-sdk
        lsb-release
        openssl_1_0_2.out openssl_1_0_2.dev
        gnome3.gtk gnome3.gtk.dev
        hicolor-icon-theme
        gsettings_desktop_schemas
        #androidenv.androidPkgs_9_0.androidsdk

        ((import <nixpkgs/pkgs/development/mobile/androidenv> {
          config = { android_sdk.accept_license = true; };
        }).composeAndroidPackages {
          platformVersions = [ "24" ];
          abiVersions = [ "armeabi-v7a" ];
        }).androidsdk
      ];
      ignoreCollisions = true;
    };

    nixmy-package = pkgs.callPackage /home/matejc/workarea/nixmy { config.nixpkgs.config.nixmy = nixmy; };
  };

  allowUnfree = true;
  mpv.vaapiSupport = true;
  nixui.dataDir = "/home/matejc/.nixui";
  nixui.NIX_PATH = "nixpkgs=/home/matejc/workarea/nixpkgs:nixos=/home/matejc/workarea/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix:services=/etc/nixos/services";
  nixmy = {
    NIX_MY_PKGS = "/home/matejc/workarea/nixpkgs";
    NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/matejc";
    NIX_MY_GITHUB = "git@github.com:matejc/nixpkgs.git";
    NIX_MY_BACKUP = "git@github.com:matejc/configurations.git";
  };
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    "openssl-1.0.2u"
    "p7zip-16.02"
  ];
}
