#!/bin/bash

# Some code taken from github.com/penpen/dotfiles.

DOTFILES="$HOME/Documents/code/dotfiles"
BIN="/usr/local/bin"

function link_bin () {
	ln -s "$DOTFILES/$1.sh" "$BIN/$1";
}

ln -s "$DOTFILES/profile_file.sh" "$HOME/.zshrc"
ln -s "$DOTFILES/gitignore" "$HOME/.gitignore"
ln -s "$DOTFILES/Textmate/" "$HOME/Library/Application Support/Textmate"
link_bin "backup_system"
link_bin "start_python_project"
link_bin "rewrite_git_history"
link_bin "symlink_dotfiles"
