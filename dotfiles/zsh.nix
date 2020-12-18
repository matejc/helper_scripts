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
    ZSH_DISABLE_COMPFIX="true"

    unset RPS1  # clean up

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

    #. ${pkgs.gnome3.vte}/etc/profile.d/vte.sh
    #if [[ $TERM == xterm-termite ]]; then
      #__vte_osc7
    #fi
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

    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=("history")
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
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

    alias l='${pkgs.exa}/bin/exa -gal --git'
    alias t='${pkgs.exa}/bin/exa -gal --git -T --ignore-glob=".git" -L3'

    alias ..='cd ..'

    # include .profile if it exists
    if [ -f "$HOME/.profile" ]; then
        . "$HOME/.profile"
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi

    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
    if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; fi

    export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
    export LC_ALL="${variables.locale.all}"
    export LANG="en"
    export LANGUAGE="en"

    set_oldpwd() {
      echo "$PWD" >${variables.homeDir}/.oldpwd
    }

    #trap set_oldpwd EXIT

    if [[ -z "$STARSHIP_SHELL" ]]
    then
      export STARSHIP_CONFIG="${variables.homeDir}/.config/starship.toml"
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    fi
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
    if [[ -f "${variables.homeDir}/.oldpwd" ]]
    then
      cd "$(cat ${variables.homeDir}/.oldpwd)"
      rm "${variables.homeDir}/.oldpwd"
    fi
  '';
}]
