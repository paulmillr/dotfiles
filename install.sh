#!/bin/sh
set -eu

secure_path_tree() {
  path="$1"

  [ -d "$path" ] || return 0

  find "$path" -exec chmod go-w {} +
}

main() {
  umask 022

  shell_name="${SHELL:-}"
  shell_name="${shell_name##*/}"
  [ "$shell_name" != "zsh" ] && echo "You might need to change default shell to zsh: \`chsh -s /bin/zsh\`"

  script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)
  repo="$script_dir"

  if [ ! -r "$repo/scripts/link.sh" ] || [ ! -d "$repo/home" ]; then
    echo "Run install.sh from a complete local dotfiles checkout" >&2
    exit 1
  fi

  secure_path_tree "$repo"
  sh "$repo/scripts/link.sh" --overwrite

  # Optional: remove Git metadata
  # rm -rf .git
  # Optional: remove scripts
  # rm install.sh scripts/link.sh scripts/linux/install-motd.sh README.md
}

main "$@"
