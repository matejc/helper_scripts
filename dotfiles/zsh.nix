{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.zshrc";
  source = pkgs.writeText "zshrc" ''
    function preexec() {
      printf "\033]0;%s\a" "$1"
      timer=''${timer:-$SECONDS}
    }

    function precmd() {
      print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%~\a"
      RPROMPT="''${return_code}"
      if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        if [ ! $timer_show -eq 0 ]
        then
          RPROMPT="''${RPROMPT} %F{blue}''${timer_show}s%{$reset_color%}"
        fi
        unset timer
      fi
      if [ -z "$TMUX" ]
      then
        if [ -f ~/.temp1_input ]
        then
          temp=$(( $(cat ~/.temp1_input) / 1000 ))
          temp_color=yellow
          if [[ $temp -gt 60 ]]
          then
            temp_color=red
          elif [[ $temp -lt 40 ]]
          then
            temp_color=green
          fi
          RPROMPT="''${RPROMPT} %F{$temp_color}''${temp}°C%{$reset_color%}"
          unset temp
          unset temp_color
        fi

        bat=$(batstatus)
        if [ -n "$bat" ]
        then
          bat_color=yellow
          if [[ $bat -lt 30 ]]
          then
            bat_color=red
          elif [[ $bat -gt 60 ]]
          then
            bat_color=green
          fi
          RPROMPT="''${RPROMPT} %F{$bat_color}''${bat}%%%{$reset_color%}"
          unset bat
          unset bat_color
        fi
      fi

      if [ -n "$TELEPRESENCE_POD" ]
      then
        RPROMPT="%F{red}[telepresence]%{$reset_color%} ''${RPROMPT}"
      fi

      export RPROMPT
    }

    export BROWSER="${variables.browser}"
    export EDITOR="${variables.editor}"
    export PATH="$HOME/bin:${pkgs.direnv}/bin:$PATH"
    export TERM="xterm-256color"
    if [ -n "$TMUX" ]
    then
      export TERM="screen-256color"
    fi


    # eval "$(direnv hook zsh)"
    _direnv_hook() {
      eval "$(direnv export zsh 2>/dev/null)";
      if [ -n "$DIRENV_DIR" ] && [ -n "$DIRENV_WATCHES" ]
      then
        RPROMPT="%F{blue}[env:$(basename ''${DIRENV_DIR:1})]%{$reset_color%} ''${RPROMPT}"
      fi
    }
    typeset -ag precmd_functions;
    if [[ -z ''${precmd_functions[(r)_direnv_hook]} ]]; then
      precmd_functions+=_direnv_hook;
    fi

    unalias l

    # ctrl+del
    bindkey '^[[3;5~' kill-word
    # alt+del
    bindkey '^[[3;3~' kill-word

    # alt+backspace
    bindkey '^[^?' backward-kill-word

    # alt+z
    bindkey '^[z' undo

    # alt+r
    bindkey '^[r' redo
  '';
}]
