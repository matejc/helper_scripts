{
  packageOverrides = pkgs:
  rec {

    dockerenv = pkgs.buildEnv {
      name = "dockerenv";
      paths = [ pkgs.bashInteractive pkgs.docker pkgs.which
        pkgs.python27Packages.docker_compose ];
    };

    py3env = pkgs.buildEnv {
      name = "py3env";
      paths = with pkgs; [
        python3
        python3Packages.virtualenv
        gcc
        python3Packages.yapf
        python3Packages.pep8
        coreutils
        atom
        which
        nix
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

    envTex = pkgs.buildEnv {
      name = "mytex";
      paths = with pkgs; [
        (let myTexLive =
          pkgs.texLiveAggregationFun {
            paths =
              [ pkgs.texLive
                pkgs.texLiveCMSuper
                pkgs.texLiveExtra
                pkgs.texLiveBeamer ];
          };
         in myTexLive)
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
#        python27Packages.site
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
        pcre
        pkgconfig
        #postgresql
        python27Full
#        python27Packages.ipython
        python27Packages.pyyaml
#        python27Packages.readline
#        python27Packages.sqlite3
        python27Packages.virtualenv
        subversionClient
        # stdenv
        # wget
        zlib
        #w3m
        # poppler
#        rubyLibs.docsplit
#        python27Packages.ipdb
#        docutils
#        python27Packages.pygments
        # vimprobable2
#        python27Packages.cssselect
        gettext
        # python27Packages.libarchive
#        python27.modules.curses
        # rsync
        python27Packages.setuptools
        # nano
        python27Packages.pysqlite

        # youtubeDL ffmpeg
        # postgresql openldap libjpeg optipng

        #nodePackages.jshint

#        python27Packages.jinja2
        #vimHugeX
        # lessc  # searx
        # libffi  # searx

        # python27Packages.pyopenssl
        # python27Packages.ndg-httpsclient
        # python27Packages.pyasn1

        # python27Packages.pyflakes
        # python27Packages.pep8
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

        pypi2nix gcc.cc libarchive gcc.cc.lib python27Packages.libarchive
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
        rubygems
        #rubyLibs.nix
        nix

        bundler bundix gnumake stdenv.cc

        #rubyLibs.heroku rubyLibs.rb_readline
        #rubyLibs.travis
        nodejs which python2 pythonPackages.pygments
      ];
      ignoreCollisions = true;
    };

    ruby2env = pkgs.buildEnv {
      name = "ruby2env";
      paths = with pkgs; [
        stdenv busybox gnumake
        nix
        git
        ruby_2_1
        readline
        gnused
        nodejs
        bundix nix-prefetch-scripts
        jekyll
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
        nodejs-6_x
        python
        utillinux
        # node_webkit_0_11
        xdg_utils
        graphicsmagick
        imagemagick
        youtube-dl mplayer psmisc ffmpeg vlc
        bzip2
        libpng nasm libtool autoconf automake
        libarchive
        busybox

        # selenium
        # phantomjs2-bin
        # selenium-server-standalone

        openssh

        flow

        graphviz-nox

        #electron libnotify

        libpcap

        (with nodePackages; [ grunt-cli npm2nix bower ])

        electron libnotify

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
        stdenv.cc git nix gnumake unzip which coreutils gnused gnugrep bashInteractive
        utillinux
        gnutar bzip2
        go
        go2nix
        findutils
        gawk

        git
        nix-prefetch-scripts
        pkgconfig
        oniguruma

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
      paths = with pkgs; [
        stdenv
        bash
        git
        jdk strace gcc.cc.lib

        ((import <nixpkgs/pkgs/development/mobile/androidenv> {
          inherit pkgs;
          pkgs_i686 = pkgs.pkgsi686Linux;
        }).androidsdk {
          /*platformVersions = [ "24" ];*/
          platformVersions = [ ];
          /*abiVersions = [ "x86" "x86_64"];*/
          abiVersions = [ ];
          useGoogleAPIs = false;
        })
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

  };
#  st.conf = builtins.readFile ./.st.conf;
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
