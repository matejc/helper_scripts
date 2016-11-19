{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.i3minator/w1.yml";
  source = pkgs.writeScript "w1.yml" ''
    name: w1
    root: ${variables.homeDir}
    workspace_name: "1"

    # Chain of commands to populate workspace.
    # Every element can be either a node (see below), or a command between:
    #   go_vertical, vertical, v:      change split mode into vertical
    #   go_horizontal, horizontal, h:  change split mode into vertical
    #   go_stacked, stacked:           set the layout to stacked
    #
    # Example for a rails application:
    window_chain:
      - console

    # Nodes. Each node represent a window. The available parameters are:
    #   command:  the command to execute
    #   terminal: whatever the command should be run in a terminal window
    #   timeout:  A window can take a while to be placed, if your layout does not come as you want,
    #             inceremnt the timeout for slow windows. default: 0.1
    nodes:
        console:
            terminal: false
            command: /run/current-system/sw/bin/xfce4-terminal
            timeout: 0.4
  '';
} {
  target = "${variables.homeDir}/.i3minator/w3.yml";
  source = pkgs.writeScript "w3.yml" ''
    name: w3
    root: ${variables.homeDir}
    workspace_name: "3"

    # Chain of commands to populate workspace.
    # Every element can be either a node (see below), or a command between:
    #   go_vertical, vertical, v:      change split mode into vertical
    #   go_horizontal, horizontal, h:  change split mode into vertical
    #   go_stacked, stacked:           set the layout to stacked
    #
    # Example for a rails application:
    window_chain:
      - browser

    # Nodes. Each node represent a window. The available parameters are:
    #   command:  the command to execute
    #   terminal: whatever the command should be run in a terminal window
    #   timeout:  A window can take a while to be placed, if your layout does not come as you want,
    #             inceremnt the timeout for slow windows. default: 0.1
    nodes:
        browser:
            terminal: false
            command: /run/current-system/sw/bin/chromium || /run/current-system/sw/bin/vivaldi
            timeout: 1
  '';
} {
  target = "${variables.homeDir}/.i3minator/w4.yml";
  source = pkgs.writeScript "w4.yml" ''
    name: w4
    root: ${variables.homeDir}
    workspace_name: "4"

    # Chain of commands to populate workspace.
    # Every element can be either a node (see below), or a command between:
    #   go_vertical, vertical, v:      change split mode into vertical
    #   go_horizontal, horizontal, h:  change split mode into vertical
    #   go_stacked, stacked:           set the layout to stacked
    #
    # Example for a rails application:
    window_chain:
      - chat

    # Nodes. Each node represent a window. The available parameters are:
    #   command:  the command to execute
    #   terminal: whatever the command should be run in a terminal window
    #   timeout:  A window can take a while to be placed, if your layout does not come as you want,
    #             inceremnt the timeout for slow windows. default: 0.1
    nodes:
        chat:
            terminal: false
            command: /run/current-system/sw/bin/Franz
            timeout: 1
  '';
}]
