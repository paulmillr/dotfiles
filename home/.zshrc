#!/usr/bin/env zsh

# Resolve this symlink back into the checkout, then load the real Zsh config.
_dotfiles_root="${${(%):-%x}:A:h:h}"
_dotfiles_zshrc="$_dotfiles_root/config/shell/zsh/zshrc.zsh"

if [[ -r "$_dotfiles_zshrc" ]]; then
  source -- "$_dotfiles_zshrc"
else
  print -u2 "Dotfiles Zsh configuration is unavailable: $_dotfiles_zshrc"
fi

unset _dotfiles_zshrc _dotfiles_root
