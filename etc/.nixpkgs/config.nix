{
  packageOverrides = pkgs:
  rec {

    homeEnv = pkgs.buildEnv {
      name = "homeEnv";
      paths = [ pkgs.emacs24 pkgs.bsdgames ];
    };

    workEnv = pkgs.buildEnv {
      name = "workEnv";
      paths = [ pkgs.perl ];
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

    mpl = pkgs.buildEnv {
      name = "mpl";
      paths = with pkgs; [
          (python27Full.override {
            extraLibs = [
#              python27Packages.needsmpl
              python27Packages.ipython
            ];
          })
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
        postgresql openldap libjpeg

        nodePackages.jshint

#        python27Packages.jinja2
        vimHugeX
        lessc  # searx

        python27Packages.pyflakes
        python27Packages.pep8
        python27Packages.pillow

        python27Packages.dbus
      ];
      pathsToLink = [ "/" ];
      ignoreCollisions = true;
    };

    # ruby environment
    rubyenv = pkgs.buildEnv {
      name = "rubyenv";
      paths = with pkgs; [
        stdenv
        git
        ruby
        rubygems
        rubyLibs.nix
        nix

        rubyLibs.heroku rubyLibs.rb_readline
        rubyLibs.travis
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
        stdenv git nix
        nodejs
        python
        utillinux
        (with nodePackages; [ bower grunt-cli node-inspector ])
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
}
