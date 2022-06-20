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
