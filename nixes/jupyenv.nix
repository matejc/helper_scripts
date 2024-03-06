{ jupyenv }:
{ config, lib, pkgs, ... }:

with lib;

let
  jupyenvOpts = { name, config, ... }: {
    options = {
      enable = mkEnableOption "Jupyter development server";

      ip = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          IP address Jupyter will be listening on.
        '';
      };

      port = mkOption {
        type = types.port;
        description = ''
          Port number Jupyter will be listening on.
        '';
      };

      uid = mkOption {
        type = types.int;
        default = 1000 + config.port;
        description = ''
          uid of user
        '';
      };

      gid = mkOption {
        type = types.int;
        default = 1000 + config.port;
        description = ''
          gid of user's group
        '';
      };

      uidMap = mkOption {
        type = types.int;
        default = 900000 + config.port;
        description = ''
          subuid of uid map
        '';
      };

      gidMap = mkOption {
        type = types.int;
        default = 900000 + config.port;
        description = ''
          subgid of gid map
        '';
      };

      password = mkOption {
        type = types.str;
        default = "u''";
        description = ''
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
        description = ''
          Token to use with notebook.
        '';
      };

      attrs = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          Extra jupyenv attrset.
          https://jupyenv.io/documentation/how-to/
        '';
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = ''
          Extra config to pass as config file.
        '';
      };
    };
  };

  enabled = filterAttrs (n: v: v.enable) config.services.jupyenv;

  nsjail = import ./nsjail.nix { inherit pkgs; };

