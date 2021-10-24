#!/bin/sh

rsync -vh --exclude ".git" --exclude "bootstrap.sh" . ~
sudo rsync -vh configuration.nix /etc/nixos/configuration.nix
source ~/.bashrc
