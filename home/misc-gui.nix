{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
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
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        sway-workspace = pkgs.callPackage ../nixes/sway-workspace.nix { };
        sway-scratchpad = pkgs.callPackage ../nixes/sway-scratchpad.nix { };
        sway-wsshare = pkgs.callPackage ../nixes/sway-wsshare/default.nix { };
        thorium = pkgs.callPackage ../nixes/thorium.nix { };
        swiftpoint = pkgs.callPackage ../nixes/swiftpoint.nix { };
        logseq = pkgs.callPackage ../nixes/logseq.nix { };
        cinny-desktop = pkgs.callPackage ../nixes/cinny-desktop.nix { pkgs = prev; };
        mpv = prev.mpv.override {
          scripts = [ prev.mpvScripts.mpris ];
        };
        element-desktop = pkgs.callPackage ../nixes/element-desktop.nix { pkgs = prev; };
        movemaster = pkgs.callPackage ../nixes/movemaster.nix { };
        creality-print = pkgs.callPackage ../nixes/creality-print.nix { };
        configure-gtk = configure-gtk;
        recordCmd = recordCmd;
        zed-editor = pkgs.callPackage ../nixes/zed.nix { pkgs = prev; };
      })
    ];
    home.file = {
      default-cursor = {
        source = "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
        target = ".icons/default";
      };
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
    ]
    ++ services-cmds
    ++ programs;

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = config.variables.graphical.name;
    };

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
  };
}
