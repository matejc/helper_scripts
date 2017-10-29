{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.zshrc";
  source = builtins.toFile "zshrc" ''
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
      export RPROMPT
    }
  '';
}]
