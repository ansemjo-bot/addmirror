#!/bin/sh

# fail entire script on any error
set -e

# print some info with bold '>>>' prefixed
function info { echo -e "\e[1m>>>\e[0m $@"; }

# check if remote repo exists and is accessible
function check_remote {
    info "Checking remote repository ..."
    git ls-remote --quiet "$1" && echo "OK."
}

check_remote "$1"
