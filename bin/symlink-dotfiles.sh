#!/bin/bash

dev="$HOME/Development"
dotfiles="$dev/paulmillr/dotfiles"
bin="/usr/local/bin"

if [[ -d "$dotfiles" ]]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles does not exist"
  exit 1
fi

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm --force "$to"
  ln -s "$from" "$to"
}

for location in home/*; do
  file="${location##*/}"
  file="${file%.*}"
  link "$dotfiles/$location" "$HOME/.$file"
done

for location in bin/*; do
  file="${location##*/}"
  file="${file%.*}"
  link "$dotfiles/$location" "$bin/$file"
done

if [[ `uname` == 'Darwin' ]]; then
  link "$dotfiles/sublime/Packages/User/Preferences.sublime-settings" "$HOME/Library/Application Support/Sublime Text 2/Packages/User/Preferences.sublime-settings"
fi
