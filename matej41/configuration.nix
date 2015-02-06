# Edit this configuration file to define what should be installed on
# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:
let

  trackpoint_scroll = pkgs.writeScript "trackpoint-scroll.sh" ''
    # To enable vertical scrolling
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
    # To enable horizontal scrolling in addition to vertical scrolling
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # To enable middle button emulation (using left- and right-click simultaneously)
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Middle Button Emulation" 1
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Middle Button Timeout" 50
  '';

  nixmy = pkgs.writeScript "nixmy.sh" ''
    #!/usr/bin/env bash
    source /home/matej/workarea/nixmy/nixmy.sh
    export PATH="${nixmy_env}/bin:$PATH"
    $@
  '';

  nixmy_env = pkgs.writeScriptBin "nix-env" ''
    #!/usr/bin/env bash
    source /home/matej/workarea/nixmy/nixmy.sh
    ${config.nix.package}/bin/nix-env -f "$NIX_MY_PKGS" $@
  '';


  applist = [
    {mimetypes = ["text/plain" "text/css"]; exec = "${pkgs.sublime3}/bin/sublime";}
    {mimetypes = ["text/html"]; exec = "${pkgs.firefox}/bin/firefox";}
    {mimetypes = ["inode/directory"]; exec = "/run/current-system/sw/bin/enlightenment_filemanager";}
    {mimetypes = ["x-scheme-handler/http" "x-scheme-handler/https"]; exec = "/run/current-system/sw/bin/firefox";}
  ];

in {
  require =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #/home/matej/workarea/rails-nixos-fullstack/deploy/service.nix
    ];

#  hardware.firmware = [ pkgs.radeonR700 pkgs.radeonR600 ];
#  hardware.firmware = [ pkgs.radeonARUBA pkgs.radeonR600 pkgs.radeonR700 ];
  #hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

#  hardware.opengl.videoDrivers = [ "intel" ];

  hardware.pulseaudio.enable = false;

  boot = {
    initrd = {
      kernelModules = [ "dm-crypt" "ext4" "ecb" "tun" ];  # "radeon" "wl"
      luks = {
        devices = [ {
          name = "lvm_pool1";
          device = "/dev/sda2";
          allowDiscards = true;
          } ];
      };
    };
    kernelPackages = pkgs.linuxPackages_3_17;
    blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
#    extraModprobeConfig = ''
#      options sdhci debug_quirks=0x4670
#      options thinkpad_acpi fan_control=1
#      options radeon agpmode=-1
#      options radeon modeset=0
#      options snd_hda_intel index=0
#    '';

    # grub 2 can boot from lvm, not sure whether version 2 is default
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    # major:minor number of my swap device, fully lvm-based system
    #resumeDevice = "254:1";
  };

  networking = {
    #wireless.enable = false;
    #wireless.driver = "wl";
    #wireless.interfaces = [ "wlp3s0" ];
    #wireless.userControlled.enable = true;
    networkmanager.enable = false;
    connman.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 55555 ];
      allowedUDPPorts = [ 55555 ];
      enable = true;
      allowPing = true;
    };
    #interfaceMonitor.enable = false; # Watch for plugged cable.
    hostName = "matej41"; # Define your hostname.
    #interfaces.enp1s0 = {
    #  ipAddress = "192.168.111.11";
    #  prefixLength = 24;
    #};
    #defaultGateway = "192.168.111.10";
    #nameservers = [ "192.168.111.10" ];
    #enableIPv6 = false;

#    extraHosts = ''
#      blog.matejc.com matejc.github.io
#    '';

    #bridges.br0.interfaces = [ "enp0s25" "wlp3s0" ];
  };

  #powerManagement.enable = true;
#  powerManagement.resumeCommands = ''
#    /run/current-system/sw/bin/sh -c "/run/current-system/sw/bin/date > /home/matej/tmp/RESUMECOMMANDS"
#    /run/current-system/sw/bin/sh -c "/run/current-system/sw/bin/sleep 5; /run/current-system/sw/bin/date > /home/matej/tmp/LOCKMATEJ; /home/matej/sync/bin/thissession /home/matej/sync/bin/i3lock-wrapper" &
#  '';
#    /run/current-system/sw/bin/systemctl stop connman

