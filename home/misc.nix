{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  sleepCmd = pkgs.writeShellScriptBin "systemctl-sleep" ''
    exec ${pkgs.systemd}/bin/systemctl ${
      if config.variables ? "hibernate" && config.variables.hibernate then "hibernate" else "suspend"
    }
  '';
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        ${pkgs.glib}/bin/gsettings set $gnome_schema gtk-theme 'Breeze-Dark'
        ${pkgs.glib}/bin/gsettings set $gnome_schema color-scheme 'prefer-dark'
        ${pkgs.glib}/bin/gsettings set $gnome_schema font-name '${config.variables.font.family} ${toString config.variables.font.size}'
      '';
  };
  recordCmd = pkgs.writeShellScript "record.sh" ''
    if [ -f "$HOME/.rec.pid" ]
    then
      rec_pid="$(cat "$HOME/.rec.pid")"
      kill -INT "$rec_pid"
      wait "$rec_pid"
      rm "$HOME/.rec.pid"
    else
      export GST_PLUGIN_SYSTEM_PATH_1_0="${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
          pkgs.gst_all_1.gstreamer
          pkgs.gst_all_1.gst-plugins-base
          pkgs.gst_all_1.gst-plugins-good
        ]
      }"
      export PATH="${
        lib.makeBinPath [
          pkgs.gst_all_1.gstreamer
          pkgs.pulseaudio
        ]
      }:$PATH"
      mkdir -p "$HOME/Audio"
      rec_path="$HOME/Audio/recording_$(date +%Y-%m-%d_%H-%M-%S).wav"
      gst-launch-1.0 -e audiomixer name=mixer ! queue ! audioconvert ! wavenc ! filesink location="$rec_path" pulsesrc device="$(pactl get-default-source)" ! queue ! audioconvert ! mixer.  pulsesrc device="$(pactl get-default-sink).monitor" ! queue ! audioconvert ! mixer. &
      rec_pid="$!"
      echo -n "$rec_pid" > "$HOME/.rec.pid"
    fi
  '';
  tempstatus_all =
    let
      temp_list = "${lib.concatMapStringsSep "; " (
        t: ''${getTempstatus t.device t.group t.field_prefix}''
      ) config.variables.temperatures}";
    in
    pkgs.writeShellScriptBin "tempstatus" ''
      ${pkgs.gawk}/bin/awk '{i=$1}i>max{max=i}END{print max}' <(${temp_list})
    '';
  getTempstatus =
    device: group: field_prefix:
    pkgs.writeShellScript "tempstatus-${device}-${group}-${field_prefix}.sh" ''
      export PATH="$PATH:${
        lib.makeBinPath [
          pkgs.jq
          pkgs.lm_sensors
          pkgs.coreutils
        ]
      }"
      sensors -j "${device}" | jq --unbuffered -c '."${device}"."${group}"."${field_prefix}_input"|tonumber|floor'
    '';
  programs = lib.mapAttrsToList (
    name: exec:
    pkgs.writeShellScriptBin name ''
      exec ${exec} "$@"
    ''
  ) config.variables.programs;
  services-cmds = map (
    group:
    pkgs.writeScriptBin "service-group-${group}" ''
      #!${config.variables.shell}
      source "${config.variables.shellRc}"
      export WAYLAND_DISPLAY=wayland-1
      export DISPLAY=:0
      ${pkgs.dbus}/bin/dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY
      ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
      ${lib.concatMapStringsSep "\n" (
        s: ''{ sleep ${toString s.delay} && systemctl --user "$1" "${s.name}"; } &''
      ) config.variables.services}
      wait
    ''
  ) (map (s: s.group) config.variables.services);
  nur = import inputs.nur {
    nurpkgs = pkgs;
    inherit pkgs;
  };
  helper_scripts = ./..;
  dotFileAt =
    file: at:
    (lib.elemAt (import "${helper_scripts}/dotfiles/${file}" {
      inherit lib pkgs config;
      inherit (config) variables;
    }) at).source;
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        sway-workspace = pkgs.callPackage ../nixes/sway-workspace.nix { };
        sway-scratchpad = pkgs.callPackage ../nixes/sway-scratchpad.nix { };
        cproxy = pkgs.callPackage ../nixes/cproxy.nix { };
        graftcp = pkgs.callPackage ../nixes/graftcp.nix { };
        sway-wsshare = pkgs.callPackage ../nixes/sway-wsshare/default.nix { };
        thorium = pkgs.callPackage ../nixes/thorium.nix { };
        swiftpoint = pkgs.callPackage ../nixes/swiftpoint.nix { };
        logseq = pkgs.callPackage ../nixes/logseq.nix { };
        cinny-desktop = pkgs.callPackage ../nixes/cinny-desktop.nix { pkgs = prev; };
        nix-index =
          inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db; # for nixmy
        mpv = prev.mpv.override {
          scripts = [ prev.mpvScripts.mpris ];
        };
        element-desktop = pkgs.callPackage ../nixes/element-desktop.nix { pkgs = prev; };
        quickemu = inputs.quickemu.packages.${pkgs.stdenv.hostPlatform.system}.default;
        movemaster = pkgs.callPackage ../nixes/movemaster.nix { };
        sleepCmd = sleepCmd;
        configure-gtk = configure-gtk;
        recordCmd = recordCmd;
        tempstatus_all = tempstatus_all;
      })
    ];
    home.file = {
      default-cursor = {
        source = "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
        target = ".icons/default";
      };
    };
    nixpkgs.config = import ../dotfiles/nixpkgs-config.nix;
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        trusted-users = [
          "@wheel"
          config.variables.user
        ];
        experimental-features = [
          "configurable-impure-env"
          "nix-command"
          "flakes"
        ];
      };
    };
    programs.nixmy = {
      nixpkgsLocalPath = config.variables.nixmy.nixpkgs;
      nixpkgsRemote = config.variables.nixmy.remote;
      backupRemote = config.variables.nixmy.backup;
      extraPaths = [ pkgs.gnumake ];
      nix = config.nix.package;
    };
    xdg = {
      enable = true;
      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/https" = [ "browser.desktop" ];
          "x-scheme-handler/http" = [ "browser.desktop" ];
          "x-scheme-handler/file" = [ "browser.desktop" ];
          "application/pdf" = [ "browser.desktop" ];
        };
      };
      desktopEntries = {
        browser = {
          name = "Web Browser";
          genericName = "Web Browser";
          exec = "${config.variables.profileDir}/bin/browser %U";
          terminal = false;
          categories = [
            "Application"
            "Network"
            "WebBrowser"
          ];
          mimeType = [
            "x-scheme-handler/https"
            "x-scheme-handler/http"
            "x-scheme-handler/file"
            "application/pdf"
          ];
        };
      };
      configFile."nixpkgs/config.nix".source = ../dotfiles/nixpkgs-config.nix;
    };

    services.gnome-keyring = {
      enable = true;
    };

    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.font-awesome
      config.gtk.font.package
      pkgs.noto-fonts-color-emoji
      pkgs.git
      pkgs.git-crypt
      pkgs.zsh
      pkgs.xdg-utils
      pkgs.dconf
      pkgs.file
      pkgs.jq
      pkgs.tempstatus_all
      pkgs.sleepCmd
      config.nix.package
    ]
    ++ services-cmds
    ++ programs;

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
      XDG_CURRENT_DESKTOP = config.variables.graphical.name;
    };
    home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

    gtk = {
      enable = true;
      font = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = config.variables.font.family;
        size = builtins.floor config.variables.font.size;
      };
      iconTheme = {
        name = "breeze-dark";
        package = pkgs.kdePackages.breeze-icons;
      };
      theme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
      cursorTheme = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
        size = 16;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
    };

    programs.chromium = {
      package = pkgs.ungoogled-chromium;
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];
      extensions =
        let
          adn = rec {
            id = "omdnkjimmikpnlkkcjdfkmfknempnppc";
            version = "3.26.0";
            crxPath = pkgs.fetchurl {
              url = "https://github.com/dhowe/AdNauseam/releases/download/v${version}/adnauseam-${version}.chromium.crx";
              name = "adnauseam-${version}.chromium.crx";
              hash = "sha256-VK2uTuWjYu+Pg/mzbkLVydxxnajxtY0hTYyy8bhAFjY=";
            };
          };
        in
        [
          # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          # { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock origin lite
          # { id = "gcbommkclmclpchllfjekcdonpmejbdp"; } # https everywhere
          { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc
          # { id = "clpapnmmlmecieknddelobgikompchkk"; } # disable automatic gain control
          adn
        ];
    };

    programs.firefox = {
      profiles = {
        default = {
          extensions.packages = with nur.repos.rycee.firefox-addons; [
            keepassxc-browser
            multi-account-containers
            tree-style-tab
            adnauseam
          ];
          settings = {
            "general.smoothScroll" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "ui.textScaleFactor" = 90;
            "browser.tabs.drawInTitlebar" = false;
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.startup.page" = 3;
          };
          userChrome = ''
            * {
               font-size: ${toString config.variables.font.size}pt !important;
            }

            /* Hide main tabs toolbar */

            #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
                opacity: 0;
                pointer-events: none;
            }

            #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
                visibility: collapse !important;
            }

            /* Sidebar min and max width removal */

            #sidebar-box {
                max-width: none !important;
                min-width: 0px !important;
            }
            /* Hide splitter, when using Tree Style Tab. */

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] + #sidebar-splitter {
                display: none !important;
            }
            /* Hide sidebar header, when using Tree Style Tab. */

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                visibility: collapse;
            }

            /* Shrink sidebar until hovered, when using Tree Style Tab. */
            :root {
                --thin-tab-width: 100px;
                --wide-tab-width: 350px;
            }

            #sidebar-box:not([sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]) {
                min-width: var(--wide-tab-width) !important;
                max-width: none !important;
            }

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] {
                position: relative !important;
                transition: all 200ms !important;
                min-width: var(--thin-tab-width) !important;
                max-width: var(--thin-tab-width) !important;
                z-index: calc(var(--browser-area-z-index-tabbox, 10000) + 1) !important;
            }

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]:hover {
                transition: all 200ms !important;
                min-width: var(--wide-tab-width) !important;
                max-width: var(--wide-tab-width) !important;
                margin-right: calc((var(--wide-tab-width) - var(--thin-tab-width)) * -1) !important;
            }
          '';
        };
      };
    };

    programs.htop.enable = true;

    programs.home-manager = {
      enable = true;
    };

    home.username = config.variables.user;
    home.homeDirectory = config.variables.homeDir;

    services.kanshi = {
      systemdTarget = config.variables.graphical.target;
      settings = [
        {
          profile.name = "default";
          profile.outputs = map (o: {
            inherit (o)
              criteria
              position
              mode
              scale
              status
              ;
          }) config.variables.outputs;
        }
        {
          profile.name = "firstonly";
          profile.outputs = lib.imap0 (i: o: {
            inherit (o)
              criteria
              position
              mode
              scale
              ;
            status = if i == 0 then "enable" else "disable";
          }) config.variables.outputs;
        }
        {
          profile.name = "all";
          profile.outputs = map (o: {
            inherit (o)
              criteria
              position
              mode
              scale
              ;
            status = "enable";
          }) config.variables.outputs;
        }
      ];
    };

    services.kdeconnect = {
      #enable = true;
      #indicator = true;
    };
    systemd.user.services.kdeconnect.Install.WantedBy = lib.mkIf (config.services.kdeconnect.enable) (
      lib.mkForce [
        config.variables.graphical.target
      ]
    );
    systemd.user.services.kdeconnect-indicator.Install.WantedBy =
      lib.mkIf (config.services.kdeconnect.enable)
        (
          lib.mkForce [
            config.variables.graphical.target
          ]
        );
    systemd.user.services.kdeconnect-indicator.Unit.Requires =
      lib.mkIf (config.services.kdeconnect.enable)
        (lib.mkForce [ ]);

    systemd.user.services.network-manager-applet.Service.ExecStart =
      lib.mkIf (config.services.network-manager-applet.enable) (
        lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator"
      );
    systemd.user.services.network-manager-applet.Unit.Requires =
      lib.mkIf (config.services.network-manager-applet.enable)
        (
          lib.mkForce [
            "graphical-session-pre.target"
          ]
        );

    services.syncthing.extraOptions = [
      "--gui-address=127.0.0.1:8384"
      "--home=${config.variables.homeDir}/Syncthing/.config/syncthing"
    ];

    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      pinentry.package = pkgs.pinentry-curses;
    };
    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*".addKeysToAgent = "10m";
    };

    programs.bash = {
      enable = true;
      enableVteIntegration = true;
      historyControl = [
        "erasedups"
        "ignorespace"
      ];
    };

    programs.zsh = {
      enable = true;
      enableVteIntegration = true;
      initContent = ''
        . "${dotFileAt "zsh.nix" 0}" || true

        . "${pkgs.nix}/etc/profile.d/nix.sh"

        unset __HM_SESS_VARS_SOURCED
        . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" || true
      '';
      loginExtra = ''
        . "${dotFileAt "zsh.nix" 1}" || true
      '';
      envExtra = ''
        setopt no_global_rcs
        unset __HM_ZSH_SESS_VARS_SOURCED
      '';
      history = {
        expireDuplicatesFirst = true;
        extended = true;
      };
      historySubstringSearch = {
        enable = true;
        searchUpKey = "^[[A";
        searchDownKey = "^[[B";
      };
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      autocd = true;
      defaultKeymap = "emacs";
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        command_timeout = 2000;
        character.success_symbol = "[❯](bold green) ";
        character.error_symbol = "[✗](bold red) ";
        status.disabled = false;
        status.style = "fg:red";
        status.format = "[\\[$common_meaning$signal_name$maybe_int\\]]($style) ";
      };
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--no-info"
      ];
      colors = {
        hl = "#FC9867";
        "hl+" = "#FC9867";
      };
    };
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    home.shellAliases = {
      ".." = "cd ..";
      "l" = "${pkgs.eza}/bin/eza -gal --git";
      "t" = "${pkgs.eza}/bin/eza -T --ignore-glob='.git' -L3";
      "c" = "${pkgs.bat}/bin/bat";
      "d" = "${pkgs.delta}/bin/delta";
      "g" = "${pkgs.git-igitt}/bin/git-igitt";
    };
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = false;
      # settings = {
      #   simplified_ui = true;
      #   default_layout = "compact";
      #   copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";
      #   default_shell = "${context.variables.shell}";
      #   pane_frames = false;
      #   copy_on_select = false;
      #   keybinds = {
      #     # unbind = [ "Ctrl t" "Ctrl s" "Ctrl g" "Ctrl n" "Ctrl q" "Ctrl o" "Ctrl p" "Ctrl h" "Ctrl b" ];
      #     unbind = true;
      #     normal = {
      #       "bind \"Ctrl C\"" = "Copy;";
      #     };
      #   };
      # };
    };
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        log = {
          enabled = false;
        };
        mgr = {
          show_hidden = false;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
        opener = {
          play = [
            {
              run = ''mpv "$@"'';
              orphan = true;
              for = "unix";
            }
          ];
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open";
            }
          ];
          open-json = [
            {
              run = ''${pkgs.jq}/bin/jq '.' "$@" | $EDITOR'';
              block = true;
              for = "unix";
            }
          ];
        };
        open.append_rules = [
          {
            mime = "text/*";
            use = "edit";
          }
          {
            mime = "video/*";
            use = "play";
          }
          {
            name = "*.json";
            use = "open-json";
          }
          {
            name = "*";
            use = "open";
          }
        ];
      };
    };
    programs.broot = {
      enableZshIntegration = true;
      settings = {
        default_flags = "--sort-by-date --show-git-info --git-ignored --sizes --hidden";
        verbs = [
          {
            invocation = "open";
            key = "enter";
            execution = ":open_stay";
            apply_to = "file";
          }
          {
            key = "enter";
            execution = ":focus";
            apply_to = "directory";
          }
          {
            key = "right";
            execution = ":focus";
            apply_to = "directory";
          }
          {
            key = "left";
            execution = ":parent";
          }
          {
            invocation = "edit";
            key = "ctrl-enter";
            execution = "$EDITOR {file}";
            apply_to = "text_file";
            from_shell = true;
          }
        ];
      };
    };
    programs.foot = {
      settings = {
        main = {
          term = "xterm-256color";
          font = "${config.variables.font.family}:size=${toString config.variables.font.size}";
          dpi-aware = "no";
          # shell="${context.variables.shell} -c 'sleep 0.1; ${pkgs.zellij}/bin/zellij'";
        };
        mouse = {
          hide-when-typing = "no";
        };
        colors = {
          alpha = 0.9;
          background = "20211d";
          foreground = "FCFCFA";
          regular0 = "403E41";
          regular1 = "FF6188";
          regular2 = "A9DC76";
          regular3 = "FFD866";
          regular4 = "FC9867";
          regular5 = "AB9DF2";
          regular6 = "78DCE8";
          regular7 = "FCFCFA";
          bright0 = "727072";
          bright1 = "FF6188";
          bright2 = "A9DC76";
          bright3 = "FFD866";
          bright4 = "FC9867";
          bright5 = "AB9DF2";
          bright6 = "78DCE8";
          bright7 = "FCFCFA";
        };
      };
    };
    home.activation = {
      zshrcActivationAction = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run rm -f ${config.variables.homeDir}/.zshrc.zwc
      '';
      variablesActivationAction = lib.mkIf (config.variables ? activationScript) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${pkgs.writeShellScript "variables-activation.sh" config.variables.activationScript}
        ''
      );
    };

  };
}
