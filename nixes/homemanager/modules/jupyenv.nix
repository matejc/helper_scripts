{ inputs }:
{ config, lib, pkgs, ... }:

with lib;

let
  jupyenvOpts = { name, ... }: {
    options = {
      enable = mkEnableOption (lib.mdDoc "Jupyter development server");

      ip = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = lib.mdDoc ''
          IP address Jupyter will be listening on.
        '';
      };

      port = mkOption {
        type = types.port;
        description = lib.mdDoc ''
          Port number Jupyter will be listening on.
        '';
      };

      password = mkOption {
        type = types.str;
        default = "u''";
        description = lib.mdDoc ''
          Password to use with notebook.
          Can be generated using:
            In [1]: from notebook.auth import passwd
            In [2]: passwd('test')
            Out[2]: 'sha1:1b961dc713fb:88483270a63e57d18d43cf337e629539de1436ba'
            NOTE: you need to keep the single quote inside the nix string.
          Or you can use a python oneliner:
            "open('/path/secret_file', 'r', encoding='utf8').read().strip()"
          It will be interpreted at the end of the notebookConfig.
        '';
        example = "'sha1:1b961dc713fb:88483270a63e57d18d43cf337e629539de1436ba'";
      };

      token = mkOption {
        type = types.str;
        default = "''";
        description = lib.mdDoc ''
          Token to use with notebook.
        '';
      };

      attrs = mkOption {
        type = types.attrs;
        default = {};
        description = lib.mdDoc ''
          Extra jupyenv attrset.
          https://jupyenv.io/documentation/how-to/
        '';
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = lib.mdDoc ''
          Extra config to pass as config file.
        '';
      };
    };
  };

  enabled = filterAttrs (n: v: v.enable) config.services.jupyenv;
in {
  options.services.jupyenv = mkOption {
    type = types.attrsOf(types.submodule jupyenvOpts);
    default = {};
    description = lib.mkDoc ''
      Multiple Jupyenv servers.
    '';
  };

  config = mkIf (config.services.jupyenv != {}) {
    users.groups = mapAttrs' (n: _: nameValuePair "j${n}" {}) enabled;
    users.users = mapAttrs' (name: _: nameValuePair "j${name}" {
      group = "j${name}";
      home = "/var/lib/jupyenv-${name}";
      createHome = true;
      homeMode = "770";
      isSystemUser = true;
      useDefaultShell = true; # needed so that the user can start a terminal.
    }) enabled;

    systemd.services = (mapAttrs' (name: cfg:
      let
        package = inputs.jupyenv.lib."x86_64-linux".mkJupyterlabNew cfg.attrs;

        configFile = pkgs.writeText "config.py" ''
          ${cfg.extraConfig}
          c.NotebookApp.password = ${cfg.password}
          c.NotebookApp.token = ${cfg.token}
        '';
      in nameValuePair "jupyenv-${name}" {
          description = "Jupyenv server - ${name}";

          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            PATH = mkForce (makeBinPath [ pkgs.bash pkgs.coreutils-full ]);
          };

          serviceConfig = {
            Restart = "always";
            ExecStartPre = ''${pkgs.coreutils-full}/bin/mkdir -p "/var/lib/jupyenv-${name}/notebook"'';
            ExecStart = ''${package}/bin/jupyter-lab \
              --no-browser \
              --ip=${cfg.ip} \
              --port=${toString cfg.port} --port-retries 0 \
              --notebook-dir=/var/lib/jupyenv-${name}/notebook \
              --config=${configFile}'';
            User = "j${name}";
            Group = "j${name}";
            WorkingDirectory = "/var/lib/jupyenv-${name}";
          };
        }
    ) enabled);
  };
}