#  powerManagement.resumeCommands = ''
#  powerManagement.powerUpCommands = ''
#    /run/current-system/sw/bin/sleep 5 ; /home/matej/sync/bin/thissession /home/matej/sync/bin/i3lock-wrapper
#  '';
#  powerManagement.powerUpCommands = "/run/current-system/sw/sbin/modprobe -r wl ; /run/current-system/sw/sbin/modprobe wl";
  #powerManagement.aggressive = true;

  programs.ssh.forwardX11 = false;

  security.sudo.enable = true;
  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
  ];

  # Add file system entries for each partition that you want to see mounted
  # at boot time. You can add filesystems which are not mounted at boot by
  # adding the noauto option.
  fileSystems = [
    # Mount the root file system
    #
    { mountPoint = "/";
      device = "/dev/vg_pool1/lv_root";
    } {
      mountPoint = "/boot";
      device = "/dev/sda1";
    }
    { mountPoint = "/home";
      device = "/dev/vg_pool1/lv_home";
    }

    # Copy & Paste & Uncomment & Modify to add any other file system.
    #
    # { mountPoint = "/data"; # where you want to mount the device
    # device = "/dev/sdb"; # the device or the label of the device
    # # label = "data";
    # fsType = "ext3"; # the type of the partition.
    # options = "data=journal";
    # }
    { mountPoint = "/tmp";
      device = "tmpfs";
      fsType = "tmpfs";
      options = "nosuid,nodev,relatime,size=10G";
    }
  ];

  # List swap partitions activated at boot time.
  swapDevices =
    [ { device = "/dev/vg_pool1/lv_swap"; }
    ];

