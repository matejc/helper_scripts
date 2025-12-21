#!/usr/bin/env bash

set -e

if ! command -v nix >/dev/null 2>&1
then
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  exit 0
fi

if ! command -v home-manager >/dev/null 2>&1
then
  nix --extra-experimental-features "nix-command flakes" run home-manager/master -- init --switch
fi

exec home-manager --extra-experimental-features "nix-command flakes" switch -b backup --flake "${1:?'Error: Required flake path not supplied as first argument!'}"
