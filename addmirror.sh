#!/bin/sh

# fail entire script on any error
set -e


    bare="$1"
    remote="$2"

    hooks_dir="custom_hooks" # --> see $gitlab_customhooks
    gituser="git"
    gitbin="git"
    hashbin="md5sum"

    blogpost="https://smcleod.net/mirror-gitlab-to-github/"
    gitlab_customhooks="http://docs.gitlab.com/ce/hooks/custom_hooks.html"
    github_machineuser="https://developer.github.com/guides/managing-deploy-keys/#machine-users"


# print some info with bold '>>>' prefixed
function info { echo -e "\e[1m>>> $@ ...\e[0m"; }


# check if running as correct user
if ! test "$EUID" == "$(id -u git)"; then
    info "You are not running as user '$gituser'!";
    read -n 1 -p "Are you sure you want to continue? [y/n] " sure
    if test "$sure" == "y"; then
        echo "es" #yes
    else
        echo; false;
    fi
fi


# check if local repository exists and is bare
info "Checking existence of local bare repository"
if ! test "$($gitbin -C "$bare" rev-parse --is-bare-repository)" == "true"; then
    echo "Repository '$bare' does not exist or is not a bare repository."; false;
fi


# check if remote repo exists and is accessible
info "Checking existence and access to remote repository"
"$gitbin" ls-remote --quiet "$remote"


# hash the remote url
info "Hashing remote url"
hashed="$(printf "%s" "$remote" | "$hashbin" | awk '{print $1}')"
echo "using '$hashed' as hash"


# add remote to local repository
info "Adding remote to local repository"
if ! "$gitbin" -C "$bare" remote -v | grep "$hashed.*push"; then
    "$gitbin" -C "$bare" remote add --mirror=push "$hashed" "$remote"
else
    echo "a remote for this hash already exists in '$bare'!"
fi


# add post-receive hook
info "Adding 'post-receive' hook"
mkdir -p "$bare/$hooks_dir"
hook="$bare/$hooks_dir/post-receive"
# create file if neccessary
if ! test -x $hook; then
    echo "create hook and mark as executable .."
    touch "$hook"
    chmod +x "$hook"
fi
# add git-push to hook
if ! grep "$hash" "$hook"; then
    echo "exec \"$gitbin\" push --quiet \"$hashed\" &" | tee --append "$hook"
else
    echo "a hook for this hash already exists in '$hook'!"
fi