#  fonts = {
#    enableFontDir = true;
#    enableGhostscriptFonts = true;
#    extraFonts = [
#       pkgs.anonymousPro
#       pkgs.arkpandora_ttf
#       pkgs.bakoma_ttf
#       pkgs.cantarell_fonts
#       pkgs.corefonts
#       pkgs.clearlyU
#       pkgs.cm_unicode
#       pkgs.freefont_ttf
#       pkgs.gentium
#       pkgs.inconsolata
#       pkgs.liberation_ttf
#       pkgs.libertine
#       pkgs.lmodern
#       pkgs.mph_2b_damase
#       pkgs.oldstandard
#       pkgs.theano
#       pkgs.tempora_lgc
#       pkgs.terminus_font
#       pkgs.ttf_bitstream_vera
#       pkgs.ucsFonts
#       pkgs.unifont
#       pkgs.vistafonts
#    ];
#  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_GB.utf8";
  };

  users.extraUsers = {
    matej = {
      uid = 499;
      createHome = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "vboxusers" ];
      group = "users";
      home = "/home/matej";
      shell = "/run/current-system/sw/bin/zsh";
    };
  };

  services = {
    # List services that you want to enable:
/*

    #mpd.enable = true;
    #mpd.network.host = ''"/var/lib/mpd/socket"'';

    #httpd = {
    #  enable = true;
    #  adminAddr = "cotman.matej@gmail.com";
    #  port = 11111;
    #  extraSubservices =
    #    [ {
    #      serviceType = "owncloud";
    #      dbServer = "localhost:/tmp/.s.PGSQL.5432";
    #      dbPassword = "<password>";
    #      adminUser = "admin";
    #      adminPassword = "admin";
    #      libreofficePath = "${pkgs.libreoffice}/bin/libreoffice";
    #      overwriteHost = "";
    #      overwriteProtocol = "";
    #    } ];
    #};

    postgresql.enable = false;
    postgresql.package = pkgs.postgresql92;
    postgresql.authentication = ''
      local owncloud all trust
      local all all trust
    '';

    tiddly.enable = true;

    tiddlywiki.enable = true;
    tiddlywiki.port = 8888;
    tiddlywiki.username = "matejc";
    tiddlywiki.password = "<haha>";
*/
    locate.enable = true;
    nixosManual.showManual = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    openssh.permitRootLogin = "no";

    # Enable CUPS to print documents.
    printing.enable = true;

    printing.drivers = [ pkgs.hplip pkgs.gutenprint pkgs.foomatic_filters ];

    #acpid.lidEventCommands = ''
    #  /run/current-system/sw/bin/echo "lidEventCommands" >> /tmp/lidEventCommands.log
    #'';

    # Enable the X11 windowing system.
    xserver = {
      defaultApps = applist;
      vaapiDrivers = [ pkgs.vaapiIntel ];
      videoDrivers = [ "intel" ];
#      virtualScreen = { x = 3286; y = 1080; };
#      screenSection = ''
#DefaultDepth    24
#SubSection "Display"
#    Virtual 3286 1080
#EndSubSection
#      '';
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      autorun = true;
      exportConfiguration = true;
      desktopManager.xfce.enable = false;
      desktopManager.e19.enable = true;
      desktopManager.kde5.enable = true;
      desktopManager.gnome3.enable = false;
      desktopManager.default = "E19";
      displayManager.slim.enable = true;
      displayManager.lightdm.enable = false;
      displayManager.kdm.enable = false;
      displayManager.desktopManagerHandlesLidAndPower = false;
      synaptics = {
        enable = true;
        twoFingerScroll = true;
        maxSpeed = "0.95";
        tapButtons = false;
      };
    };

    #syncthing.enable = false;
    #syncthing.user = "matej";
    #syncthing.dataDir = "/home/matej";

    btsync = {
      enable = true;
      checkForUpdates = false;
      deviceName = "matej41";
      enableWebUI = true;
      httpListenAddr = "127.0.0.1";
      httpListenPort = 9000;
      httpLogin = "matej";
      httpPass = "<password>";
      listeningPort = 55555;
    };

    #searx.enable = true;
    #searx.configFile = "/var/lib/searx/.searx.yml";

    #seeks.enable = true;
    #seeks.confDir = "/var/lib/seeks/etc/seeks";

    #elasticsearch.enable = true;

    #nixui.enable = true;
    #nixui.user = "matej";
    #nixui.dataDir = "/home/matej/.nixui";

    #mailpile.enable = true;

    openvpn.servers = {
      matejc = {
        autoStart = false;
        config = ''
client
dev tun
proto udp
nobind
remote 88.198.109.162 1194
ca /home/matej/workarea/ov/matejc/demoCA/cacert.pem
cert /home/matej/workarea/ov/matejc/matej.crt
key /home/matej/workarea/ov/matejc/matej.key
dh /home/matej/workarea/ov/matejc/dh2048.pem
comp-lzo
verb 5
keepalive 10 60
explicit-exit-notify 2
tls-auth /home/matej/workarea/ov/matejc/ta.key 1
tls-remote "matejc.scriptores.com"
        '';
      };
    };

    #cron.enable = true;
    #cron.systemCronJobs = [
    #  "@reboot  matej  /run/current-system/sw/bin/supervisord -c /home/matej/.supervisord.conf"
    #];

    cron.enable = true;
    cron.systemCronJobs = [
      "@reboot  root  ${pkgs.bindfs}/bin/bindfs -u matej /var/lib/btsync/sync /home/matej/sync"
    ];

    dbus.enable = true;
    dbus.packages = [ pkgs.gnome3.dconf ];

    virtualboxHost.enable = true;
  };

  time.timeZone = "Europe/Ljubljana";
  environment = {
    interactiveShellInit = ''
        export PATH=$HOME/bin:$HOME/sync/bin:$PATH
        export EDITOR="vim"
        export EMAIL=cotman.matej@gmail.com
        export FULLNAME="Matej Cotman"
        export PIP_DOWNLOAD_CACHE=$HOME/.pip_download_cache
    '';
    pathsToLink = [ "/" ];
    systemPackages = with pkgs; [
      file
      gnupg
      gnupg1
      nmap
      p7zip
      zip
      unzip
      htop
      powertop
      pwgen
      tmux
      stdmanpages
      telnet
      unrar unzip
      wget
      w3m
      bash zsh
      gitAndTools.gitFull
      gitAndTools.hub
      lsof
      stdenv
      xfontsel
      xlibs.xev
      xlibs.xmessage
      xlibs.xmodmap
      rxvt_unicode
      xsel

      vimHugeX
      ctags # used in vim
      # needed for vim's syntastic
      phantomjs
      pythonPackages.flake8
      pythonPackages.docutils
      htmlTidy
      csslint

      tree
      firefoxWrapper
      evince
      vlc
      mpv
      sublime3
      wgetpaste
      gparted
      unetbootin
      xautolock

      i3lock
      i3status
      scrot  # screenshots
      vifm  # file browser

      imagemagick

      python27Full
      pythonPackages.virtualenv
      pythonPackages.ipython
      pythonPackages.supervisor

      feh
      #gnome.GConf

      #pcmanfm
      atool

      openssl
      libnotify
      ccrypt
      bind
      psmisc
      upower
      pmutils
      virtmanager

      kde4.ark

      #gtk-engine-murrine

      e19.terminology e19.rage

      # texstudio texLiveFull
      zed nixui

      abiword

      cmst

      #xfce.terminal
      #torbrowser

      audacious
      bindfs

      nixopsUnstable

      chromium

      #libreoffice

      nox
      ncdu
    ];
  };

  sound.enable =  true;

  nixpkgs.config = {

    nixui.dataDir = "/home/matej/.nixui";
    nixui.NIX_PATH = "nixpkgs=/home/matej/workarea/nixpkgs:nixos=/home/matej/workarea/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix:services=/etc/nixos/services";

    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
      icedtea = true;
    };

    chromium = {
      #enableAdobeFlash = true;
      #enableGoogleTalkPlugin = true;
      #enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      #enablePepperPDF = true;
      enablePepperFlash = true;
      #enableWideVine = true;
      #hiDPISupport = true;
    };
    rxvt_unicode = {
      perlBindings = true;
    };

