#!/usr/bin/env zsh

# A simple script for setting up OSX dev environment.

dev="$HOME/Development"
pushd .
mkdir -p $dev
cd $dev

echo 'Enter new hostname of the machine (e.g. macbook-paulmillr)'
	read hostname
	echo 'Setting new hostname...'
	scutil –set HostName "$hostname"

echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f '~/.ssh/id_rsa.pub' ]] || ssh-keygen -t rsa

echo 'Copying public key to clipboard. Paste it into your Github account...'
  [[ -f '~/.ssh/id_rsa.pub' ]] && pbcopy < '~/.ssh/id_rsa.pub'
  open 'https://github.com/account/ssh'

if [[ `uname` == 'Darwin' ]]; then
  echo 'Installing Homebrew...'
    ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
    brew update

  echo 'Installing NPM...'
    curl http://npmjs.org/install.sh | sh

  echo 'OS X tweaking...'
    source 'etc/osx.sh'
fi

echo 'Symlinking config files...'
  source 'bin/symlink-dotfiles.sh'

popd
