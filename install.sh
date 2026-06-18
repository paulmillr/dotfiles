#!/bin/sh
set -eu

umask 022

shell_name="${SHELL:-}"
shell_name="${shell_name##*/}"
[ "$shell_name" != "zsh" ] && echo "You might need to change default shell to zsh: \`chsh -s /bin/zsh\`"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to install these dotfiles" >&2
  exit 1
fi

secure_path_tree() {
  path="$1"

  [ -d "$path" ] || return 0

  find "$path" -type d -exec chmod go-w {} +
  find "$path" -type f -exec chmod go-w {} +
}

dev_root="$HOME/Developer"
dev="$dev_root/personal"
repo="$dev/dotfiles"

mkdir -p "$dev"
chmod go-w "$dev_root" "$dev"

if [ -d "$repo/.git" ]; then
  echo "Using existing dotfiles checkout at $repo"
else
  if [ -e "$repo" ]; then
    echo "$repo already exists but is not a git checkout" >&2
    exit 1
  fi
  git clone --filter=blob:none --depth 1 --recurse-submodules --shallow-submodules https://github.com/paulmillr/dotfiles.git "$repo"
fi

git -C "$repo" submodule update --init --recursive --depth 1
secure_path_tree "$repo"
sh "$repo/etc/symlink-dotfiles.sh"

# Optional: remove .git directories
# rm -rf .git vim/.git terminal/completion/.git terminal/highlight/.git .gitmodules
# Optional: remove scripts
# rm install.sh etc/symlink-dotfiles.sh etc/install-linux-startup.sh README.md
