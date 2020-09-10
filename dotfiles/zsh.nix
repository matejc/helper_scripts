{ variables, config, pkgs, lib }:
let
  gitrootSrc = pkgs.fetchFromGitHub {
    owner = "mollifier";
    repo = "cd-gitroot";
    rev = "fec94c5b2178b56de8726013f53bb09fb51311e6";
    sha256 = "1xm1gl2mmq5difl9m57k0nh6araxqgj9vwqkh7qhqa79jm8m6my4";
  };
in
[{
  target = "${variables.homeDir}/.zshrc";
  source = pkgs.writeText "zshrc" ''
    unset RPS1  # clean up

    function preexec() {
      printf "\033]0;%s\a" "$1"
    }

    function precmd() {
      print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%2~\a"
    }

    export BROWSER="${variables.browser}"
    export EDITOR="${variables.editor}"
    export TERMINAL="${variables.terminal}"

    . ${pkgs.gnome3.vte}/etc/profile.d/vte.sh
    if [[ $TERM == xterm-termite ]]; then
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

    # alt+del
    bindkey '^[[3;3~' kill-word

    # alt+backspace
    bindkey '^[^?' backward-kill-word

    # alt+u
    bindkey '^[u' undo

    # alt+r
    bindkey '^[r' redo

    # ctrl + left/right
    bindkey "^[[1;5C" forward-word
    bindkey "^[[1;5D" backward-word

    # alt + left/right
    bindkey "^[[1;3C" forward-word
    bindkey "^[[1;3D" backward-word

    setopt histignorespace

    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    export ZSH_AUTOSUGGEST_STRATEGY=("history")

    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true

    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
    DISABLE_AUTO_TITLE="true"

    autoload -Uz compinit
    compinit

    fpath=(${gitrootSrc}(N-/) $fpath)
    autoload -Uz cd-gitroot
    alias cdu='cd-gitroot'

    alias l='${pkgs.exa}/bin/exa -gal --git'
    alias t='${pkgs.exa}/bin/exa -gal --git -T --ignore-glob=".git"'

    eval "$(${pkgs.starship}/bin/starship init zsh)"
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
