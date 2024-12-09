{ variables, config, pkgs, lib }:
let
  gitrootSrc = pkgs.fetchFromGitHub {
    owner = "mollifier";
    repo = "cd-gitroot";
    rev = "fec94c5b2178b56de8726013f53bb09fb51311e6";
    sha256 = "1xm1gl2mmq5difl9m57k0nh6araxqgj9vwqkh7qhqa79jm8m6my4";
  };

  atuinZsh = pkgs.writeScript "atuin.zsh" ''
    export ATUIN_NOBIND="true"
    eval "$(${pkgs.atuin}/bin/atuin init zsh)"

    export ATUIN_ARROW_INDEX=-1
    export ATUIN_SEARCH_BUFFER=""

    upArrow() {

      if [[ "$ATUIN_ARROW_INDEX" == "-1" ]] && [ -z "$ATUIN_SEARCH_BUFFER" ]
      then
        export ATUIN_SEARCH_BUFFER="$BUFFER"
      fi

      COMMAND=$(atuin search --limit 1 --offset $(( ATUIN_ARROW_INDEX + 1 )) --cmd-only -- $ATUIN_SEARCH_BUFFER)
      if [[ "$?" == "0" ]]
      then
        LBUFFER="$COMMAND"
        export ATUIN_ARROW_INDEX=$(( ATUIN_ARROW_INDEX + 1 ))
      fi

      return
    }

    downArrow() {
      export ATUIN_ARROW_INDEX=$(( ATUIN_ARROW_INDEX - 1 ))

      if [ $ATUIN_ARROW_INDEX -lt 0 ]; then
        export ATUIN_ARROW_INDEX=-1
        export ATUIN_SEARCH_BUFFER=""
        LBUFFER=""
        return
      fi

      COMMAND=$(atuin search --limit 1 --offset $ATUIN_ARROW_INDEX --cmd-only -- $ATUIN_SEARCH_BUFFER)
      LBUFFER="$COMMAND"

      return
    }

    returnKey() {
      export ATUIN_ARROW_INDEX=-1
      export ATUIN_SEARCH_BUFFER=""
      zle accept-line
    }

    _atuin_precmd_2() {
      if [[ "$?" == "130" ]]
      then
        export ATUIN_ARROW_INDEX=-1
        export ATUIN_SEARCH_BUFFER=""
      fi
      return 0
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _atuin_precmd_2

    zle -N upArrow
    zle -N downArrow
    zle -N returnKey

    bindkey '^M' returnKey
    bindkey '^[[A' upArrow
    bindkey '^[OA' upArrow
    bindkey '^[[B' downArrow
    bindkey '^[OB' downArrow
  '';

  fdz-dir = pkgs.writeShellScript "fdz-dir.sh" ''
    export PATH="${lib.makeBinPath (with pkgs; [ fre fd fzf gawk gnused coreutils ])}"

    set -o errexit
    set -o nounset

    fzf_result="$({
      fre --store_name dir_history --sorted | sed -e "s|$PWD|\.|" -e '/^.$/d'
      fd -t d --min-depth 1 --max-depth 3 "" "." --exec echo {} | awk -F/ '{print NF,$0}' | sort -n | cut -d' ' -f 2-
    } | awk '!x[$0]++' | fzf +m --reverse --height 15 --tiebreak=index --bind 'tab:down' --bind 'shift-tab:up' -1 -0)"

    entry="$(realpath -s "$fzf_result")"

    if [ -d "$entry" ]
    then
      fre --store_name dir_history --add "$entry" && echo -n "$entry"
    elif [ -n "$fzf_result" ]
    then
      fre --store_name dir_history --delete "$fzf_result" && echo -n "."
    else
      echo -n "."
    fi
  '';
