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

if [[ `uname` == 'Darwin' ]]; then
  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
      ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
      brew update
  fi

  echo 'Tweaking OS X...'
    source 'etc/osx.sh'

  echo 'You will need to manually copy some OS X settings:'
    # Wipes the default substitution list and creates a new blank one.
    gprefs='~/Library/Preferences/.GlobalPreferences.plist'
    # /usr/libexec/PlistBuddy -c 'Delete NSUserReplacementItems' $gprefs
    # /usr/libexec/PlistBuddy -c 'Add NSUserReplacementItems array' $gprefs
    # Merge text substitutions from previous backup.
    # /usr/libexec/PlistBuddy -c "Merge $(pwd)/etc/osx-text-substitutions.plist NSUserReplacementItems" $gprefs
fi

echo 'Symlinking config files...'
  source 'bin/symlink-dotfiles.sh'

popd
