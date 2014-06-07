#!/usr/bin/env zsh

# A simple script for setting up OSX dev environment.

dev="$HOME/Developer"
pushd .
mkdir -p $dev
cd $dev

echo 'Enter new hostname of the machine (e.g. macbook-paulmillr)'
  read hostname
  echo "Setting new hostname to $hostname..."
  scutil --set HostName "$hostname"
  compname=$(sudo scutil --get HostName | tr '-' '.')
  echo "Setting computer name to $compname"
  scutil --set ComputerName "$compname"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$compname"

pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f $pub ]] || ssh-keygen -t rsa

echo 'Copying public key to clipboard. Paste it into your Github account...'
  [[ -f $pub ]] && cat $pub | pbcopy
  open 'https://github.com/account/ssh'

# If we on OS X, install homebrew and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then
  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/homebrew/go/install)"
      brew update
      brew install htop mysql nginx node ruby
  fi

  echo 'Tweaking OS X...'
    source 'etc/osx.sh'

  # http://github.com/sindresorhus/quick-look-plugins
  echo 'Installing Quick Look plugins...'
    brew tap phinze/homebrew-cask
    brew install brew-cask
    brew cask install suspicious-package quicklook-json qlmarkdown qlstephen qlcolorcode
fi

echo 'Symlinking config files...'
  source 'bin/symlink-dotfiles.sh'

echo 'Applying sublime config...'
  st=$(pwd)/sublime/packages
  as="$HOME/Library/Application Support/Sublime Text 3/Packages"
  asprefs="$as/User/Preferences.sublime-settings"
  if [[ -d "$as" ]]; then
    for theme in $st/Theme*; do
      cp -r $theme $as
    done
    rm $asprefs
    cp -r $st/pm-themes $as
  else
    echo "Install Sublime Text http://www.sublimetext.com"
  fi

open_apps() {
  echo 'Install apps:'
  echo 'Firefox:'
  open http://www.mozilla.org/en-US/firefox/new/
  echo 'Dropbox:'
  open https://www.dropbox.com
  echo 'Chrome:'
  open https://www.google.com/intl/en/chrome/browser/
  echo 'Sequel Pro:'
  open http://www.sequelpro.com
  echo 'Skype:'
  open http://www.skype.com/en/download-skype/skype-for-computer/
  echo 'Toggl:'
  open https://www.toggl.com
  echo 'Tower:'
  open http://www.git-tower.com
  echo 'Transmission:'
  open http://www.transmissionbt.com
  echo 'VLC:'
  open http://www.videolan.org/vlc/index.html
  echo 'Pixelmator!'
}

echo 'Should I give you links for system applications (e.g. Skype, Tower, VLC)?'
echo 'n / y'
read give_links
[[ "$give_links" == 'y' ]] && open_apps

popd
