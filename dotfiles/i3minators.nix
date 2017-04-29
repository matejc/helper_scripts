{ variables, config, pkgs, lib }:
let
  configs = if variables ? "i3minator" then variables.i3minator else {};
  dotfiles = lib.mapAttrsToList (name: v: {
    target = "${variables.homeDir}/.i3minator/${name}.yml";
    source = pkgs.writeText "${name}.yml" ''
      name: ${name}
      root: ${variables.homeDir}
      workspace_name: "${v.workspace}"

      # Chain of commands to populate workspace.
      # Every element can be either a node (see below), or a command between:
      #   go_vertical, vertical, v:      change split mode into vertical
      #   go_horizontal, horizontal, h:  change split mode into vertical
      #   go_stacked, stacked:           set the layout to stacked
      #
      # Example for a rails application:
      window_chain:
        - ${name}

      # Nodes. Each node represent a window. The available parameters are:
      #   command:  the command to execute
      #   terminal: whatever the command should be run in a terminal window
      #   timeout:  A window can take a while to be placed, if your layout does not come as you want,
      #             inceremnt the timeout for slow windows. default: 0.1
      nodes:
          console:
              terminal: false
              command: ${v.command}
              timeout: ${v.timeout}
    '';
  }) configs;
in
  dotfiles
