#!/usr/bin/env zsh

# A simple script for setting up OSX dev environment.

dev="$HOME/Development"
pushd .
mkdir --parents $dev
cd $dev

echo 'Enter new hostname of the machine (e.g. macbook-paulmillr)'
  read hostname
  echo "Setting new hostname to $hostname..."
  scutil --set HostName "$hostname"
  compname=$(sudo scutil --get HostName | tr '-' '.')
  echo "Setting computer name to $compname"
  scutil --set ComputerName "$compname"

echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f '~/.ssh/id_rsa.pub' ]] || ssh-keygen -t rsa

echo 'Copying public key to clipboard. Paste it into your Github account...'
  [[ -f '~/.ssh/id_rsa.pub' ]] && cat '~/.ssh/id_rsa.pub' | pbcopy
  open 'https://github.com/account/ssh'

# If we on OS X, install homebrew and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then
  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
      ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
      brew update
      brew install htop mongodb mysql nginx node ruby
  fi

  echo 'Tweaking OS X...'
    source 'etc/osx.sh'
fi

echo 'Symlinking config files...'
  source 'bin/symlink-dotfiles.sh'

echo 'Applying sublime config...'
  st=$(pwd)/sublime/packages
  as="$HOME/Application Support/Sublime Text 2/Packages"
  asprefs="$as/User/Preferences.sublime-settings"
  if [[ -z "$as" ]]; then
    for theme in $st/Theme*; do
      cp -r $theme $as
    done
    rm $asprefs
    cp -r $st/pm-themes $as
    ln -s "$st/User/Preferences.sublime-settings" $asprefs
  else
    echo "Install Sublime Text"
  fi

popd
