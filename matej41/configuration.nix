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

  applist = [
    {mimetypes = ["text/plain" "text/css"]; applicationExec = "${pkgs.sublime3}/bin/sublime";}
    {mimetypes = ["text/html"]; applicationExec = "${pkgs.firefox}/bin/firefox";}
  ];

  xdg_default_apps = import /home/matej/workarea/helper_scripts/nixes/defaultapps.nix { inherit pkgs; inherit applist; };

in {
  require =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

#  hardware.firmware = [ pkgs.radeonR700 pkgs.radeonR600 ];
#  hardware.firmware = [ pkgs.radeonARUBA pkgs.radeonR600 pkgs.radeonR700 ];
  #hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

#  hardware.opengl.videoDrivers = [ "intel" ];

  hardware.pulseaudio.enable = true;

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
    #kernelPackages = pkgs.linuxPackages_3_12;
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
      allowedTCPPorts = [ 22 7962 ];
      allowedUDPPorts = [ 7962 ];
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
      extraGroups = [ "wheel" "networkmanager" ];
      group = "users";
      home = "/home/matej";
      shell = "/run/current-system/sw/bin/zsh";
    };
  };

  services = {
    # List services that you want to enable:
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
      desktopManager.e18.enable = false;
      desktopManager.kde4.enable = false;
      desktopManager.gnome3.enable = true;
      desktopManager.default = "gnome3";
      displayManager.slim.enable = false;
      displayManager.lightdm.enable = true;
      displayManager.kdm.enable = false;
      displayManager.desktopManagerHandlesLidAndPower = false;
      synaptics = {
        enable = true;
        twoFingerScroll = true;
        maxSpeed = "0.95";
        tapButtons = false;
      };
#      desktopManager.session = [
#      { name = "E18";
#        start = ''
#          ${pkgs.e18.enlightenment}/bin/enlightenment_start &> /home/matej/E18.log
#          waitPID=$!
#        '';
#      }];
    };

    syncthing.enable = true;
    syncthing.user = "matej";
    syncthing.dataDir = "/home/matej";

    #searx.enable = true;
    #searx.configFile = "/var/lib/searx/.searx.yml";

    #seeks.enable = true;
    #seeks.confDir = "/var/lib/seeks/etc";


    elasticsearch.enable = true;

    #nixui.enable = true;
    #nixui.user = "matej";
    #nixui.dataDir = "/home/matej/.nixui";

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

    #gnome3.evolution-data-server.enable = true;

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
    systemPackages = with pkgs; [
      #alsaLib alsaPlugins alsaUtils
      file
      gnupg
      gnupg1
      nmap
      p7zip
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
      gitFull
      lsof
      stdenv
      xfontsel
      xlibs.xev
      #xlibs.xinput
      xlibs.xmessage
      xlibs.xmodmap
      rxvt_unicode
      xsel
      #networkmanagerapplet
      gnome.gnome_keyring

      vimHugeX
      ctags # used in vim
      # needed for vim's syntastic
      phantomjs
      pythonPackages.flake8
      pythonPackages.docutils
      htmlTidy
      csslint
      #xmllint
      #zptlint

      tree
      chromium
      firefoxWrapper
      vimprobable2Wrapper
      evince
      vlc
      mplayer2 smplayer
      dropbox
      audacity
      sublime3
      wgetpaste
      dmenu
      truecrypt
      gparted
      unetbootin
      xfce.xfce4_systemload_plugin
      #dunst
      twmn
      xautolock

      i3lock
      i3status
      scrot  # screenshots
      vifm  # file browser

      imagemagick

      python27Full
      pythonPackages.virtualenv
      pythonPackages.ipython
      pythonPackages.alot
      pythonPackages.afew
      pythonPackages.supervisor

      feh
      gnome.GConf

      #pcmanfm
      atool

      openssl
      tk tcl
      libnotify
      ccrypt
      bind
      cdrkit
      psmisc 
      upower
      pmutils
      virtmanager libvirt
      #connman
      #connmanui
      filezilla
      #parcellite xdotool

      #kde4.yakuake kde4.konsole
      kde4.ark
      #kde4.kde_gtk_config gtk_engines gnome3.gnome_themes_standard
      #kde4.akonadi kde4.kdepimlibs kde4.kdepim_runtime kde4.kdepim
      #kde4.networkmanagement

      gtk-engine-murrine

      #e18.efl e18.evas e18.emotion e18.elementary e18.enlightenment e18.econnman
      e18.terminology
      openvpn
      x11_ssh_askpass

      # texstudio texLiveFull
      zed

      cmst

      xdg_default_apps

      xfce.terminal
    ];


    gnome3.packageSet = pkgs.gnome3_12;
  };

  sound.enable =  true;

  nixpkgs.config = {

    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;       
    };

    chromium = {
      #enableAdobeFlash = true;
      enableGoogleTalkPlugin = true;
      #enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      #enablePepperPDF = true;
      #jre = true;
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
*/

    systemd.services."my-post-suspend" =
      { description = "Post-Suspend Actions";
        wantedBy = [ "suspend.target" ];
        before = [ "post-sleep.service" ];
        script =
          ''
            /home/matej/workarea/helper_scripts/bin/thissession /home/matej/workarea/helper_scripts/bin/i3lock-wrapper
          '';
        serviceConfig.Type = "simple";
      };

#  nix.trustedBinaryCaches = [
#    "http://cache.nixos.org/"
#    "http://hydra.scriptores.com/"
#    "http://hydra.nixos.org/"
#  ];

}
