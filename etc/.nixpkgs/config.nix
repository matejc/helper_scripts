{
  packageOverrides = pkgs:
  rec {

    dockerenv = pkgs.buildEnv {
      name = "dockerenv";
      paths = [ pkgs.bashInteractive pkgs.docker pkgs.which ];
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
        stdenv.cc gnumake bashInteractive curl nix
        busybox
        cyrus_sasl
        db4
        file
        gitAndTools.gitFull
        groff
        jdk
        libxml2
        libxslt
        mercurial
        openssh
        openssl
        pcre
        pkgconfig
        postgresql
        pycrypto
        python27Full
#        python27Packages.ipython
        python27Packages.pyyaml
#        python27Packages.readline
#        python27Packages.sqlite3
        python27Packages.virtualenv
        subversionClient
        stdenv
        wget
        zlib
        w3m
        poppler
#        rubyLibs.docsplit
#        python27Packages.ipdb
#        docutils
#        python27Packages.pygments
        vimprobable2
#        python27Packages.cssselect
        gettext
        python27Packages.libarchive
#        python27.modules.curses
        rsync
        python27Packages.setuptools
        nano
        python27Packages.pysqlite

        youtubeDL ffmpeg
        postgresql openldap libjpeg optipng

        nodePackages.jshint

#        python27Packages.jinja2
        vimHugeX
        lessc  # searx

        python27Packages.pyflakes
        python27Packages.pep8
        python27Packages.pillow
        python27Packages.wxPython

        which
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
        stdenv gcc busybox gnumake
        git
        ruby
        rubygems
        #rubyLibs.nix
        nix

        #bundler2nix
        gnused coreutils

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
        stdenv.cc git nix gnumake unzip which coreutils gnused gnugrep bashInteractive ruby
        nodejs
        python
        utillinux
        node_webkit
        xdg_utils
        graphicsmagick
        imagemagick
        youtube-dl mplayer psmisc ffmpeg vlc
        gnutar bzip2
        (with nodePackages; [ grunt-cli node-inspector npm2nix bower ])
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
        (with goPackages; [ ])
      ];
      ignoreCollisions = true;
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

  };
#  st.conf = builtins.readFile ./.st.conf;
  allowUnfree = true;
  mpv.vaapiSupport = true;
  nixui.dataDir = "/home/matej/.nixui";
  nixui.NIX_PATH = "nixpkgs=/home/matej/workarea/nixpkgs:nixos=/home/matej/workarea/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix:services=/etc/nixos/services";
}
