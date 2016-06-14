#!/bin/sh

# fail entire script on any error
set -e


    bare="$1"
    remote="$2"

    hooks_dir="custom_hooks"
    hashbin="/usr/bin/sha256sum"


# print some info with bold '>>>' prefixed
function info { echo -e "\e[1m>>>\e[0m $@"; }


# check if local repository exists and is bare
info "Checking local bare repository ..."
if test "$(git -C "$bare" rev-parse --is-bare-repository)" == "true"; then
    echo "OK."
else
    echo "Repository '$bare' does not exist or is not a bare repository."; return 1
fi


# check if remote repo exists and is accessible
info "Checking existence of remote repository ..."
git ls-remote --quiet "$remote" && echo "OK."


# hash the remote url
info "Hashing remote url ..."
remote_hashed="$(printf "%s" "$remote" | $hashbin | awk '{print $1}')"
echo "using '$remote_hashed' as name"
