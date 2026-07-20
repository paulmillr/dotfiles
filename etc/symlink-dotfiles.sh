#!/bin/sh
set -eu

umask 022

script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)
dotfiles=$(CDPATH='' cd "$script_dir/.." && pwd -P)

echo ""
if [ -d "$dotfiles/home" ]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles/home does not exist" >&2
  exit 1
fi

# Move an existing non-symlink file aside before replacing it, unless its
# content already matches the incoming file (so reruns don't clobber a
# .bak holding real user data with a pristine copy).
backup_existing() {
  from="$1"
  to="$2"

  if [ -f "$to" ] && [ ! -L "$to" ] && ! cmp -s "$from" "$to"; then
    echo "Backing up '$to' to '$to.bak'"
    mv -f "$to" "$to.bak"
  fi
}

link() {
  from="$1"
  to="$2"

  if [ ! -e "$from" ] && [ ! -L "$from" ]; then
    echo "Cannot link missing path '$from'" >&2
    return 1
  fi
  if [ -d "$to" ] && [ ! -L "$to" ]; then
    echo "Refusing to replace directory '$to'" >&2
    return 1
  fi

  backup_existing "$from" "$to"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

find "$dotfiles/home" -maxdepth 1 -type f -name '.*' -print | sort | while IFS= read -r location; do
  file="${location##*/}"
  case "$file" in
    .gitconfig|.npmrc)
      continue
      ;;
  esac
  file="${file%.sh}"
  link "$location" "$HOME/$file"
done

echo "Initializing fresh git config in '$HOME/.gitconfig'"
backup_existing "$dotfiles/home/.gitconfig" "$HOME/.gitconfig"
backup_existing "$dotfiles/home/.npmrc" "$HOME/.npmrc"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.npmrc"
cp "$dotfiles/home/.gitconfig" "$HOME/.gitconfig"
cp "$dotfiles/home/.npmrc" "$HOME/.npmrc"

link "$dotfiles/vim" "$HOME/.vim"
unm="$(uname)"
if [ "$unm" = 'Darwin' ]; then
  vsdir="$HOME/Library/Application Support/Code/User"
else
  vsdir="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
fi

if [ -d "$vsdir" ]; then
  link "$dotfiles/vscode/settings.json" "$vsdir/settings.json"
fi
