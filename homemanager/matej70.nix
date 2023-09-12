{ pkgs, lib, config, ... }:
with lib;
with pkgs;
let
  nixpkgsConfigFile = "${builtins.toString ./.}/../dotfiles/nixpkgs-config.nix";
  font = {
    family = "Fira Mono Nerd Font";
    style = "Regular";
    size = 11.0;
  };
  ethernetInterfaces = [ "eno1" ];
  wirelessInterfaces = [ "wlp3s0" ];
  temperatureFiles = [ "/sys/devices/virtual/thermal/thermal_zone1/temp" ];
  terminal = "${konsole}/bin/konsole";
  term = "xterm-256color";
  editor = "${nano}/bin/nano";
  browser = "${config.home.profileDirectory}/bin/chromium";
  filemanager = "${xfce.thunar}/bin/thunar";
  window-center = writeScript "sway-window-center.sh" ''
    #!${stdenv.shell}

    wp="$1"
    hp="$2"

    width="$(swaymsg -t get_outputs | ${jq}/bin/jq '.[0].rect.width')"
    height="$(swaymsg -t get_outputs | ${jq}/bin/jq '.[0].rect.height')"

    w="$(($width * $wp/100))"
    h="$(($height * $hp/100))"

    echo "resize set $w px $h px, move position $(( ($width - $w) / 2 )) px $(( ($height - $h) / 2 )) px"
  '';
  dropdown = writeScript "terminal-dropdown.sh" ''
    #!${stdenv.shell}
    set -x
    RESULT=$(swaymsg -t get_tree | ${jq}/bin/jq '.. | .floating_nodes? // empty | .[].nodes[] | select(.marks[0]=="I3WM_SCRATCHPAD").focused')
    if [ -z "$RESULT" ]
    then
      ${terminal} --title=ScratchTerm --role=ScratchTerm &
      sleep 0.5
      WINDOW_CENTER="$(${window-center} 95 90)"
      swaymsg "[title=\"^ScratchTerm.*\"] mark I3WM_SCRATCHPAD, move scratchpad, border pixel 1, $WINDOW_CENTER, focus"
    elif [[ "$RESULT" = "true" ]]
    then
      swaymsg '[con_mark="I3WM_SCRATCHPAD"] move scratchpad'
    elif [[ "$RESULT" = "false" ]]
    then
      swaymsg '[con_mark="I3WM_SCRATCHPAD"] focus'
    fi
  '';
  launcher = writeScript "bemenu-launcher.sh" ''
    #!${python3Packages.python}/bin/python
    import os
    import re
    import subprocess
    import sys

    devnull = open(os.devnull)

    def list_env_var(envvar):
        return os.environ[envvar].split(':')


    def list_paths(path, executable=False, directory=False, recursive=False, regular=False):
        result = []

        for root, dirs, files in os.walk(path, followlinks=True):

            if directory:
                result += map(lambda x: (root, x), dirs)

            if files and (executable or regular):
                for file in files:
                    abspath = os.path.join(root, file)
                    if abspath.split("/")[-1][0] == ".":
                        continue
                    if executable and os.access(abspath, os.X_OK):
                        result += [(root, file)]
                        continue
                    if regular and os.path.isfile(abspath):
                        result += [(root, file)]

            if not recursive:
                break

        return result

    def executables():
        result = []

        #for directory in list_env_var('PATH'):
        for directory in ["${config.home.homeDirectory}/bin","/var/setuid-wrappers","${config.home.homeDirectory}/.nix-profile/bin","${config.home.homeDirectory}/.nix-profile/sbin","/nix/var/nix/profiles/default/bin","/nix/var/nix/profiles/default/sbin","/run/current-system/sw/bin","/run/current-system/sw/sbin"]:
            paths = list_paths(directory, executable=True)
            result += map(lambda item: "{0:<50} [Executable: '{1}']".format(item[1], os.path.join(item[0], item[1])), paths)

        return result


    def dirs():
        result = []
        result += list_paths(os.environ['HOME'], directory=True, regular=True)
        # result += list_paths("/your/custom/dir", directory=True)
        return map(lambda item: "{0:<50} [Open: '{1}']".format(item[1], os.path.join(item[0], item[1])), result)


    def join(paths):
        return '\n'.join(paths)


    def dmenu(args=[], options=[]):
        dmenu_cmd = ["${bemenu}/bin/bemenu"]
        if args:
            dmenu_cmd += args
        p = subprocess.Popen(
            dmenu_cmd,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        if options:
            stdout, _ = p.communicate('\n'.join(options).encode())
        else:
            stdout, _ = p.communicate()
        return stdout.decode().strip('\n')


    def read_last(path):
        result = []
        if not os.path.isfile(path):
            return result
        with open(path, 'r') as f:
            for line in f:
                s = line.strip()
                if s:
                    result += [s]
        return result


    def write_last(path, newentry):
        lines = read_last(path)
        if not newentry:
            return
        s = newentry.strip()
        lines.insert(0, s)
        with open(path, 'w') as f:
            f.write(join(remove_duplicates(lines[0:4])))


    def remove_duplicates(values):
        result = []
        seen = set()
        for value in values:
            if value not in seen:
                result.append(value)
                seen.add(value)
        return result

    def execute_menu(cmd="${bemenu}/bin/bemenu", custom_args=['-P', '>', '-b', '--fork']):
        menu_cmd = [cmd]
        menu_args = ['-p', 'run', '-l', '10', '-i']
        return subprocess.Popen(
            menu_cmd + menu_args + custom_args,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

    menu_process = execute_menu()

    s = join(read_last('${config.home.homeDirectory}/.dmenu_last') + sorted(executables()) + sorted(dirs()))

    menu_stdout, _ = menu_process.communicate('\n'.join([s]).encode())
    run = menu_stdout.decode().strip('\n')
    if run:
        match = re.match(r'.+\s+\[Executable\: \'(.+)\'\]', run)
        if match:
            write_last('${config.home.homeDirectory}/.dmenu_last', run)
            subprocess.call(match.groups()[0], shell=True)
            sys.exit(0)
        match = re.match(r'.+\s+\[Open\: \'(.+)\'\]', run)
        if match:
            write_last('${config.home.homeDirectory}/.dmenu_last', run)
            subprocess.call(['${filemanager}', match.groups()[0]])
            sys.exit(0)
        subprocess.call(run, shell=True)
  '';
  i3_workspace = writeScript "i3_workspace.py" ''
    #!${python2Packages.python}/bin/python

    import subprocess
    import json
    import sys
    import os

    def usage():
        return "Usage: {0} [--skip,--notify] {{prev|next|prev_on_output|next_on_output}}".format(os.path.basename(sys.argv[0]))

    if len(sys.argv) < 2:
        print usage()
        exit(1)

    direction = 'next'
    skip = False
    notify = False

    for i in range(1, len(sys.argv)):
        option = sys.argv[i].lower()
        if option in ('prev', 'next', 'prev_on_output', 'next_on_output'):
            direction = option
        elif option == '--notify':
            notify = True
        elif option == '--skip':
            skip = True
        else:
            print usage()
            exit(1)

    def find_by(workspaces, current, step, output = None, skip = True):
        if output != None:
            workspaces = filter(lambda w: w[u'output'] == output, workspaces)

        existing = map(lambda w: w[u'num'], workspaces)

        next = current + step
        first = 1
        last = max(existing)

        if skip:
            r = []
            if step > 0:
                r = range(first, last+1)
            elif step < 0:
                r = range(next-1, first-1, -1)
            for i in r:
                if next in existing:
                    break
                next += step

        if current == last and step > 0:
            next = last + step
        elif next < first:
            next = first
        elif next > last:
            next = last

        return next

    output = subprocess.check_output(["swaymsg", "-t", "get_workspaces"])

    workspaces = json.loads(output)

    for index in range(len(workspaces)):
        workspace = workspaces[index]

        if workspace[u'focused'] == True:
            current = workspace[u'num']
            result = current

            if direction == 'prev':
                result = find_by(workspaces, current, -1, skip=skip)
            elif direction == 'next':
                result = find_by(workspaces, current, 1, skip=skip)
            elif direction == 'prev_on_output':
                result = find_by(workspaces, current, -1, workspace[u'output'], skip)
            elif direction == 'next_on_output':
                result = find_by(workspaces, current, 1, workspace[u'output'], skip)

            if notify:
              subprocess.call(["${libnotify}/bin/notify-send", "-a", "workspace", "-t", "500", "Workspace: "+str(result)])
            print result

            break

    exit(0)
  '';
  nextcloudClientRestartScript = writeScript "nextcloud-client-restart.sh" ''
    #!${stdenv.shell}
    ${procps}/bin/pkill nextcloud
    source "${config.home.homeDirectory}/.zshrc"
    exec ${nextcloud-client}/bin/nextcloud --background
  '';
  gitrootSrc = fetchFromGitHub {
    owner = "mollifier";
    repo = "cd-gitroot";
    rev = "fec94c5b2178b56de8726013f53bb09fb51311e6";
    sha256 = "1xm1gl2mmq5difl9m57k0nh6araxqgj9vwqkh7qhqa79jm8m6my4";
  };
in
  {
    #nixpkgs.config = import nixpkgsConfigFile;
    xdg = {
      enable = true;
      configFile."nixpkgs/config.nix".source = nixpkgsConfigFile;
    };
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      font-awesome
      (nerdfonts.override { fonts = [ "FiraMono" "SourceCodePro" ]; })
      xorg.xauth
      xfce.terminal
      git
      keepassxc
      qt5Full
    ];

    gtk = {
      enable = true;
      font.name = "${font.family} ${font.style} ${toString font.size}";
      iconTheme = {
        name = "breeze";
        package = breeze-icons;
      };
      theme = {
        name = "Breeze";
        package = breeze-gtk;
      };
    };

    programs.chromium = {
      enable = true;
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
      ];
    };

    programs.firefox = {
      enable = false;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        https-everywhere ublock-origin
      ];
      profiles = {
        default = {
          settings = {
            "general.smoothScroll" = false;
          };
        };
      };
    };

    programs.htop.enable = true;

    programs.home-manager = {
      enable = true;
    };

    programs.i3status.enable = false;

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        assigns = {
          "2" = [{ window_role = "^xfce4-terminal.*"; }];
          "3" = [{ class = "^.nvim-qt-wrapped$"; }];
          "4" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; }];
        };
        bars = [];
        colors = {
          background = "#ff0000";
          focused = { background = "#272822"; border = "#272822"; childBorder = "#66D9EF"; indicator = "#66D9EF"; text = "#A6E22E"; };
          focusedInactive = { background = "#272822"; border = "#272822"; childBorder = "#272822"; indicator = "#272822"; text = "#66D9EF"; };
          unfocused = { background = "#1E1F1C"; border = "#1E1F1C"; childBorder = "#272822"; indicator = "#272822"; text = "#939393"; };
          urgent = { background = "#F92672"; border = "#F92672"; childBorder = "#F92672"; indicator = "#F92672"; text = "#FFFFFF"; };
        };
        fonts = { names = [ font.family ]; style = font.style; size = font.size; };
        keybindings =
          mkOptionDefault {
            "${modifier}+Control+t" = "exec ${terminal}";
            "${modifier}+Control+h" = "exec ${filemanager} '${config.home.homeDirectory}'";
            "F12" = "exec ${dropdown}";
            "${modifier}+Control+k" = "kill";
            "${modifier}+Control+space" = "exec ${launcher}";
            "Control+Tab" = "workspace back_and_forth";
            "${modifier}+Control+Left" = "exec WSNUM=$(${i3_workspace} --skip prev) && swaymsg workspace $WSNUM";
            "${modifier}+Control+Right" = "exec WSNUM=$(${i3_workspace} --skip next) && swaymsg workspace $WSNUM";
            "${modifier}+Control+Shift+Left" = "exec WSNUM=$(${i3_workspace} prev) && swaymsg move workspace $WSNUM && swaymsg workspace $WSNUM";
            "${modifier}+Control+Shift+Right" = "exec WSNUM=$(${i3_workspace} next) && swaymsg move workspace $WSNUM && swaymsg workspace $WSNUM";
          };
          modifier = "Mod4";
          startup = [
            { command = "systemctl --user restart polybar"; always = true; }
            { command = "systemctl --user restart dunst"; always = true; }
            { command = "${nextcloudClientRestartScript}"; always = true; }
            { command = "${browser}"; }
            { command = "${terminal}"; }
          ];
          window = {
            border = 1;
            commands = [
              { command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
              { command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
              { command = "border pixel 1"; criteria = { class = "Firefox"; }; }
              { command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
            ];
          };
        };
  };

  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "bottom";
      height = 24;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "idle_inhibitor" "pulseaudio" "network" "disk" "cpu" "memory" "temperature" "backlight" "battery" "battery#bat1" "clock" "tray" ];
      modules = {
        "sway/mode".format = "<span style=\"italic\">{}</span>";
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        tray.spacing = 10;
        clock.format = "{:%H:%M, %a %d of %b, %Y}";
        cpu = {
            format = "{usage}% ";
            tooltip = false;
        };
        memory.format = "{}% ";
        temperature = {
          hwmon-path = head temperatureFiles;
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };
        backlight = {
          format = "{percent}% {icon}";
          format-icons = [ "" "" ];
        };
        battery = {
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        "battery#bat1" = {
          bat = "BAT1";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        disk = {
          interval = 30;
          format = "{free} {path}";
          path = "/";
        };
      };
    }];
  };
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      ZSH_DISABLE_COMPFIX="true"

      unset RPS1  # clean up

      function preexec() {
        printf "\033]0;%s\a" "$1"
      }

      function precmd() {
        print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%2~\a"
      }

      export BROWSER="${browser}"
      export EDITOR="${editor}"
      export TERMINAL="${terminal}"

      export TERM="${term}"
      if [ -n "$TMUX" ]
      then
        export TERM="screen-256color"
      fi

      # del
      bindkey '^[[3~' delete-char

      # alt+del
      bindkey '^[[3;3~' kill-word

      # alt+backspace
      bindkey '^[^?' backward-kill-word

      # alt+u
      bindkey '^[u' undo

      # alt+r
      bindkey '^[r' redo

      # home
      bindkey '^[[H' beginning-of-line

      # end
      bindkey '^[[F' end-of-line

      WORDCHARS='*?_~=&;!#$%^{}<>'
      MOTION_WORDCHARS='*?_~=&;!#$%^{}<>'
      ""{back,for}ward-word() WORDCHARS=$MOTION_WORDCHARS zle .$WIDGET
      zle -N forward-word
      zle -N backward-word

      # ctrl + left/right
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # alt + left/right
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word

      export HISTFILESIZE=10000000
      export HISTSIZE=10000000
      export SAVEHIST=10000000
      export HISTFILE=~/.zsh_history

      setopt HIST_FIND_NO_DUPS
      setopt SHARE_HISTORY

      setopt histignorespace

      # 0 -- vanilla completion (abc => abc)
      # 1 -- smart case completion (abc => Abc)
      # 2 -- word flex completion (abc => A-big-Car)
      # 3 -- full flex completion (abc => ABraCadabra)
      zstyle ':completion:*' matcher-list "" \
        'm:{a-z\-}={A-Z\_}' \
        'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
        'r:|?=** m:{a-z\-}={A-Z\_}'

      zstyle ':completion:*' menu select

      source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

      source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
      ZSH_AUTOSUGGEST_STRATEGY=("history")
      ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

      source ${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down
      HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true

      DISABLE_AUTO_TITLE="true"

      autoload -Uz compinit
      compinit

      fpath=(${gitrootSrc}(N-/) $fpath)
      autoload -Uz cd-gitroot
      alias cdu='cd-gitroot'
      alias ...='cd-gitroot'

      alias l='${eza}/bin/exa -gal --git'
      alias t='${eza}/bin/exa -gal --git -T --ignore-glob=".git" -L3'

      alias ..='cd ..'

      # include .profile if it exists
      if [ -f "$HOME/.profile" ]; then
          . "$HOME/.profile"
      fi

      # set PATH so it includes user's private bin if it exists
      if [ -d "$HOME/bin" ] ; then
          PATH="$HOME/bin:$PATH"
      fi
    '';
    loginExtra = ''
      (
        # Function to determine the need of a zcompile. If the .zwc file
        # does not exist, or the base file is newer, we need to compile.
        # These jobs are asynchronous, and will not impact the interactive shell
        zcompare() {
          if [[ -s ''${1} && ( ! -s ''${1}.zwc || ''${1} -nt ''${1}.zwc) ]]; then
            zcompile ''${1}
          fi
        }

        setopt EXTENDED_GLOB

        # zcompile the completion cache; siginificant speedup.
        for file in ${config.home.homeDirectory}/.zcomp^(*.zwc)(.); do
          zcompare ''${file}
        done

        # zcompile .zshrc
        zcompare ${config.home.homeDirectory}/.zshrc
      ) &!
    '';
  };
  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "[❯](bold green) ";
      character.error_symbol = "[✗](bold red) ";
    };
  };
}
