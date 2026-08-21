#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 [--overwrite]"
  echo ""
  echo "Existing paths are left untouched by default."
  echo "Use --overwrite to replace them; displaced paths are backed up."
}

overwrite=0
case "$#" in
  0)
    ;;
  1)
    case "$1" in
      --overwrite)
        overwrite=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 2
        ;;
    esac
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

umask 022

script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)
dotfiles=$(CDPATH='' cd "$script_dir/.." && pwd -P)

red=''
reset=''
if [ -z "${NO_COLOR+x}" ] && { [ -t 2 ] || [ "${CLICOLOR_FORCE:-0}" = '1' ]; }; then
  red=$(printf '\033[31m')
  reset=$(printf '\033[0m')
fi

had_conflicts=0

echo ""
if [ -d "$dotfiles/home" ]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles/home does not exist" >&2
  exit 1
fi

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

report_conflict() {
  had_conflicts=1
  printf 'Existing path left untouched: %s%s%s\n' "$red" "$1" "$reset" >&2
}

next_backup_path() {
  to="$1"
  backup="$to.bak"
  suffix=1

  while path_exists "$backup"; do
    backup="$to.bak.$suffix"
    suffix=$((suffix + 1))
  done
}

# Preserve every displaced path, including an existing backup from an earlier
# run. This makes --overwrite explicit without making it destructive.
backup_existing() {
  to="$1"
  next_backup_path "$to"

  echo "Backing up '$to' to '$backup'"
  mv "$to" "$backup"
}

backup_file() {
  to="$1"
  next_backup_path "$to"

  echo "Backing up '$to' to '$backup'"
  cp -p "$to" "$backup"
}

link() {
  from="$1"
  to="$2"

  if [ ! -e "$from" ] && [ ! -L "$from" ]; then
    echo "Cannot link missing path '$from'" >&2
    return 1
  fi

  if [ -L "$to" ] && [ "$(readlink "$to")" = "$from" ]; then
    echo "Already linked '$to'"
    return 0
  fi

  if path_exists "$to"; then
    if [ -d "$to" ] && [ ! -L "$to" ]; then
      report_conflict "$to"
      return 0
    fi
    if [ "$overwrite" -eq 0 ]; then
      report_conflict "$to"
      return 0
    fi
    backup_existing "$to"
  fi

  echo "Linking '$from' to '$to'"
  ln -s "$from" "$to"
}

copy_file() {
  from="$1"
  to="$2"

  if [ ! -f "$from" ]; then
    echo "Cannot copy missing file '$from'" >&2
    return 1
  fi

  if [ -f "$to" ] && cmp -s "$from" "$to"; then
    echo "Already current '$to'"
    return 0
  fi

  if path_exists "$to"; then
    if [ -d "$to" ] && [ ! -L "$to" ]; then
      report_conflict "$to"
      return 0
    fi
    if [ "$overwrite" -eq 0 ]; then
      report_conflict "$to"
      return 0
    fi
    backup_existing "$to"
  fi

  echo "Copying '$from' to '$to'"
  cp "$from" "$to"
}

ensure_line() {
  file="$1"
  line="$2"

  if [ -f "$file" ] && grep -Fqx "$line" "$file"; then
    return 0
  fi

  if path_exists "$file"; then
    if [ -d "$file" ] && [ ! -L "$file" ]; then
      report_conflict "$file"
      return 0
    fi
    if [ "$overwrite" -eq 0 ]; then
      report_conflict "$file"
      return 0
    fi
    if [ -f "$file" ]; then
      backup_file "$file"
    else
      backup_existing "$file"
    fi
  fi

  echo "Adding dotfiles include to '$file'"
  printf '\n%s\n' "$line" >> "$file"
}

for location in "$dotfiles"/home/.*; do
  [ -f "$location" ] || continue
  file="${location##*/}"
  case "$file" in
    .bashrc|.gitconfig|.npmrc)
      continue
      ;;
  esac
  link "$location" "$HOME/$file"
done

copy_file "$dotfiles/home/.gitconfig" "$HOME/.gitconfig"
copy_file "$dotfiles/home/.npmrc" "$HOME/.npmrc"

link "$dotfiles/config/vim" "$HOME/.vim"
unm="$(uname)"
if [ "$unm" = 'Darwin' ]; then
  ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$ghostty_dir"
  link "$dotfiles/config/ghostty/config" "$ghostty_dir/dotfiles.ghostty"

  # Ghostty loads its macOS config after its XDG config. Include our settings
  # from the active macOS file so an existing Command+C binding cannot override
  # them, while preserving the rest of the user's Ghostty configuration.
  if [ -f "$ghostty_dir/config" ]; then
    ghostty_config="$ghostty_dir/config"
  else
    ghostty_config="$ghostty_dir/config.ghostty"
  fi
  ghostty_include='config-file = dotfiles.ghostty'
  ensure_line "$ghostty_config" "$ghostty_include"

  vsdir="$HOME/Library/Application Support/Code/User"
else
  vsdir="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
fi

if [ -d "$vsdir" ]; then
  link "$dotfiles/config/vscode/settings.json" "$vsdir/settings.json"
fi

if [ "$had_conflicts" -ne 0 ]; then
  echo "" >&2
  if [ "$overwrite" -eq 0 ]; then
    echo "Conflicting paths were left untouched. Re-run with --overwrite to replace them." >&2
  else
    echo "Some paths could not be replaced." >&2
  fi
  exit 1
fi
