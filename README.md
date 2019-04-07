# git-global-hooks

This script will create global git hooks which will be executed before the local ones. This is useful for example if you want to make sure a tool is run, even if it's not defined as a git hook in the local repo (e.g. linters, formatters, et.c.)

## Install

From the command line, run the following.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/paleite/git-global-hooks/master/install.sh)"
```

You can then modify your global hooks by editing the `*.global.sh`-files.

**NB:** If you re-run the install script, existing `*.global.sh`-files will **NOT** be overwritten.
