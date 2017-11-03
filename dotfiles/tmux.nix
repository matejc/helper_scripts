{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.tmux.conf";
  source = pkgs.writeText "tmux.conf" ''
    set -ga terminal-overrides ",xterm-256color:Tc"
    set -g default-terminal "screen-256color"

    set -g mouse on

    bind-key -n WheelUpPane \
        if-shell -Ft= "#{?pane_in_mode,1,#{mouse_button_flag}}" \
            "send-keys -M" \
            "if-shell -Ft= '#{alternate_on}' \
                'send-keys Up Up Up' \
                'copy-mode'"

    bind-key -n WheelDownPane \
        if-shell -Ft= "#{?pane_in_mode,1,#{mouse_button_flag}}" \
            "send-keys -M" \
            "send-keys Down Down Down"

    bind m run "\
        tmux show-options -g | grep -q "mouse.*on"; \
        if [ \$? = 0 ]; \
        then  \
            toggle=off;  \
        else  \
            toggle=on;  \
        fi;  \
        tmux display-message \"mouse is now: \$toggle\";  \
        tmux set-option -w mouse \$toggle; \
        tmux set-option -g mouse \$toggle; \
        "

    bind-key -n MouseDrag1Status swap-window -t=

    bind-key -n C-PageDown next-window
    bind-key -n C-PageUp previous-window
    bind-key -n C-N new-window -c '#{pane_current_path}'

    bind-key -n F9 new-window -c '#{pane_current_path}'

    bind -n F5 select-pane -L
    bind -n F6 select-pane -R
    bind -n F7 select-pane -U
    bind -n F8 select-pane -D

    bind-key -n F3 splitw -v -p 50 -c '#{pane_current_path}'
    bind-key -n F4 splitw -h -p 50 -c '#{pane_current_path}'

    setw -g monitor-activity on
    set -g visual-activity on

    # Automatically set window title
    setw -g automatic-rename

    set-window-option -g xterm-keys on

    set -g history-limit 10000

    #bind -t emacs-copy F10 rectangle-toggle

    # COPY & PASTE
    #bind-key -t emacs-copy MouseDragEnd1Pane copy-pipe "xclip -i -selection primary > /dev/null"
    #bind-key -t vi-copy MouseDragEnd1Pane copy-pipe "xclip -i -selection primary > /dev/null"
    # bind-key -n MouseDragEnd1Pane run -b "sleep 0.3 && tmux show-buffer | xclip -i -selection primary > /dev/null && tmux display-message \"beje\""
    # bind -n F10 run -b "tmux show-buffer | xclip -i -selection primary > /dev/null"
    #bind -n F11 run -b "exec </dev/null; xclip -o -selection clipboard | tmux load-buffer - ; tmux paste-buffer"

    source-file "${variables.homeDir}/.green.tmuxtheme"
  '';
} {
  target = "${variables.homeDir}/.green.tmuxtheme";
  source = pkgs.writeText "green.tmuxtheme" ''
    #
    # Powerline Green - Tmux Theme
    # Created by Jim Myhrberg <contact@jimeh.me>.
    #
    # Inspired by vim-powerline: https://github.com/Lokaltog/powerline
    #
    # Requires terminal to be using a powerline compatible font, find one here:
    # https://github.com/Lokaltog/powerline-fonts
    #

    # Status update interval
    set -g status-interval 5

    # Basic status bar colors
    set -g status-fg colour248
    set -g status-bg "#fdf6e3"

    # Left side of status bar
    set -g status-left-bg "#fdf6e3"
    set -g status-left-fg colour32
    set -g status-left-length 40
    set -g status-left "#[fg=colour100,bg=\"#fdf6e3\",bold] #S #[fg=colour32,bg=\"#fdf6e3\",nobold]#[fg=colour32,bg=\"#fdf6e3\"] #(whoami) #[fg=colour235,bg=\"#fdf6e3\"]#[fg=colour235,bg=\"#fdf6e3\",nobold]"

    # Right side of status bar
    set -g status-right-bg "#fdf6e3"
    set -g status-right-fg colour32
    set -g status-right-length 150
    set -g status-right "#[fg=colour32,bg=\"#fdf6e3\"]#[fg=colour245,bg=\"#fdf6e3\",bold] #H [${lib.concatMapStringsSep '', '' (i: ''#(echo $(( $(cat ${i}) / 1000 ))°C)'') variables.temperatureFiles}/#(echo $(batstatus)%)]"

    # Window status
    set -g window-status-format " #I:#P:#(echo \"#{pane_current_path}\" | rev | cut -d'/' -f-2 | rev) "
    set -g window-status-current-format "#[fg=colour32,bg=\"#fdf6e3\",nobold] #I:#P:#[fg=colour208,bg=\"#fdf6e3\",nobold]#(echo \"#{pane_current_path}\" | rev | cut -d'/' -f-2 | rev) #[fg=black,bg=\"#fdf6e3\",nobold]"

    # Current window status
    set -g window-status-current-bg "#fdf6e3"
    set -g window-status-current-fg colour34

    # Window with activity status
    set -g window-status-activity-bg colour197 # fg and bg are flipped here due to
    set -g window-status-activity-fg "#fdf6e3" # a bug in tmux

    # Window separator
    set -g window-status-separator ""

    # Window status alignment
    set -g status-justify centre

    # Pane border
    set -g pane-border-bg default
    set -g pane-border-fg colour238

    # Active pane border
    set -g pane-active-border-bg default
    set -g pane-active-border-fg colour100

    # Pane number indicator
    set -g display-panes-colour "#fdf6e3"
    set -g display-panes-active-colour colour245

    # Clock mode
    set -g clock-mode-colour colour100
    set -g clock-mode-style 24

    # Message
    set -g message-bg colour100
    set -g message-fg black

    # Command message
    set -g message-command-bg "#fdf6e3"
    set -g message-command-fg black

    # Mode
    set -g mode-bg colour100
    set -g mode-fg colour235
  '';
}]
