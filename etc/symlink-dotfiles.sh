#!/bin/sh

dev="$HOME/Developer"
dotfiles="$dev/personal/dotfiles"

echo ""
if [ -d "$dotfiles" ]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles does not exist"
  exit 1
fi

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

for location in $(find home -name '.*'); do
  file="${location##*/}"
  file="${file%.sh}"
  link "$dotfiles/$location" "$HOME/$file"
done

link $dotfiles/vim $HOME/.vim
unm=$(uname)
if [ $unm = 'Darwin' ]; then
  vsdir="$HOME/Library/Application Support/Code/User"
else
  vsdir="$HOME/.vscode"
fi

if [ -d "$vsdir" ]; then
  link "$dotfiles/vscode/settings.json" "$vsdir/settings.json"
fi