#packageOverrides = pkgs:
#{
#  ttf_bitstream_vera_for_powerline = pkgs.callPackage ./custom/ttf_bitstream_vera_for_powerline.nix { };
#};

  };

  # Fix dri and link fglrx_dri.so
#  system.activationScripts.drifix = ''
#      # Create the required /usr/lib/dri/fglrx_dri.so;
#      #mkdir -p /usr/lib/dri
#      #ln -fs /run/opengl-driver/lib/dri/fglrx_dri.so /usr/lib/dri/fglrx_dri.so
#      mkdir -p /lib/dri
#      ln -fs ${pkgs.mesa_drivers}/lib/dri/r600_dri.so /lib/dri/r600_dri.so
#      ln -fs ${pkgs.mesa_drivers}/lib/dri/swrast_dri.so /lib/dri/swrast_dri.so
#  '';

  system.activationScripts.matej_bin = ''
      mkdir -p /home/matej/bin
      ln -sf "${trackpoint_scroll}" "/home/matej/bin/trackpoint-scroll.sh"
      ln -sf "${nixmy}" "/home/matej/bin/nixmy-env"
  '';
  system.activationScripts.bin_lib_links = ''
      mkdir -p /usr/bin
      ln -fs /run/current-system/sw/bin/g++ /usr/bin/g++
      ln -fs /run/current-system/sw/bin/gcc /usr/bin/gcc
      ln -fs ${pkgs.bash}/bin/bash /bin/bash
      mkdir -p /usr/lib
      ln -fs ${pkgs.xlibs.libX11}/lib/libX11.so.6 /usr/lib/libX11.so.6
  '';
#  system.activationScripts.connman = ''
#    ln -fs ${pkgs.connman}/usr/share/dbus-1/system-services/connman.service /etc/static/systemd/system/connman.service
#    ln -fs ${pkgs.connman}/usr/share/dbus-1/system-services/connman-vpn.service /etc/static/systemd/system/connman-vpn.service
#    ln -fs ${pkgs.connman}/usr/share/dbus-1/system-services/net.connman.vpn.service /etc/static/systemd/system/net.connman.vpn.service
#  '';

#  systemd.packages = [ pkgs.connman ];
/*
  systemd.services."connman" = {
    description = "Connection service";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "net.connman";
      Restart = "on-failure";
      ExecStart = "${pkgs.connman}/sbin/connmand --nodaemon";
      StandardOutput = "null";
    };
  };


  systemd.services."connman-vpn" = {
    description = "ConnMan VPN service";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "net.connman.vpn";
      ExecStart = "${pkgs.connman}/sbin/connman-vpnd -n";
      StandardOutput = "null";
    };
  };

  systemd.services."net-connman-vpn" = {
    description = "D-BUS Service";
    serviceConfig = {
      Name = "net.connman.vpn";
      ExecStart = "${pkgs.connman}/sbin/connman-vpnd -n";
      User = "root";
      SystemdService = "connman-vpn.service";
    };
  };


    systemd.services."my-post-suspend" =
      { description = "Post-Suspend Actions";
        wantedBy = [ "suspend.target" ];
        after = [ "post-sleep.service" ];
        script =
          ''
            sleep 3 && systemctl restart docker
          '';
        serviceConfig.Type = "simple";
      };

  systemd.services.docker.preStart = "${pkgs.nettools}/bin/ifconfig docker0 down && ${pkgs.bridge_utils}/sbin/brctl delbr docker0 || true";
*/

  nix.trustedBinaryCaches = [
    "https://hydra.nixos.org/"
    "https://cache.nixos.org/"
  ];

  nix.binaryCaches = [
    "https://hydra.nixos.org/"
    "https://cache.nixos.org/"
  ];

   virtualisation.docker.enable = false;
   virtualisation.docker.socketActivation = false;
   virtualisation.docker.extraOptions = ''
   --ip=127.0.0.1 --dns=8.8.8.8
   '';

    systemd.services.keylogger = {
      description = "keylogger";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.logkeys}/bin/logkeys -s";
        ExecStop = "${pkgs.logkeys}/bin/logkeys -k";
        Type = "forking";
      };
    };

  #virtualisation.libvirtd = {
  #  enable = true;
  #  enableKVM = true;
  #};

}
