# Mirroring a bare git repository

Bare git repositories have the possibility to set up pre- or post-receive [hooks]
that are executes when new commits are pushed.

In some cases it might be desirable to have two copies of a repository at
different places. I.e. push to your self-hosted GitLab server but have it mirrored
on GitHub. _At least this was my usage scenario here._

There are a couple of ways to do this when using GitLab. But a rather universal
one which should work with other implementations like gitolite too is simply
using the aforementioned hooks directory. Note however, that GitLab uses a
[custom_hooks] directory instead and that this requires administrative access on
the server it is running on.

Sam McLeod outlined the three basic steps necessary in a [blogpost]:

1. Grant write access on the repository you want to mirror to
2. Set it up as a remote in your bare repository
3. Add a 'post-receive' hook to mirror-push any changes
    
This script is merely a way to automate steps 2 and 3 once access is set up.

# 1. Granting access

In case your remote repository is hosted on GitHub you basically follow their
guide on [managing deploy keys][deploy_user]. I chose to create a seperate user
on GitHub and add this user as a collaborator on the repositories I want to mirror.

Either way, it usually consists of [creating a new set][ssh-keygen] of SSH keys
and granting the appropriate public key write access. In my case I chose no
passphrase as the user account usually has no possibility of user interaction.
Alternatively you could set up an ssh-agent and enter the passphrase once every
boot. But you'd need to somehow ensure that the agent still works after x days.

Another particularity I stumbled upon was OpenSSH's connection multiplexing.
My usual SSH config includes `ControlMaster auto` which means that the first
connection will create a master socket and background that. All following
connections will use that socket and thus avoid the need for repeated authentication
and key exchange. However, the backgrounding seems to cause problems with GitLab's
unicorn worker threads: I consistently got timeouts, killed threads and 504 errors
in the browser. Thus disable connection multiplexing altogether in 
`~git/.ssh/config`:

```
Host *
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent no
    
    ControlPath none
    ControlMaster no
    ControlPersist no
```

Afterwards, check if you have access at all with something like:

```
git ~ $ ssh git@github.com
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

# 2. Set up the remote

I set up remotes in repositories of a GitLab installation on Arch Linux. The path
to the repositories is `/var/lib/gitlab/repositories/...` in this case.

Set up a new repository on GitHub and add your machine user as a collaborator.
Find the correct bare repository on the filesystem and add the SSH clone URL of
this new repository as a remote. For example, a GitLab project 'testproject' of
user 'username':

```
git ~ $ cd repositories/username/testproject.git
git testproject.git $ git remote add mirror git@github.com:username/mirror.git
```

_Subsitute with any other hosted repository service as you wish._



<!--Links:-->
[hooks]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
[blogpost]: https://smcleod.net/mirror-gitlab-to-github/ "Mirror GitLab to GitHub"
[custom_hooks]: http://docs.gitlab.com/ce/hooks/custom_hooks.html "GitLab: custom_hooks"
[deploy_user]: https://developer.github.com/guides/managing-deploy-keys/#machine-users "GitHub: managing deploy keys"
[ssh-keygen]: https://help.github.com/articles/generating-an-ssh-key/ "Generate an SSH key"