in {
  options.services.jupyenv = mkOption {
    type = types.attrsOf(types.submodule jupyenvOpts);
    default = {};
    description = lib.mkDoc ''
      Multiple Jupyenv servers.
    '';
  };

  config = mkIf (config.services.jupyenv != {}) {
    users.groups = mapAttrs' (n: c: nameValuePair "j${n}" {gid = c.gid;}) enabled;
    users.users = mapAttrs' (name: c: nameValuePair "j${name}" {
      group = "j${name}";
      home = "/var/lib/jupyenv-${name}";
      createHome = true;
      homeMode = "770";
      isSystemUser = true;
      uid = c.uid;
      useDefaultShell = true; # needed so that the user can start a terminal.
      subUidRanges = [
        { startUid = c.uidMap; count = 1; }
      ];
      subGidRanges = [
        { startGid = c.gidMap; count = 1; }
      ];
    }) enabled;

    systemd.services = (mapAttrs' (name: cfg:
      let
        package = jupyenv.lib."x86_64-linux".mkJupyterlabNew cfg.attrs;

        configFile = pkgs.writeText "config.py" ''
          ${cfg.extraConfig}
          c.ServerApp.allow_remote_access = True
          c.ServerApp.password = ${cfg.password}
          c.ServerApp.token = ${cfg.token}
        '';

        buildScript = pkgs.writeScript "build-jupyter-lab-${name}.sh" ''
          #!${pkgs.stdenv.shell}
          set -e
          export HOME=/var/lib/jupyenv-${name}/home
          cd $HOME
          exec ${package}/bin/jupyter lab build
        '';

        execStartPre = pkgs.writeScript "start-pre-jupyter-lab-${name}.sh" ''
          #!${pkgs.stdenv.shell}
          set -e

          chmod o+x "/var/lib/jupyenv-${name}"
          mkdir -p /var/lib/jupyenv-${name}/home/.{cache,jupyter,yarn}
          chown -R ${toString cfg.uid}:${toString cfg.gid} /var/lib/jupyenv-${name}/home/.{cache,jupyter,yarn}

          su - j${name} -c ${buildScript}

          chown ${toString cfg.uidMap}:${toString cfg.gidMap} /var/lib/jupyenv-${name}/home
          chown -R ${toString cfg.uidMap}:${toString cfg.gidMap} /var/lib/jupyenv-${name}/home/.{cache,jupyter,yarn}
        '';

        runJupyterLab = pkgs.writeScript "jupyter-lab-${name}.sh" ''
          #!${pkgs.stdenv.shell}
          set -e
          mkdir -p /home/j${name}/notebook
          ${package}/bin/jupyter-lab \
            --no-browser \
            --ip=0.0.0.0 \
            --port=${toString cfg.port} --port-retries 0 \
            --notebook-dir=/home/j${name}/notebook \
            --config=${configFile}
        '';

        libraries = with pkgs; [
          zlib
          zstd
          stdenv.cc.cc
          curl
          openssl
          attr
          libssh
          bzip2
          libxml2
          acl
          libsodium
          util-linux
          xz
          systemd
          shadow
          coreutils-full
          bashInteractive
          git
          gawk
          iproute2
        ];

        pathEnv = pkgs.buildEnv {
          name = "bin";
          paths = libraries;
          pathsToLink = [ "/bin" ];
        };

        passwdFile = pkgs.writeText "passwd" ''
          root:!:0:0::/root:/bin/sh
          j${name}:!:${toString cfg.uid}:${toString cfg.gid}::/home/j${name}:/bin/bash
          nobody:!:65534:65534::/var/empty:/bin/nologin
        '';

        groupFile = pkgs.writeText "group" ''
          root:x:0:
          j${name}:x:${toString cfg.gid}:j${name}
          nogroup:x:65534:nobody
        '';

        slirp4netnsJson = builtins.toFile "json" (builtins.toJSON {
          execute = "add_hostfwd";
          arguments = {
            proto = "tcp";
            host_addr = cfg.ip;
            host_port = cfg.port;
            guest_port = cfg.port;
          };
        });

        startNs = pkgs.writeScript "start-ns-${name}.sh" ''
          #!${pkgs.stdenv.shell}
          trap 'kill $(jobs -rp)' EXIT

          for i in {1..50}
          do
            nspid="$(${pkgs.procps}/bin/pgrep -u ${toString cfg.uidMap} -f ${runJupyterLab})"
            if [ ! -z "$nspid" ] && [ -f "/proc/$nspid/cmdline" ]
            then
              ${pkgs.slirp4netns}/bin/slirp4netns --disable-dns \
                --configure --mtu=65520 --disable-host-loopback \
                --api-socket /var/lib/jupyenv-${name}/slirp4netns.sock $nspid tap0
              break
            fi
            sleep 0.1
          done &

          { ${nsjail}/bin/nsjail \
            --uid_mapping ${toString cfg.uid}:${toString cfg.uidMap}:1 \
            --gid_mapping ${toString cfg.gid}:${toString cfg.gidMap}:1 \
            --bindmount_ro /nix/store:/nix/store \
            --bindmount_ro /etc/resolv.conf:/etc/resolv.conf \
            --bindmount /dev/null:/dev/null \
            --bindmount /var/lib/jupyenv-${name}/devpts:/dev/pts \
            --symlink /dev/pts/ptmx:/dev/ptmx \
            --tmpfsmount /lib \
            --symlink ${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2:/lib/ld-linux-x86-64.so.2 \
            --symlink ${passwdFile}:/etc/passwd \
            --symlink ${groupFile}:/etc/group \
            --symlink ${pathEnv}/bin:/bin \
            --tmpfsmount /tmp \
            --tmpfsmount /home \
            --bindmount /var/lib/jupyenv-${name}/home:/home/j${name} \
            --cwd /home/j${name} \
            --env PATH=${pkgs.lib.makeBinPath libraries} \
            --env HOME=/home/j${name} \
            --env USER=j${name} \
            --rlimit_fsize 512 \
            --rlimit_nofile 512 \
            -- ${runJupyterLab}; } 2> >(${pkgs.gnused}/bin/sed \
              '/Use Control-C to stop this/ e cat ${slirp4netnsJson} | ${pkgs.libressl.nc}/bin/nc -U /var/lib/jupyenv-${name}/slirp4netns.sock')
        '';

        startScript = pkgs.writeScript "start-jupyter-lab-${name}.sh" ''
          #!${pkgs.stdenv.shell}

          on_exit() {
            umount /var/lib/jupyenv-${name}/devpts
          }
          trap on_exit EXIT

          mkdir -p /var/lib/jupyenv-${name}/devpts
          mount -t devpts -o ptmxmode=0666,max=16 none /var/lib/jupyenv-${name}/devpts

          su - j${name} -c "${startNs}"
        '';
      in nameValuePair "jupyenv-${name}" {
          description = "Jupyenv server - ${name}";

          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            PATH = mkForce "${makeBinPath [ pkgs.bash pkgs.coreutils-full ]}:${config.security.wrapperDir}";
          };

          serviceConfig = {
            Restart = "always";
            TimeoutStartSec = "600";
            ExecStartPre = "+${execStartPre}";
            ExecStart = "+${startScript}";
            KillSignal = "SIGINT";
            User = "j${name}";
            Group = "j${name}";
            WorkingDirectory = "/var/lib/jupyenv-${name}";
          };
        }
    ) enabled);
  };
}
