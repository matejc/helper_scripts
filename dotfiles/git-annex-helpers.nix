{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/git-annex-add-remote";
  source = pkgs.writeScript "git-annex-add-remote.sh" ''
  #!/usr/bin/env bash

  # On all involved machines:
  #   install gitAndTools.git-annex gitAndTools.gitRemoteGcrypt gnupg1
  #
  # On server:
  #   $ mkdir -p ~/annex && cd ~/annex && git init --bare
  #
  # On your computer:
  #
  #   $ ssh-keygen -t rsa -b 2048 -f ~/.ssh/gitannexkey
  #
  #   add pub key (ex: ~/.ssh/gitannexkey.pub) to server's ~/.ssh/authorized_keys
  #
  #   contents of .ssh/config:
  #   ...
  #   Host server1
  #       HostName server1.yourdomain.com
  #       User notroot
  #       Port 1234
  #       IdentityFile /home/notroot/.ssh/gitannexkey
  #   ...
  #
  #   _this_ script:
  #   $ git-annex-add-remote <local destination> <server name> <ssh endpoint> <gpg id>
  #   ex: git-annex-add-remote ~/annex server1 server1:/home/user/annex matej@matejc.com
  #
  #   for automatic syncing use something like:
  #   $ git-annex assistant --foreground --debug

  export PATH="${pkgs.gitAndTools.git-annex}:${pkgs.gitAndTools.gitRemoteGcrypt}:${pkgs.gnupg1}:$PATH"

  INIT_DIR="$1"
  REMOTE_NAME="$2"
  REMOTE_SSH="$3"
  KEYID="$4"

  set -xe

  test -n "$INIT_DIR"
  test -n "$REMOTE_NAME"
  test -n "$REMOTE_SSH"
  test -n "$KEYID"

  mkdir -p $INIT_DIR

  cd $INIT_DIR

  if [ ! -d "$INIT_DIR/.git" ]; then
      git init
  fi
  git-annex init
  git-annex wanted . standard
  git-annex group . client

  EXCODE="0"
  git-annex initremote "$REMOTE_NAME" type=gcrypt gitrepo="$REMOTE_SSH" keyid="$KEYID" || EXCODE="$?"
  git-annex wanted "$REMOTE_NAME" standard
  git-annex group "$REMOTE_NAME" backup
  echo "exit status: $EXCODE"
  '';
} {
  target = "${variables.homeDir}/bin/git-annex-sync";
  source = pkgs.writeScript "git-annex-sync.sh" ''
  #!/usr/bin/env bash

  export PATH="${pkgs.gitAndTools.git-annex}:${pkgs.gitAndTools.gitRemoteGcrypt}:${pkgs.gnupg1}:$PATH"

  REPOSITORY_DIR="$1"

  set -e

  test -n "$REPOSITORY_DIR"

  if [ -d "$REPOSITORY_DIR/.git" ]; then
      cd "$REPOSITORY_DIR"
      git-annex sync --content
  else
      echo "[$REPOSITORY_DIR/.git] does not exist!"
      false
  fi
  '';
} {
  target = "${variables.homeDir}/bin/git-annex-assistant";
  source = pkgs.writeScript "git-annex-assistant.sh" ''
  #!/usr/bin/env bash

  export PATH="${pkgs.gitAndTools.git-annex}:${pkgs.gitAndTools.gitRemoteGcrypt}:${pkgs.gnupg1}:$PATH"

  REPOSITORY_DIR="$1"

  set -e

  test -n "$REPOSITORY_DIR"

  if [ -d "$REPOSITORY_DIR/.git" ]; then
      cd "$REPOSITORY_DIR"
      git-annex assistant
      gitannex_sync_stop() {
          git-annex assistant --stop
          echo "exit status: $?"
      }
      trap "gitannex_sync_stop" SIGINT
      sleep 1
      tail -f .git/annex/daemon.log
  else
      echo "[$REPOSITORY_DIR/.git] does not exist!"
      false
  fi
  '';
}]
