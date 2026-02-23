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
        cproxy = pkgs.callPackage ../nixes/cproxy.nix { };
        graftcp = pkgs.callPackage ../nixes/graftcp.nix { };
        nix-index =
          inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db; # for nixmy
        quickemu = inputs.quickemu.packages.${pkgs.stdenv.hostPlatform.system}.default;
        sleepCmd = sleepCmd;
        tempstatus_all = tempstatus_all;
        searxngr = pkgs.callPackage ../nixes/searxngr.nix { };
      })
    ];
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

    home.packages = [
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
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
    home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

    programs.htop.enable = true;

    programs.home-manager = {
      enable = true;
    };

    home.username = config.variables.user;
    home.homeDirectory = config.variables.homeDir;

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
      historyFile = "${config.home.homeDirectory}/.bash_history";
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
        findNoDups = true;
        share = true;
        ignoreSpace = true;
        path = "${config.programs.zsh.dotDir}/.zsh_history";
        save = 1000000;
        size = 1000000;
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
      dotDir = config.home.homeDirectory;
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
      shellWrapperName = "y";
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

    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
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
