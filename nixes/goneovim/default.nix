{ buildGoPackage, fetchFromGitHub, go, libsForQt514, buildEnv
, lib, callPackage, libglvnd }:

/*
$ export GOPATH=$(pwd)
$ mkdir -p $GOPATH/src/github.com/akiyosi/goneovim
$ cd $GOPATH/src/github.com/akiyosi/goneovim
$ dep init
$ dep2nix
*/
let

  qtcmds = buildGoPackage {
    pname = "qt";
    version = "20200904";

    goPackagePath = "github.com/therecipe/qt";
    subPackages = [ "cmd/qtmoc" "cmd/qtdeploy" "cmd/qtsetup" ];

    src = fetchFromGitHub {
      owner = "therecipe";
      repo = "qt";
      rev = "c0c124a5770d357908f16fa57e0aa0ec6ccd3f91";
      sha256 = "197wdh2v0g5g2dpb1gcd5gp0g4wqzip34cawisvy6z7mygmsc8rd";
    };

    goDeps = ./qt-deps.nix;
  };

  libsForQt5 = libsForQt514;

  qtVersion = libsForQt5.qt5.qtbase.version;
  qtEnv = callPackage <nixpkgs/pkgs/development/libraries/qt-5/qt-env.nix> {
    qtbase = libsForQt5.qt5.qtbase;
  };
  qt = qtEnv "qt-${qtVersion}" (with libsForQt5; [
    qt5.qtvirtualkeyboard qt5.qtxmlpatterns
    qt5.qtwebsockets qt5.qtwebview
    qt5.qtsensors qt5.qtremoteobjects
    qt5.qtscxml qt5.qtbase
    qt5.qtdeclarative
    qt5.qt3d
    qt5.qtpurchasing qt5.qtlocation
    qt5.qtconnectivity qt5.qtcharts
    qt5.qtdatavis3d qt5.qtlottie
    qt5.qtspeech qt5.qtserialport
    fcitx5-qt fcitx-qt5
    qt5.qtserialbus qt5.qttools
    qt5.qtmultimedia qt5.qtsvg
    qt5.qtwebchannel
    qt5.qtwebengine qt5.qtscript qt5.qtgamepad qt5.qtquickcontrols2
  ]);

  deps = buildEnv {
    name = "deps";
    paths = map lib.getDev [
      libglvnd
    ];
  };

in
buildGoPackage rec {
  pname = "goneovim";
  version = "0.4.10";

  goPackagePath = "github.com/akiyosi/goneovim";
  subPackages = [ "cmd/goneovim" ];

  src = fetchFromGitHub {
    owner = "akiyosi";
    repo = "goneovim";
    rev = "v${version}";
    sha256 = "1m9kacinw5rl6fkrqjdp7iz05ci2jwgjkwkbqpw0a90y44phhv5c";
  };

  buildPhase = ''
    mkdir -p $TMPDIR/qt/${qtVersion}/gcc_64/
    ln -s ${qt}/* $TMPDIR/qt/${qtVersion}/gcc_64/
    export QT_API=5.13.0
    export QT_VERSION=${qtVersion}
    export QT_DIR=$TMPDIR/qt
    export GO111MODULE=off
    export GOCACHE=$TMPDIR/go-cache
    export GOROOT=${go}/share/go
    export NIX_CFLAGS_COMPILE="-I${deps}/include"

    ${qtcmds}/bin/qtsetup -test=false

    cd ./go/src/github.com/akiyosi/goneovim
    ${qtcmds}/bin/qtmoc

    cd ./cmd/goneovim
    ${qtcmds}/bin/qtdeploy build desktop
  '';

  goDeps = ./deps.nix;
}
