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

      if [ -n "$TELEPRESENCE_POD" ]
      then
        RPROMPT="%F{red}[telepresence]%{$reset_color%} ''${RPROMPT}"
      fi

      if [ -n "$container" ]
      then
        RPROMPT="%F{cyan}[$container]%{$reset_color%} ''${RPROMPT}"
      fi

      export RPROMPT
    }

    export BROWSER="${variables.browser}"
    export EDITOR="${variables.editor}"
    export PATH="$HOME/bin:${pkgs.direnv}/bin:$PATH"

    if [[ $TERM == xterm-termite ]]; then
      . ${pkgs.gnome3.vte}/etc/profile.d/vte.sh
      __vte_osc7
    fi
    ${lib.optionalString (variables.term != null) ''
      export TERM="${variables.term}"
    ''}
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

    export PERL5LIB="${pkgs.git}/share/perl5:$PERL5LIB"

    setopt histignorespace
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
    for file in ${variables.homeDir}/.zcomp^(*.zwc)(.); do
      zcompare ''${file}
    done

    # zcompile .zshrc
    zcompare ${variables.homeDir}/.zshrc
  ) &!
  '';
}]
