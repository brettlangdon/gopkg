gopkg
=====

`gopkg` is a helper wrapper similar to `virtualenvwrapper` for python, making it
easy to keep package third party dependencies isolated. `gopkg.sh` simply
provides some bash functions to help manage your `GOPATH`.


## Setup

Download the latest version of the script.
```bash
mkdir ~/.gopkg
curl -o ~/.gopkg/gopkg.sh https://raw.githubusercontent.com/brettlangdon/gopkg/master/gopkg.sh
```

Next modify your `~/.bashrc` or `~/.zshrc` files to include the following
```bash
export GOPKG_REPO=github.com/username
export GOPKG_HOME=~/.gopkg
source ~/.gopkg/gopkg.sh
```

### Environment variables

`gopkg` uses the following environment variables

* `GOPATH` - when creating a new package `gopkg` will create a directory for the
source of your package within your `GOPATH`
* `GOPKG_REPO` - when creating a new package `gopkg` will use `GOPKG_REPO` as
the base repository location for your package (e.g. `github.com/username`)
* `GOPKG_HOME` - when creating a new package `gopkg` will create a new directory
in `GOPKG_HOME` to store all third party packages (installed normally via `go
get`) in this directory


## Usage
### Creating a new package

To create a new package use the command `mkgopkg <name>`. This will create
directories (if they do not already exist) at `$GOPATH/src/$GOPKG_REPO/<name>`
and `$GOPKG_HOME/<name>` and will update your `GOPATH` to be
`$GOPKG_HOME/<name>:$GOPATH`.

### Removing an existing package

To remove an existing package run the command `rmgopkg <name>`. `rmgopkg` will
only remove the directory created inside of `$GOPKG_HOME/<name>`, it will not
touch the one in `$GOPATH/src/$GOPKG_REPO/<name>`.

### Activating a package

Just like `virtualenv` you have to "activate" a package in order to use
it. Running `gopkg <name>` will activate an existing package. What it does is
simply update your `GOPATH` to be `$GOPKG_HOME/<name>:$GOPATH` and add `(<name>)
` to `PS1`.

The updated `GOPATH` allows `go get` to install all packages into
`$GOPKG_HOME/<name>` while still being able to successfully find you source
package in `$GOPATH/src/$GOPKG_REPO/<name>`.

### Deactivating a package

When you are done and want to reset your `PS1` and `GOPATH` variables simply run
`deactivate`. `deactivate` is a command which is only available once you have
run `gopkg <name>`.
