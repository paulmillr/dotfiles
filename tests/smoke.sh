#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)
dotfiles=$(CDPATH='' cd "$script_dir/.." && pwd -P)

test -d "$dotfiles/config/shell/zsh/vendor/completions/src"
test -r "$dotfiles/config/shell/zsh/vendor/completions/LICENSE"
test -x "$dotfiles/scripts/update-vendor.sh"
for completion in certbot chromium cmake diskutil golang httpie mkcert nftables playwright tox ufw virtualbox; do
  test -r "$dotfiles/config/shell/zsh/vendor/completions/src/_$completion"
done
test "$(find "$dotfiles/config/shell/zsh/vendor/completions/src" -type f | wc -l)" -eq 33
test -r "$dotfiles/config/shell/zsh/vendor/highlighting/zsh-syntax-highlighting.zsh"
test -r "$dotfiles/config/shell/zsh/vendor/highlighting/highlighters/main/main-highlighter.zsh"
test ! -e "$dotfiles/.gitmodules"
test ! -e "$dotfiles/config/shell/zsh/vendor/completions/.git"
test ! -e "$dotfiles/config/shell/zsh/vendor/highlighting/.git"
test ! -e "$dotfiles/config/shell/zsh/vendor/highlighting/tests"
test ! -e "$dotfiles/config/shell/zsh/vendor/highlighting/highlighters/brackets"
grep -F "$(cat "$dotfiles/config/shell/zsh/vendor/completions/.revision-hash")" \
  "$dotfiles/config/shell/zsh/vendor/README.md" >/dev/null
grep -F "$(cat "$dotfiles/config/shell/zsh/vendor/highlighting/.revision-hash")" \
  "$dotfiles/config/shell/zsh/vendor/README.md" >/dev/null

sh -n \
  "$dotfiles/install.sh" \
  "$dotfiles/scripts/link.sh" \
  "$dotfiles/scripts/linux/install-motd.sh" \
  "$dotfiles/scripts/macos/defaults.sh" \
  "$dotfiles/scripts/update-vendor.sh"
grep -F 'sh "$repo/scripts/link.sh" --overwrite' "$dotfiles/install.sh" >/dev/null
bash -n \
  "$dotfiles/home/.bashrc" \
  "$dotfiles/scripts/linux/motd.sh" \
  "$dotfiles/config/shell/shared.sh"
zsh -n \
  "$dotfiles/home/.zshrc" \
  "$dotfiles/config/shell/shared.sh" \
  "$dotfiles/config/shell/zsh/zshrc.zsh"

test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM
test_home="$test_root/home"
test_repo="$test_home/Developer/personal/dotfiles"

mkdir -p "$test_repo" "$test_home/.config/Code/User"
cp -R \
  "$dotfiles/config" \
  "$dotfiles/home" \
  "$dotfiles/scripts" \
  "$test_repo/"

HOME="$test_home" sh "$test_repo/scripts/link.sh"

test -L "$test_home/.zshrc"
test ! -e "$test_home/.bashrc"
test -L "$test_home/.vim"
test -L "$test_home/.config/Code/User/settings.json"

# Shared environment setup behaves identically in Bash and Zsh, including
# recovery of the terminal background cached by a normal SSH login.
shared="$test_repo/config/shell/shared.sh"
HOME="$test_home" \
XDG_CACHE_HOME="$test_root/cache-bash" \
SSH_CONNECTION=1 \
HERDR_ENV= \
LC_TERM_BG=light \
DOTFILES_SHARED="$shared" \
bash --noprofile --norc -c '
  . "$DOTFILES_SHARED" || exit 1
  test "$dev" = "$HOME/Developer" || exit 1
  test "$pm" = "$HOME/Developer/personal" || exit 1
  test "$BAT_THEME" = "$BAT_THEME_LIGHT" || exit 1
  test "$DELTA_FEATURES" = "+light-mode" || exit 1
'
HOME="$test_home" \
XDG_CACHE_HOME="$test_root/cache-bash" \
SSH_CONNECTION=1 \
HERDR_ENV=1 \
DOTFILES_SHARED="$shared" \
bash --noprofile --norc -c '
  unset LC_TERM_BG
  . "$DOTFILES_SHARED" || exit 1
  test "$LC_TERM_BG" = light || exit 1
  test "$BAT_THEME" = "$BAT_THEME_LIGHT" || exit 1
  test "$DELTA_FEATURES" = "+light-mode" || exit 1
'
HOME="$test_home" \
DOTFILES_BASHRC="$test_repo/home/.bashrc" \
bash --noprofile --norc -ic '
  . "$DOTFILES_BASHRC" || exit 1
  test "$DO_NOT_TRACK" = 1 || exit 1
  declare -F _bash_prompt_capture_status >/dev/null || exit 1
  declare -F _bash_prompt_update >/dev/null || exit 1
  [[ "$PROMPT_COMMAND" == *"_bash_prompt_update"* ]] || exit 1
