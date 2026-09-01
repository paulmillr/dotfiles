#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
repo_dir=$(CDPATH='' cd -- "$script_dir/.." && pwd -P)
vendor_dir="$repo_dir/config/shell/zsh/vendor"
completions_target="$vendor_dir/completions"
highlighting_target="$vendor_dir/highlighting"
work_dir=''
committed=0

kept_completions='age certbot chromium cmake diskutil fallocate golang gpgconf gtk-launch httpie ipcmk ipcrm ipcs lscpu lsipc lslocks lslogins lsmem mcookie mkcert nano nftables node openssl playwright rev tox ufw uuidgen uuidparse virtualbox wdctl wg-quick'

cleanup() {
  status=$?
  trap - 0 HUP INT TERM

  if [ -n "$work_dir" ] && [ -d "$work_dir" ]; then
    if [ "$committed" -eq 0 ]; then
      if [ -d "$work_dir/old-completions" ]; then
        rm -rf -- "$completions_target"
        mv -- "$work_dir/old-completions" "$completions_target"
      fi
      if [ -d "$work_dir/old-highlighting" ]; then
        rm -rf -- "$highlighting_target"
        mv -- "$work_dir/old-highlighting" "$highlighting_target"
      fi
      if [ -f "$work_dir/old-README.md" ]; then
        mv -- "$work_dir/old-README.md" "$vendor_dir/README.md"
      fi
    fi
    rm -rf -- "$work_dir"
  fi

  exit "$status"
}

die() {
  echo "$*" >&2
  exit 1
}

prune_completions() {
  source_dir="$1/src"
  count=0

  for file in "$source_dir"/_*; do
    [ -f "$file" ] || continue
    completion=${file##*/}
    completion=${completion#_}
    case " $kept_completions " in
      *" $completion "*) count=$((count + 1)) ;;
      *) rm -- "$file" ;;
    esac
  done

  for completion in $kept_completions; do
    [ -r "$source_dir/_$completion" ] ||
      die "Upstream no longer provides the required _$completion completion"
  done
  [ "$count" -eq 33 ] || die "Expected 33 completions, retained $count"

  rm -rf -- \
    "$1/.git" \
    "$1/.editorconfig" \
    "$1/.github" \
    "$1/.gitignore" \
    "$1/CONTRIBUTING.md" \
    "$1/README.md" \
    "$1/zsh-completions-howto.org" \
    "$1/zsh-completions.plugin.zsh"
}

prune_highlighting() {
  rm -rf -- \
    "$1/.git" \
    "$1/.editorconfig" \
    "$1/.gitattributes" \
    "$1/.github" \
    "$1/.gitignore" \
    "$1/HACKING.md" \
    "$1/INSTALL.md" \
    "$1/Makefile" \
    "$1/README.md" \
    "$1/changelog.md" \
    "$1/docs" \
    "$1/images" \
    "$1/release.md" \
    "$1/tests" \
    "$1/zsh-syntax-highlighting.plugin.zsh" \
    "$1/highlighters/README.md" \
    "$1/highlighters/brackets" \
    "$1/highlighters/cursor" \
    "$1/highlighters/line" \
    "$1/highlighters/pattern" \
    "$1/highlighters/regexp" \
    "$1/highlighters/root" \
    "$1/highlighters/main/README.md" \
    "$1/highlighters/main/test-data"
}

command -v git >/dev/null 2>&1 || die 'git is required'
command -v zsh >/dev/null 2>&1 || die 'zsh is required'
[ -d "$completions_target" ] || die "Missing vendor directory: $completions_target"
[ -d "$highlighting_target" ] || die "Missing vendor directory: $highlighting_target"
[ -r "$vendor_dir/README.md" ] || die "Missing vendor manifest: $vendor_dir/README.md"

work_dir=$(mktemp -d "$vendor_dir/.update.XXXXXX")
trap cleanup 0
trap 'exit 1' HUP INT TERM

new_completions="$work_dir/new-completions"
new_highlighting="$work_dir/new-highlighting"

git clone --filter=blob:none --depth 1 \
  https://github.com/zsh-users/zsh-completions.git "$new_completions"
git clone --filter=blob:none --depth 1 \
  https://github.com/zsh-users/zsh-syntax-highlighting.git "$new_highlighting"

completions_commit=$(git -C "$new_completions" rev-parse HEAD)
highlighting_commit=$(git -C "$new_highlighting" rev-parse HEAD)

prune_completions "$new_completions"
prune_highlighting "$new_highlighting"

printf '%s\n' "$completions_commit" > "$new_completions/.revision-hash"
printf '%s\n' "$highlighting_commit" > "$new_highlighting/.revision-hash"

zsh -n "$new_completions"/src/*
zsh -n \
  "$new_highlighting/zsh-syntax-highlighting.zsh" \
  "$new_highlighting/highlighters/main/main-highlighter.zsh"

awk -v completions="$completions_commit" -v highlighting="$highlighting_commit" '
  /^- \[zsh-completions\]/ {
    print "- [zsh-completions](https://github.com/zsh-users/zsh-completions) at commit `" completions "`"
    next
  }
  /^- \[zsh-syntax-highlighting\]/ {
    print "- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) at commit `" highlighting "`"
    next
  }
  { print }
' "$vendor_dir/README.md" > "$work_dir/new-README.md"

grep -F "$completions_commit" "$work_dir/new-README.md" >/dev/null
grep -F "$highlighting_commit" "$work_dir/new-README.md" >/dev/null

mv -- "$completions_target" "$work_dir/old-completions"
mv -- "$highlighting_target" "$work_dir/old-highlighting"
mv -- "$vendor_dir/README.md" "$work_dir/old-README.md"
mv -- "$new_completions" "$completions_target"
mv -- "$new_highlighting" "$highlighting_target"
mv -- "$work_dir/new-README.md" "$vendor_dir/README.md"

committed=1
printf 'Vendored zsh-completions at %s\n' "$completions_commit"
printf 'Vendored zsh-syntax-highlighting at %s\n' "$highlighting_commit"