in
[{
  target = "${variables.homeDir}/.zshrc";
  source = pkgs.writeText "zshrc" ''
    ZSH_DISABLE_COMPFIX="true"

    unset RPS1  # clean up
    PATH="${pkgs.coreutils-full}/bin:$PATH"

    function preexec() {
      printf "\033]0;%s\a" "$1"
    }

    function precmd() {
      print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%2~\a"
    }

    export BROWSER="${variables.programs.browser}"
    export EDITOR="${variables.programs.editor}"
    ${lib.optionalString (variables.programs.terminal != null) ''
      export TERMINAL="${variables.programs.terminal}"
    ''}
    ${lib.optionalString (variables ? timeZone) ''
      export TZ="${variables.timeZone}"
    ''}

    ${lib.optionalString (variables.term != null) ''
      export TERM="${variables.term}"
    ''}
    if [ -n "$TMUX" ]
    then
      export TERM="screen-256color"
    fi

    # eval "$(direnv hook zsh)"
    #_direnv_hook() {
      #eval "$(${pkgs.direnv}/bin/direnv export zsh 2>/dev/null)";
      #${pkgs.direnv}/bin/direnv status | ${pkgs.gnugrep}/bin/grep -q "Found RC allowed true"
      #if [ "$?" = "0" ]
      #then
        #RPROMPT="%F{blue}env[%F{red}$(basename ''${DIRENV_DIR:1})%F{blue}]%{$reset_color%} ''${RPROMPT}"
      #fi
    #}
    #typeset -ag precmd_functions;
    #if [[ -z ''${precmd_functions[(r)_direnv_hook]} ]]; then
      #precmd_functions+=_direnv_hook;
    #fi

    # emacs mode
    bindkey -e

    # del
    bindkey '^[[3~' delete-char

    # alt+del
    bindkey '^[[3;3~' kill-word

    # ctrl+del
    bindkey '^[[3;5~' kill-word

    # alt+backspace
    bindkey '^[^?' backward-kill-word

    # ctrl+backspace
    bindkey '^H' backward-kill-word

    # alt+u
    bindkey '^[u' undo

    # alt+r
    bindkey '^[r' redo

    # home
    bindkey '^[[H' beginning-of-line
    bindkey '^[OH' beginning-of-line

    # end
    bindkey '^[[F' end-of-line
    bindkey '^[OF' end-of-line

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

    if [[ -t 0 && $- = *i* ]]
    then
      stty -ixon
      bindkey -r '^S'
    fi

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

    #source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

    #source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=("history")
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

    #source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    #bindkey "$terminfo[kcuu1]" history-substring-search-up
    #bindkey "$terminfo[kcud1]" history-substring-search-down
    #bindkey "^[[A" history-substring-search-up
    #bindkey "^[[B" history-substring-search-down
    HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true
    HISTORY_SUBSTRING_SEARCH_FUZZY=true
    unset HISTORY_SUBSTRING_SEARCH_PREFIXED

    DISABLE_AUTO_TITLE="true"

    fpath=(${gitrootSrc}(N-/) $fpath)
    autoload -Uz cd-gitroot
    alias cdu='cd-gitroot'
    alias ...='cd-gitroot'

    # include .profile if it exists
    if [ -f "$HOME/.profile" ]; then
        . "$HOME/.profile"
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi

    #if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
    #if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; fi

    export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
    export LC_ALL="${variables.locale.all}"
    export LC_CTYPE="${variables.locale.all}"
    export LANG="${variables.locale.all}"
    export LANGUAGE="${variables.locale.all}"

    #set_oldpwd() {
    #  echo "$PWD" >${variables.homeDir}/.oldpwd
    #}

    #trap set_oldpwd EXIT

    #export XDG_RUNTIME_DIR="/run/user/$(${pkgs.stdenv.cc.libc.getent}/bin/getent passwd "${variables.user}" | ${pkgs.coreutils}/bin/cut -d: -f3)"
    #export DBUS_SESSION_BUS_ADDRESS=''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}
    #export XAUTHORITY="${variables.homeDir}/.Xauthority"
    #display_no="$(${pkgs.coreutils}/bin/ls -1 /tmp/.X11-unix | ${pkgs.gawk}/bin/awk 'NR==1{if ($1 ~ /^X/) { gsub(/^X/,":",$1); printf $1; } }')"
    #if [[ ! -z "$display_no" ]]
    #then
    #  export DISPLAY="''${DISPLAY:-$display_no}"
    #fi

    setopt autocd
    first-tab() {
        if [[ $#BUFFER == 0 ]]
        then
            cd "$(${fdz-dir})"
            zle reset-prompt
            precmd
        else
            zle expand-or-complete
        fi
    }
    zle -N first-tab
    bindkey '^I' first-tab
    .{1..9} (){ local d=.; repeat ''${0:1} d+=/..; cd $d;}
    - (){cd -;}

    fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
    source ${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh
    fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions $fpath)

    # source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

    #autoload -U compinit
    #compinit -i
  '';
} {
  target = "${variables.homeDir}/.zlogin";
  source = pkgs.writeText "zlogin" ''
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
      for file in $HOME/.zcomp^(*.zwc)(.); do
        zcompare ''${file}
      done

      # zcompile .zshrc
      zcompare $HOME/.zshrc
    ) &!
  '';
}]
