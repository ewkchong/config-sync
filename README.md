# config-sync
config-sync is a command line tool that will pull the live configuration from an environment on platform.sh to your local repository, eliminating the need to go to the site, login, export the zipped tar and move the files manually.
## Installation
First, clone the repository and `cd` into it. Then run the installer script using the following command.
```shell
sh install.sh
```

It should prompt you to add a script to your PATH; in this case, a script is being added as an executable to `/usr/local/bin`. You will then be able to invoke the script globally 

-----

## Usage
Running the command as follows will prompt you for a project ID, and to specify an environment. The configuration from that environment will be pulled into your repository.
```shell
configsync
```
Alternatively, you may also specify either a project ID and/or an environment name using flags:
```shell
configsync [-p <PROJECT-ID>] [-e <ENVIRONMENT-NAME>]
```

## Repair
In the case that anything breaks, you can always reset your configsync by first running the installation script,
```shell
sh uninstall.sh
```
making sure that your config-sync repository is up to date with master,
```shell
git fetch
git reset --hard origin/master
```
and then re-running the install script.
```shell
sh install.sh
```
If that does not fix the issue, please contact me on GitHub.
