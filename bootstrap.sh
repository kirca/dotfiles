#!/bin/bash

rsync -avh --exclude ".git" --exclude "bootstrap.sh" . ~
source ~/.bashrc