'
HOME="$test_home" \
XDG_CACHE_HOME="$test_root/cache-zsh" \
SSH_CONNECTION=1 \
HERDR_ENV= \
LC_TERM_BG=light \
DOTFILES_SHARED="$shared" \
zsh -dfc '
  source "$DOTFILES_SHARED" || exit 1
  test "$dev" = "$HOME/Developer" || exit 1
  test "$pm" = "$HOME/Developer/personal" || exit 1
  test "$BAT_THEME" = "$BAT_THEME_LIGHT" || exit 1
  test "$DELTA_FEATURES" = "+light-mode" || exit 1
'
HOME="$test_home" \
XDG_CACHE_HOME="$test_root/cache-zsh" \
SSH_CONNECTION=1 \
HERDR_ENV=1 \
DOTFILES_SHARED="$shared" \
zsh -dfc '
  unset LC_TERM_BG
  source "$DOTFILES_SHARED" || exit 1
  test "$LC_TERM_BG" = light || exit 1
  test "$BAT_THEME" = "$BAT_THEME_LIGHT" || exit 1
  test "$DELTA_FEATURES" = "+light-mode" || exit 1
'

# A second default run is idempotent when every destination is already current.
HOME="$test_home" sh "$test_repo/scripts/link.sh"

# Conflicting files are reported in red and preserved unless replacement was
# explicitly requested.
rm -f "$test_home/.curlrc"
printf 'existing curl config\n' > "$test_home/.curlrc"
printf '\n[user]\n  name = Existing User\n' >> "$test_home/.gitconfig"
conflict_log="$test_root/conflicts.log"
if (
  unset NO_COLOR
  HOME="$test_home" CLICOLOR_FORCE=1 sh "$test_repo/scripts/link.sh" > "$conflict_log" 2>&1
); then
  echo 'Expected the linker to report conflicts' >&2
  exit 1
fi
red=$(printf '\033[31m')
grep -F "${red}${test_home}/.curlrc" "$conflict_log" >/dev/null
grep -F "${red}${test_home}/.gitconfig" "$conflict_log" >/dev/null
grep -F 'existing curl config' "$test_home/.curlrc" >/dev/null
grep -F 'Existing User' "$test_home/.gitconfig" >/dev/null

HOME="$test_home" sh "$test_repo/scripts/link.sh" --overwrite
test -L "$test_home/.curlrc"
grep -F 'existing curl config' "$test_home/.curlrc.bak" >/dev/null
grep -F 'Existing User' "$test_home/.gitconfig.bak" >/dev/null
cmp -s "$test_repo/home/.gitconfig" "$test_home/.gitconfig"

# Existing backups are never clobbered by later overwrite runs.
rm -f "$test_home/.curlrc"
printf 'second curl config\n' > "$test_home/.curlrc"
HOME="$test_home" sh "$test_repo/scripts/link.sh" --overwrite
grep -F 'second curl config' "$test_home/.curlrc.bak.1" >/dev/null

HOME="$test_home" ZDOTDIR="$test_home" TERM=dumb zsh -f -c '
  source "$HOME/.zshrc"
  [[ "$curr" == "$HOME/Developer/personal/dotfiles" ]]
  (( $+functions[get-vcs-info] ))
  [[ -n "$PROMPT" ]]
'

HOME="$test_home" \
ZDOTDIR="$test_home" \
XDG_CACHE_HOME="$test_root/completion-cache" \
TERM=xterm-256color \
DOTFILES_ZSHRC="$test_home/.zshrc" \
zsh -dfc '
  zmodload zsh/zpty || exit 1
  zpty shell zsh -f -i
  zpty -w shell "source ${(q)DOTFILES_ZSHRC}; whence -w _certbot >/dev/null || exit 10; whence -w _ab >/dev/null && exit 11; whence -w _zsh_highlight >/dev/null || exit 12; whence -w _zsh_highlight_highlighter_brackets_paint >/dev/null && exit 13; print -r -- embedded-startup-ok; exit"
  typeset output chunk
  while zpty -r shell chunk 2>/dev/null; do
    output+=$chunk
  done
  [[ "$output" == *embedded-startup-ok* ]] || exit 1
  [[ -s "$XDG_CACHE_HOME/zsh/completion/zcompdump" ]]
'

if command -v vim >/dev/null 2>&1; then
  HOME="$test_home" vim -Nu "$test_home/.vim/vimrc" -n -es -i NONE \
    -c 'colorscheme prismatic' \
    -c 'if g:colors_name !=# "prismatic" | cquit | endif' \
    -c 'qa!'
fi

echo 'Smoke tests passed.'
