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

    bind-key -n S-PageUp \
            copy-mode\; send-keys Up Up Up Up Up Up
    bind-key -n S-PageDown \
            copy-mode\; send-keys Down Down Down Down Down Down

    bind-key -n S-Up \
            copy-mode\; send-keys Up
    bind-key -n S-Down \
            copy-mode\; send-keys Down
    bind-key -n C-F \
            copy-mode\; send-keys ?\; send-keys C-R

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
    bind-key -n F1 swap-window -t -1
    bind-key -n F2 swap-window -t +1

    bind-key -n C-N new-window -c '#{pane_current_path}'
    bind-key -n C-T new-window -c '#{pane_current_path}'

    bind-key -n C-S-Left select-pane -L
    bind-key -n C-S-Right select-pane -R
    bind-key -n C-S-Up select-pane -U
    bind-key -n C-S-Down select-pane -D

    bind-key -n C-S-Home splitw -h -p 50 -c '#{pane_current_path}'
    bind-key -n C-S-End splitw -v -p 50 -c '#{pane_current_path}'

    setw -g monitor-activity on
    set -g visual-activity off

    # Automatically set window title
    setw -g automatic-rename

    set-window-option -g xterm-keys on

    set -g history-limit 10000

    set-option -s set-clipboard off
    # For vi copy mode bindings
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard -i"
    # For emacs copy mode bindings
    bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard -i"

    set -g set-titles on
    set -g set-titles-string "#{session_name}:#(echo \"#{pane_current_path}\" | rev | cut -d'/' -f-1 | rev): #(ps --no-headers -t #{pane_tty} -o args -O-c)"

    set-option -g renumber-windows on

    source-file "${variables.homeDir}/.tmuxtheme"
  '';
} {
  target = "${variables.homeDir}/.tmuxtheme";
  source = pkgs.writeText "tmuxtheme" ''
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
    set -g status-bg "#272822"

    # Left side of status bar
    set -g status-left-bg "#272822"
    set -g status-left-fg "#66D9EF"
    set -g status-left-length 40
    set -g status-left "#[fg=colour100,bg=\"#272822\",bold] #S #[fg=\"#66D9EF\",bg=\"#272822\",nobold]#[fg=\"#66D9EF\",bg=\"#272822\"] #(whoami) #[fg=colour235,bg=\"#272822\"]#[fg=colour235,bg=\"#272822\",nobold]"

    # Right side of status bar
    set -g status-right-bg "#272822"
    set -g status-right-fg "#66D9EF"
    set -g status-right-length 150
    set -g status-right "#[fg=\"#66D9EF\",bg=\"#272822\"]#[fg=colour245,bg=\"#272822\",bold] #H [${lib.concatMapStringsSep '', '' (i: ''#(echo $(( $(cat ${i}) / 1000 ))°C)'') variables.temperatureFiles}/#(echo $(batstatus)%)]"

    # Window status
    set -g window-status-format " #(echo \"#{pane_current_path}\" | rev | cut -d'/' -f-2 | rev):#{pane_current_command} "
    set -g window-status-current-format "#[fg=\"#66D9EF\",bg=\"#272822\",nobold] #(echo \"#{pane_current_path}\" | rev | cut -d'/' -f-2 | rev):#[fg=colour208,bg=\"#272822\",nobold]#{pane_current_command} #[fg=black,bg=\"#272822\",nobold]"

    # Current window status
    set -g window-status-current-bg "#272822"
    set -g window-status-current-fg "#A6E22E"

    # Window with activity status
    set -g window-status-activity-bg "#F92672" # fg and bg are flipped here due to
    set -g window-status-activity-fg "#272822" # a bug in tmux

    # Window separator
    set -g window-status-separator ""

    # Window status alignment
    set -g status-justify centre

    # Pane border
    set -g pane-border-bg default
    set -g pane-border-fg colour248

    # Active pane border
    set -g pane-active-border-bg default
    set -g pane-active-border-fg colour34

    # Pane number indicator
    set -g display-panes-colour "#272822"
    set -g display-panes-active-colour colour245

    # Clock mode
    set -g clock-mode-colour colour100
    set -g clock-mode-style 24

    # Message
    set -g message-bg colour100
    set -g message-fg black

    # Command message
    set -g message-command-bg "#272822"
    set -g message-command-fg black

    # Mode
    set -g mode-bg colour100
    set -g mode-fg colour235
  '';
} {
  target = "${variables.homeDir}/bin/tmux-new-session";
  source = pkgs.writeScript "tmux-new-session.sh" ''
    #!${pkgs.stdenv.shell}
    if [ -z "$TMUX_SESSION_NAME" ]
    then
      tmux $@
    else
      tmux new-session -A -s $TMUX_SESSION_NAME $@
    fi
  '';
}]
