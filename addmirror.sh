#!/bin/sh

# fail entire script on any error
set -e


    remote="$1"
    bare="$2"

    hooks_dir="custom_hooks"
    hashbin="/usr/bin/sha256sum"


# print some info with bold '>>>' prefixed
function info { echo -e "\e[1m>>>\e[0m $@"; }


# check if remote repo exists and is accessible
function check_remote {
    info "Checking remote repository ..."
    git ls-remote --quiet "$1" && echo "OK."
}

function check_bare {
    info "Checking local bare repository ..."
    if test "$(git -C "$1" rev-parse --is-bare-repository)" == "true"; then
        echo "OK."
    else
        echo "Repository '$1' does not exist or is not a bare repository."
        return 1
    fi
}

check_bare "$bare"
check_remote "$remote"
