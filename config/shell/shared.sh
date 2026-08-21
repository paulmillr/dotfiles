# Shared environment variables, aliases and functions, sourced by both
# zsh (via home/.zshrc) and bash.
#
# Kept bash/zsh-compatible on purpose: no zsh-only parameter-expansion flags
# (${(z)}, ${(f)}, ${(L)}, ...), glob qualifiers, or emulate/setopt calls,
# except where explicitly guarded by `[ -n "$ZSH_VERSION" ]`. Prefer plain
# `[ ]`/`[[ ]]`, `case`, and `read` over shell-specific string/array tricks
# so this file behaves the same way in both shells.

# ==================================================================
# = Helpers =
# ==================================================================

# Checks if a name is a command, function, or alias.
is-callable() {
  command -v "$1" > /dev/null 2>&1
}

# Portable ANSI colors (zsh's `colors` autoload module has no bash
# equivalent). Used by gback, git_raw, ram and ram-streaming below.
_color_red=$'\033[31m'
_color_green=$'\033[32m'
_color_yellow=$'\033[33m'
_color_blue=$'\033[34m'
_color_bold_blue=$'\033[1;34m'
_color_gray=$'\033[38;5;8m'
_color_reset=$'\033[0m'
_color_cyan=$'\033[35m'

# ==================================================================
# = Environment variables =
# ==================================================================
# zsh-only env setup (path dedup, ~/.private-env, TMPPREFIX) stays in
# config/shell/zsh/zshrc.zsh; everything here must work in bash too.

# Commonly used directories.
dev="$HOME/Developer"
pm="$dev/personal"

export NODE_REPL_HISTORY=''
export OLLAMA_NOHISTORY=1
export OLLAMA_NO_CLOUD=1
export DO_NOT_TRACK=1
export GH_TELEMETRY=disabled
export JSBT_FAST=0.5
export JSBT_QUIET=1
export MSHOULD_FAST=12
export MSHOULD_WORKERS=50%
export MSHOULD_QUIET=1

export BAT_STYLE='-numbers'


# Don't print rubbish when SSH disconnects due to bad connection
ssh() {
  command ssh "$@"
  local rc=$?

  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l' > /dev/tty

  return $rc
}

if [ -f "/opt/homebrew/bin/brew" ] && [ -z "${HOMEBREW_PREFIX:-}" ]; then
  # option a): use brew shellenv - slow
  # option b): less reliable, faster
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  if [ -n "${ZSH_VERSION:-}" ]; then
    fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
    export FPATH
  fi
  eval "$(/usr/bin/env PATH_HELPER_ROOT="/opt/homebrew" /usr/libexec/path_helper -s)"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_AUTO_UPDATE_SECS='2592000' # monthly
  export HOMEBREW_NO_ENV_HINTS=1
  export HOMEBREW_CURLRC=1
fi

# User-installed tools (claude, codex, ...). zsh never reads ~/.profile, so
# this must happen here for both shells.
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# Disable the less history file.
export LESSHISTFILE='-'

export PAGER='less'

# Drop any inherited BROWSER so tools (xdg-open consumers, gh, bat, etc.)
# don't auto-launch a browser we didn't choose.
unset BROWSER

for _shared_editor in code nvim vim vi nano; do
  if is-callable "$_shared_editor"; then
    export EDITOR="$(command -v "$_shared_editor")"
    export VISUAL="$EDITOR"
    break
  fi
done
unset _shared_editor

_shared_gpg_sock="$HOME/.gnupg/S.gpg-agent.ssh"
if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "$_shared_gpg_sock" ]; then
  export SSH_AUTH_SOCK="$_shared_gpg_sock"
fi
unset _shared_gpg_sock

if [ -t 0 ]; then
  export GPG_TTY="$(tty)" # For git commit signing
fi

# bat picks light vs dark by asking the terminal for its background colour
# (an OSC 11 query) and giving up if the reply is slow. Over ssh that reply
# has to cross the network, and since TERM arrives as xterm-256color bat
# can't recognise the terminal to allow it a longer budget -- so it times out
# and quietly falls back to dark. Prefer an explicit answer forwarded by the
# client in LC_TERM_BG (sshd already accepts LC_*, the same trick iTerm2 uses
# for LC_TERMINAL); probe only when nobody told us.
#
# BAT_THEME has to name a real theme: unlike --theme it does not accept the
# "light"/"dark" aliases, and warns "Unknown theme" if given one.
#
# delta needs the same answer, and needs it twice over: it has its own OSC 11
# probe for the diff backgrounds (with the same ssh timeout), but its
# syntax-theme just reads BAT_THEME -- so detection alone flips the +/- hunk
# backgrounds and leaves the code inside them highlighted for the other one.
# The `+` prefix adds to the features from gitconfig, keeping navigate = true.
# Nothing produces LC_TERM_BG on its own: it is our own name, not something any
# terminal implements. iTerm2 really does export LC_TERMINAL, which is why that
# trick works for free; Ghostty exports TERM/GHOSTTY_* and nothing about the
# background. So the client end has to answer. `defaults` exists only on macOS
# and only a non-ssh shell sits at a real terminal, so the two tests together
# scope this to the laptop. This tracks the system appearance, which is right
# when Ghostty is configured `theme = light:...,dark:...`; if yours is pinned to
# one theme, replace the whole block with a plain export of that value.
if [ -z "${SSH_CONNECTION:-}" ] && is-callable defaults; then
  if [ "$(command defaults read -g AppleInterfaceStyle 2>/dev/null)" = 'Dark' ]; then
    export LC_TERM_BG=dark
  else
    export LC_TERM_BG=light
  fi
fi

# Herdr's persistent server keeps the environment from the SSH login that
# originally started it, so even brand-new panes otherwise inherit a stale
# LC_TERM_BG after a later client reconnects. Cache the value seen by each
# ordinary SSH login, then let shells spawned inside Herdr recover the newest
# value. If multiple SSH clients are connected, the most recent login wins.
_term_bg_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
_term_bg_cache="$_term_bg_cache_dir/terminal-background"
if [ -n "${SSH_CONNECTION:-}" ] && [ -z "${HERDR_ENV:-}" ]; then
  case "${LC_TERM_BG:-}" in
    light|dark)
      if [ -d "$_term_bg_cache_dir" ] || mkdir -m 700 -p "$_term_bg_cache_dir" 2>/dev/null; then
        printf '%s\n' "$LC_TERM_BG" >| "$_term_bg_cache" 2>/dev/null
        chmod 600 "$_term_bg_cache" 2>/dev/null
      fi
      ;;
  esac
elif [ -n "${SSH_CONNECTION:-}" ] && [ -n "${HERDR_ENV:-}" ] && [ -r "$_term_bg_cache" ]; then
  _term_bg_cached="$(command cat "$_term_bg_cache" 2>/dev/null)"
  case "$_term_bg_cached" in
    light|dark) export LC_TERM_BG="$_term_bg_cached" ;;
  esac
  unset _term_bg_cached
fi
unset _term_bg_cache _term_bg_cache_dir

export BAT_THEME_LIGHT="Monokai Extended Light"
export BAT_THEME_DARK="Monokai Extended"
case "${LC_TERM_BG:-}" in
  light) export BAT_THEME="$BAT_THEME_LIGHT"; export DELTA_FEATURES="+light-mode" ;;
  dark)  export BAT_THEME="$BAT_THEME_DARK";  export DELTA_FEATURES="+dark-mode"  ;;
  *)     export BAT_THEME="$BAT_THEME_DARK";  export DELTA_FEATURES="+dark-mode"  ;;
esac

# ==================================================================
# = OS-specific aliases =
# ==================================================================
if [[ "$OSTYPE" == darwin* ]]; then
  alias paste=pbpaste
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
else
  alias ctl='systemctl'
  alias jctl='journalctl'
  alias o='xdg-open'

  if [[ -n "${WAYLAND_DISPLAY:-}" ]] && is-callable wl-copy; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste --no-newline'
  elif is-callable xclip; then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif is-callable xsel; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

if is-callable batcat; then
  alias bat=batcat
fi

# ==================================================================
# = Shortcuts =
# ==================================================================
alias cl='clear'
alias py_serve='python3 -m http.server --bind 127.0.0.1'
alias net="ping google.com | grep -E --color=never '[0-9\.]+ ms'"

# Searches command history. Usage: "hist git"
hist() {
  if [ -n "$ZSH_VERSION" ]; then
    history 0 | grep "$@"
  else
    history | grep "$@"
  fi
}

# ==================================================================
# = Node.js =
# ==================================================================
alias ni='npm install'
alias nr='node --run'
alias nt='node --run test'
alias nrb='node --run build'
alias bench='node --run benchmark'
alias npm-dry='npm pack --dry-run'
alias jsr-dry='jsr publish --dry-run'
alias npm-reinstall='rm package-lock.json; rm -r node_modules; npm install'
alias remove-node-modules="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"

# ==================================================================
# = Listing files =
# ==================================================================
if command ls --group-directories-first -d . > /dev/null 2>&1; then
  _ls_cmd='ls --group-directories-first'

  if is-callable dircolors; then
    if [[ -s "$HOME/.dir_colors" ]]; then
      eval "$(dircolors "$HOME/.dir_colors")"
    else
      eval "$(dircolors)"
    fi
  fi

  alias ls="$_ls_cmd --color=auto"
  unset _ls_cmd
else
  # BSD Core Utilities
  export LSCOLORS='exfxcxdxbxGxDxabagacad'
  export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
  alias ls='ls -G'
fi

alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias sl='ls'            # I often screw this up.
alias grep='grep --color=auto'

# ==================================================================
# = diff =
# ==================================================================
diff() {
  if is-callable git; then
    git --no-pager diff --color=auto --no-ext-diff --no-index "$@"
  else
    command diff "$@"
  fi
}

# ==================================================================
# = Git =
# ==================================================================
_git_with_utc_dates() {
  local ndate
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE="${GIT_AUTHOR_DATE:-$ndate}" \
  GIT_COMMITTER_DATE="${GIT_COMMITTER_DATE:-$ndate}" \
    command git "$@"
}

gm() {
  _git_with_utc_dates merge "$@"
}

gu() {
  _git_with_utc_dates pull "$@"
}

alias g='git'
alias ga='git add'
alias gd='git diff'
alias gf='git fetch'
alias gp='git push'
alias gs='git status --short'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
alias gcl='git clone'
alias gch='git checkout'
alias gds='git diff --staged'
alias gdisc='git reset --hard HEAD'
alias git_authors='git log --no-merges --pretty="format:%an <%ae>" | sort | uniq -c | sort -r'
alias git_timezones="git log --pretty='format:%an %ad' --date=format:'%z' | sort | uniq -c | sort -r"
alias git_submodules='git submodule update --init --recursive'

gback() {
  local subj
  local red="$_color_red" reset="$_color_reset"
  [ -t 1 ] || { red=''; reset=''; }
  subj=$(git log -1 --format='%s')
  printf 'reverting commit\n%s%s%s\n\n' "$red" "$subj" "$reset"
  git reset HEAD~1
}

gc() {
  _git_with_utc_dates commit -m "$*"
}

gcam() {
  _git_with_utc_dates commit --amend -m "$*"
}

gcp() {
  _git_with_utc_dates commit -am "$*" && _git_with_utc_dates push -u origin
}

pushwork() {
  local base branch commit remote_ref suffix=1
  local red="$_color_red" reset="$_color_reset"

  base="$(date +%m%d)-wip" || return 1
  branch="$base"
  while :; do
    if command git show-ref --quiet --verify "refs/heads/$branch" ||
      command git show-ref --quiet --verify "refs/remotes/origin/$branch"; then
      :
    else
      remote_ref="$(command git ls-remote --heads origin "refs/heads/$branch" 2>/dev/null)" ||
        return 1
      [ -n "$remote_ref" ] || break
    fi
    suffix=$((suffix + 1))
    branch="${base}-${suffix}"
  done

  command git switch -c "$branch" >/dev/null 2>&1 || return 1
  command git add -A >/dev/null 2>&1 || return 1
  _git_with_utc_dates commit -m 'WIP' >/dev/null 2>&1 || return 1
  command git push -u origin "$branch" >/dev/null 2>&1 || return 1
  commit="$(command git rev-parse --short=8 HEAD)" || return 1

  [ -t 1 ] || { red=''; reset=''; }
  printf '%s%s%s pushed to %s\n' "$red" "$commit" "$reset" "$branch"
}

pullwork() {
  local day="$1" base ref name suffix refs found=0

  case "$day" in
    [0-9][0-9][0-9][0-9]) ;;
    *)
      echo 'Usage: pullwork <MMDD>' >&2
      return 2
      ;;
  esac

  command git pull --ff-only || return 1

  base="${day}-wip"
  refs="$(command git for-each-ref --sort=version:refname --format='%(refname)' \
    "refs/remotes/origin/${base}*")" || return 1
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    name="${ref#refs/remotes/origin/}"
    if [ "$name" != "$base" ]; then
      suffix="${name#"${base}-"}"
      case "$suffix" in
        '' | *[!0-9]*) continue ;;
      esac
      [ "$suffix" -ge 2 ] || continue
    fi
    found=1
    command git cherry-pick --no-commit "HEAD..origin/$name" || return 1
  done <<EOF
$refs
EOF

  if [ "$found" -eq 0 ]; then
    echo "pullwork: no branches found for $day" >&2
    return 1
  fi
}

git_resign() {
  local old_head new_commits commit commit_object unsigned=0

  old_head="$(command git rev-parse --verify HEAD)" || return 1
  command git pull || return 1
  if ! command git merge-base --is-ancestor "$old_head" HEAD; then
    echo 'git_resign: pull did not fast-forward the current history' >&2
    return 1
  fi

  new_commits="$(command git rev-list --reverse "${old_head}..HEAD")" || return 1
  [ -n "$new_commits" ] || return 0
  while IFS= read -r commit; do
    commit_object="$(command git cat-file commit "$commit")" || return 1
    case "$commit_object" in
      *$'\ngpgsig '* | *$'\ngpgsig-sha256 '*) ;;
      *)
        unsigned=1
        break
        ;;
    esac
  done <<EOF
$new_commits
EOF

  [ "$unsigned" -eq 1 ] || return 0
  command git rebase --force-rebase --rebase-merges --gpg-sign "$old_head" || return 1

  new_commits="$(command git rev-list "${old_head}..HEAD")" || return 1
  while IFS= read -r commit; do
    commit_object="$(command git cat-file commit "$commit")" || return 1
    case "$commit_object" in
      *$'\ngpgsig '* | *$'\ngpgsig-sha256 '*) ;;
      *)
        echo "git_resign: failed to sign commit $commit" >&2
        return 1
        ;;
    esac
  done <<EOF
$new_commits
EOF
}

gl() {
  local count=10 requested current_year
  local gray="$_color_gray" green="$_color_green" blue="$_color_blue" reset="$_color_reset"
  [ -t 1 ] || { gray=''; green=''; blue=''; reset=''; }
  current_year="$(date +%y)"

  case "${1-}" in
    -[0-9]*)
      requested="${1#-}"
      case "$requested" in
        *[!0-9]*) ;;
        *) count="$requested"; shift ;;
      esac
      ;;
  esac

  git --no-pager log -n "$count" --date=format:'%-m/%-d/%y' --format='%h%x1c%G?%x1c%aN%x1c%aE%x1c%GS%x1c%s%x1c%ad' "$@" |
    awk -v gray="$gray" -v green="$green" -v blue="$blue" -v reset="$reset" -v current_year="$current_year" '
      BEGIN { FS = sprintf("%c", 28) }
      {
        valid = ($2 == "G" || $2 == "U")
        mine = ($3 == "ME" && index($5, "<" $4 ">") != 0)
        checkbox = (valid && mine) ? green "✓" reset " " : ""
        author = ($3 == "ME") ? "" : " " gray $3 reset
        display_date = $7
        sub("/" current_year "$", "", display_date)
        printf "%s%s%s %s%s %s(%s)%s%s\n", gray, $1, reset, checkbox, $6, blue, display_date, reset, author
      }
    '
}

git_release() {
  local tag="$1" version npm_name npm_check npm_status notes_mode notes

  if [ -z "$tag" ]; then
    echo 'Usage: git_release <tag>' >&2
    return 2
  fi

  if [ ! -f package.json ]; then
    echo 'git_release: no package.json in current directory' >&2
    return 1
  fi
  version="$(node -p 'require("./package.json").version')" || return 1
  if [ "${tag#v}" != "$version" ]; then
    echo "git_release: tag $tag does not match package.json version $version" >&2
    return 1
  fi
  if [ -f jsr.json ]; then
    version="$(node -p 'require("./jsr.json").version')" || return 1
    if [ "${tag#v}" != "$version" ]; then
      echo "git_release: tag $tag does not match jsr.json version $version" >&2
      return 1
    fi

    node <<'NODE' || return 1
const npm = require('./package.json');
const jsr = require('./jsr.json');

const fail = (message) => {
  console.error(`git_release: ${message}`);
  process.exitCode = 1;
};
const shortName = (name) => name.split('/').pop();
const sortedEntries = (entries) =>
  entries.sort(([nameA, rangeA], [nameB, rangeB]) =>
    nameA === nameB ? String(rangeA).localeCompare(String(rangeB)) : nameA.localeCompare(nameB)
  );

if (shortName(npm.name) !== shortName(jsr.name)) {
  fail(`package names do not match: ${npm.name} != ${jsr.name}`);
}

const npmDeps = sortedEntries(
  Object.entries(npm.dependencies || {}).map(([name, range]) => [shortName(name), range])
);
const jsrDeps = sortedEntries(
  Object.values(jsr.imports || {}).map((specifier) => {
    const match = /^(?:jsr|npm):((?:@[^/]+\/)?[^@/]+)@(.+)$/.exec(specifier);
    if (!match) throw new Error(`unsupported jsr.json import: ${specifier}`);
    return [shortName(match[1]), match[2]];
  })
);
if (JSON.stringify(npmDeps) !== JSON.stringify(jsrDeps)) {
  fail(
    `dependencies do not match:\n` +
      `  package.json: ${JSON.stringify(npmDeps)}\n` +
      `  jsr.json:     ${JSON.stringify(jsrDeps)}`
  );
}

const exportNames = (exports) => {
  if (exports == null) return [];
  if (typeof exports === 'string') return ['.'];
  const names = Object.keys(exports);
  return (names.some((name) => name.startsWith('.')) ? names : ['.']).sort();
};
const npmExports = exportNames(npm.exports);
const jsrExports = exportNames(jsr.exports);
if (JSON.stringify(npmExports) !== JSON.stringify(jsrExports)) {
  fail(
    `exports do not match:\n` +
      `  package.json: ${JSON.stringify(npmExports)}\n` +
      `  jsr.json:     ${JSON.stringify(jsrExports)}`
  );
}
NODE
  fi

  version="$(node -p 'require("./package.json").version')" || return 1
  npm_name="$(node -p 'require("./package.json").name')" || return 1
  npm_check="$(npm view "${npm_name}@${version}" version 2>&1)"
  npm_status=$?
  if [ "$npm_status" -eq 0 ]; then
    echo "git_release: ${npm_name}@${version} already exists on npm" >&2
    return 1
  fi
  case "$npm_check" in
    *E404*) ;;
    *)
      echo "$npm_check" >&2
      echo "git_release: could not check ${npm_name}@${version} on npm" >&2
      return 1
      ;;
  esac

  npm ci || return 1

  printf 'Release notes: 1) plaintext 2) file 3) generate\nChoice [1-3]: '
  read -r notes_mode
  case "$notes_mode" in
    1)
      printf 'Notes: '
      read -r notes
      ;;
    2)
      printf 'Notes file: '
      read -r notes
      if [ ! -f "$notes" ]; then
        echo "git_release: file not found: $notes" >&2
        return 1
      fi
      ;;
    3) ;;
    *)
      echo 'git_release: invalid choice' >&2
      return 2
      ;;
  esac

  echo "... releasing $tag"
  _git_with_utc_dates commit -a -m "Release $tag." &&
    _git_with_utc_dates tag -s -m '' -- "$tag" &&
    command git push &&
    command git push --tags &&
    case "$notes_mode" in
      1) gh release create "$tag" --notes "$notes" ;;
      2) gh release create "$tag" -F "$notes" ;;
      3) gh release create "$tag" --generate-notes ;;
    esac &&
    echo '... complete'
}

git_rmtag() {
  local tag="$1"
  if [ -z "$tag" ]; then
    echo 'Usage: grmtag <tag>' >&2
    return 2
  fi

  git tag -d -- "$tag"
  git push origin ":refs/tags/${tag}"
}

git_cherry() {
  local commit total
  local -a commits

  commits=()
  if [ $# -eq 1 ]; then
    case "$1" in
      *.*)
        while IFS= read -r commit; do
          commits+=("$commit")
        done < <(git rev-list --reverse --topo-order "$1")
        ;;
      *)
        commits=("$1")
        ;;
    esac
  else
    commits=("$@")
  fi

  total=${#commits[@]}
  echo "Picking $total commits:"
  for commit in "${commits[@]}"; do
    echo "$commit"
    git cherry-pick -n -- "$commit" || break
  done
}
alias cherry=git_cherry

git_raw() {
  local hash name email author_date committer_date title sep
  local red="$_color_red" green="$_color_green" yellow="$_color_yellow" reset="$_color_reset"
  [ -t 1 ] || { red=''; green=''; yellow=''; reset=''; }

  sep=$(printf '\037')
  git log --pretty='tformat:%H%x1f%an%x1f%ae%x1f%ad%x1f%cd%x1f%s' --date=format:'%Y-%m-%dT%H:%M:%S%z' |
    while IFS="$sep" read -r hash name email author_date committer_date title; do
      if [ "$author_date" = "$committer_date" ]; then
        printf '%s%s%s %s %s(%s) %s%s <%s>%s\n' \
          "$red" "$hash" "$reset" "$title" \
          "$green" "$author_date" "$yellow" "$name" "$email" "$reset"
      else
        printf '%s%s%s %s %s(%s, cmt=%s) %s%s <%s>%s\n' \
          "$red" "$hash" "$reset" "$title" \
          "$green" "$author_date" "$committer_date" "$yellow" "$name" "$email" "$reset"
      fi
    done
}

ssh_tunnel() {
  local usage="usage: ssh_tunnel PORT_OURS PORT_THEIRS HOST
sshtunnel 1234 5678 example.com"
  local port_ours="${1:-}"
  local port_theirs="${2:-}"
  local hostn="${3:-}"
  local all

  if ! [[ "$port_ours" =~ ^[0-9]+$ ]] || ! [[ "$port_theirs" =~ ^[0-9]+$ ]] || [ -z "$hostn" ]; then
    printf '%s\n' "$usage"
    return 1
  fi

  if [ "$port_ours" -lt 1 ] || [ "$port_ours" -gt 65535 ] || [ "$port_theirs" -lt 1 ] || [ "$port_theirs" -gt 65535 ]; then
    printf '%s\n' "$usage"
    return 1
  fi

  all="$port_ours:127.0.0.1:$port_theirs"
  echo "Tunnelling $all on $hostn"
  ssh -L "$all" -- "$hostn"
}

# ==================================================================
# = Functions =
# ==================================================================

# Opens file in EDITOR.
edit() {
  local dir="${1:-.}"
  local -a editor_cmd

  eval "editor_cmd=(${EDITOR:-vi})"
  command "${editor_cmd[@]}" -- "$dir"
}
alias e=edit

# Execute commands for each directory in the current directory.
each() {
  local dir

  if [ $# -eq 0 ]; then
    echo 'Usage: each <command> [args...]' >&2
    return 2
  fi

  if [ -n "$ZSH_VERSION" ]; then
    setopt local_options null_glob
  fi

  for dir in */; do
    [ -d "$dir" ] || continue
    ( builtin cd -- "$dir" && "$@" )
  done
}

# Better find(1)
ff() {
  find . -iname "*${1:-}*"
}

# Pretty-print JSON.
# $ curl http://site/v1/api.json | json
json() {
  if is-callable jq; then
    jq . "$@"
  elif is-callable python3; then
    python3 -m json.tool "$@"
  elif is-callable node; then
    node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.stringify(JSON.parse(d),null,2)))' < "${1:-/dev/stdin}"
  else
    echo 'json: jq, python3 or node is required' >&2
    return 1
  fi
}

# Quick backups: `bak file` copies to file.bak, `unbak file.bak` restores.
bak() {
  local f

  if [ $# -eq 0 ]; then
    echo 'Usage: bak <path>...' >&2
    return 2
  fi
  for f in "$@"; do
    if [ ! -e "$f" ] && [ ! -L "$f" ]; then
      echo "bak: no such path: $f" >&2
      return 1
    fi
    cp -a -- "$f" "$f.bak" || return
  done
}

unbak() {
  local f

  if [ $# -eq 0 ]; then
    echo 'Usage: unbak <path.bak>...' >&2
    return 2
  fi
  for f in "$@"; do
    case "$f" in
      *.bak) ;;
      *)
        echo "unbak: not a .bak path: $f" >&2
        return 1
        ;;
    esac
    if [ ! -e "$f" ] && [ ! -L "$f" ]; then
      echo "unbak: no such path: $f" >&2
      return 1
    fi
    mv -- "$f" "${f%.bak}" || return
  done
}

# Public IP. Uses DNS when dig is available, HTTPS otherwise.
ip_public() {
  local ip=''

  if is-callable dig; then
    ip=$(dig +short myip.opendns.com @resolver1.opendns.com A 2> /dev/null)
  fi
  if [ -z "$ip" ] && is-callable curl; then
    ip=$(curl -fsS --max-time 5 https://ifconfig.me 2> /dev/null)
  fi
  if [ -z "$ip" ]; then
    echo 'myip: could not determine public IP' >&2
    return 1
  fi
  printf '%s\n' "$ip"
}

# Local (LAN) IP addresses.
ip_local() {
  local iface ip

  if [[ "$OSTYPE" == darwin* ]]; then
    for iface in en0 en1 en2; do
      if ip=$(ipconfig getifaddr "$iface" 2> /dev/null); then
        printf '%s\n' "$iface: $ip"
      fi
    done
    return 0
  fi

  if is-callable ip; then
    command ip -4 -brief addr show scope global 2> /dev/null | awk '{print $1": "$3}'
  elif is-callable hostname; then
    hostname -I 2> /dev/null
  else
    echo 'localip: no supported tool found' >&2
    return 1
  fi
}

# Listening TCP/UDP ports with owning processes.
ports() {
  if [[ "$OSTYPE" == darwin* ]]; then
    lsof -iTCP -sTCP:LISTEN -P -n
  elif is-callable ss; then
    ss -tulpn
  else
    netstat -tulpn
  fi
}

# Command-line calculator. `calc` opens zcalc (zsh only); `calc 2*21` evaluates.
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz zcalc 2> /dev/null
fi

calc() {
  if [ $# -eq 0 ]; then
    if [ -n "$ZSH_VERSION" ]; then
      zcalc
    else
      echo 'calc: interactive mode requires zsh (zcalc)' >&2
      return 1
    fi
  else
    printf '%s\n' "$(( $* ))"
  fi
}

if [ -n "$ZSH_VERSION" ]; then
  unalias calc 2> /dev/null
  alias calc='noglob calc'
fi

_calcram_kib() {
  local app="$1"
  local snapshot

  if [ -z "$app" ]; then
    return 2
  fi

  case "$app" in
    ''|*[!0-9]*)
      # Not all-digits: treat as a case-insensitive command substring.
      # `ps` runs to completion into $snapshot before grep/awk start, so
      # their own argv (which contains $app) can never show up as a process
      # in the listing being searched (the classic `ps | grep foo` self-match).
      snapshot=$(ps axww -o rss= -o command=)
      printf '%s\n' "$snapshot" | grep -iF -- "$app" | awk '{sum+=$1} END{print sum+0}'
      ;;
    *)
      # All-digits: treat as a PID.
      ps -o rss= -p "$app" 2> /dev/null | awk '{sum+=$1} END{print sum+0}'
      ;;
  esac
}

_ram_format_mib() {
  local kib="${1:-0}"
  awk -v k="$kib" 'BEGIN { printf "%.2f", k / 1024 }'
}

_calcram() {
  local kib
  kib=$(_calcram_kib "$1") || return
  _ram_format_mib "$kib"
}

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MiB of RAM
# $ ram 1234
# # => 1234 uses 12.30 MiB of RAM
ram() {
  local kib sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - process name, command substring, or PID"
    return 0
  fi

  local blue="$_color_blue" green="$_color_green" reset="$_color_reset"
  [ -t 1 ] || { blue=''; green=''; reset=''; }

  kib=$(_calcram_kib "$app") || return
  sum=$(_ram_format_mib "$kib")
  if [ "$kib" -gt 0 ]; then
    echo "${blue}${app}${reset} uses ${green}${sum}${reset} MiB of RAM"
  else
    echo "No active process found for '${blue}${app}${reset}'"
  fi
}

# Same, but tracks RAM usage in realtime. Will run until you stop it.
# $ ram-streaming safari
# $ ram-streaming 1234
ram-streaming() {
  local kib sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - process name, command substring, or PID"
    return 0
  fi

  # On a tty, redraw one line in place; when piped, emit plain lines.
  local blue="$_color_blue" green="$_color_green" reset="$_color_reset"
  local redraw=$'\r\033[K' eol=''
  if ! [ -t 1 ]; then
    blue=''; green=''; reset=''
    redraw=''; eol=$'\n'
  fi

  while true; do
    kib=$(_calcram_kib "$app") || return
    sum=$(_ram_format_mib "$kib")
    if [ "$kib" -gt 0 ]; then
      printf '%s%s uses %s MiB of RAM%s' "$redraw" "${blue}${app}${reset}" "${green}${sum}${reset}" "$eol"
    else
      printf '%sNo active process found for %s%s' "$redraw" "'${blue}${app}${reset}'" "$eol"
    fi
    sleep 0.1
  done
}

# $ size dir1 file2.js
size() {
  du -shck "$@" | sort -rn | awk '
      function human(x) {
          s="kMGTEPYZ";
          while (x>=1000 && length(s)>1)
              {x/=1024; s=substr(s,2)}
          return int(x+0.5) substr(s,1,1)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
}

# 4 lulz.
compute() {
  while true; do head -n 100 /dev/urandom; sleep 0.1; done \
    | hexdump -C | grep "ca fe"
}

# Load all CPU cores at once.
maxcpu() {
  local dn=/dev/null
  local cores i

  cores=$(nproc 2> /dev/null || getconf _NPROCESSORS_ONLN 2> /dev/null || sysctl -n hw.ncpu 2> /dev/null)
  if [ -z "$cores" ] || [ "$cores" -lt 1 ]; then
    echo 'maxcpu: unable to determine CPU core count' >&2
    return 1
  fi
  i=0
  while [ "$i" -lt "$cores" ]; do
    yes > "$dn" &
    i=$(( i + 1 ))
  done
  echo "Loaded $cores cores. To stop: 'killall yes'"
}

# ==================================================================
# = Simple tar archiving and extraction =
# ==================================================================
_tar_require_one_path() {
  local usage="$1"
  shift

  if [ $# -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: $usage" >&2
    return 2
  fi
}

_tar_require_existing_path() {
  local path="$1"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    echo "No such path: $path" >&2
    return 1
  fi
}

_tar_reject_unsafe_members() {
  local archive="$1"
  local listing
  local verbose_listing
  shift

  if ! listing=$(tar "$@" -t -f "$archive"); then
    return 1
  fi

  _tar_reject_unsafe_member_names "$listing" || return

  if ! verbose_listing=$(tar "$@" -t -v -f "$archive"); then
    return 1
  fi

  _tar_reject_unsafe_member_types "$verbose_listing"
}

_tar_reject_unsafe_member_names() {
  local listing="$1"
  local member

  while IFS= read -r member; do
    if [[ "$member" == /* || "$member" == .. || "$member" == ../* || "$member" == */.. || "$member" == */../* ]]; then
      echo "Refusing to extract unsafe archive member: $member" >&2
      return 1
    fi
  done <<<"$listing"
}

_tar_reject_unsafe_member_types() {
  local listing="$1"
  local member

  while IFS= read -r member; do
    case "$member" in
      l*|h*|b*|c*|p*)
        echo "Refusing to extract archive with special member: $member" >&2
        return 1
        ;;
    esac
  done <<<"$listing"
}

_tar_safe_extract() {
  local archive="$1"
  shift

  _tar_require_existing_path "$archive" || return
  _tar_reject_unsafe_members "$archive" "$@" || return
  tar "$@" -x -v -k -o -f "$archive"
}

_tar_safe_extract_pbzip2() {
  local archive="$1"
  local listing
  local verbose_listing
  _tar_require_existing_path "$archive" || return

  if ! listing=$(set -o pipefail; pbzip2 -d -c -- "$archive" | tar -t -f -); then
    return 1
  fi
  _tar_reject_unsafe_member_names "$listing" || return

  if ! verbose_listing=$(set -o pipefail; pbzip2 -d -c -- "$archive" | tar -t -v -f -); then
    return 1
  fi
  _tar_reject_unsafe_member_types "$verbose_listing" || return

  if ! (set -o pipefail; pbzip2 -d -c -- "$archive" | tar -x -v -k -o -f -); then
    return 1
  fi
}

_tar_require_bzip2() {
  if ! is-callable pbzip2 && ! is-callable bzip2; then
    echo "bzip2 or pbzip2 is required for .tar.bz2 archives" >&2
    return 1
  fi
}

tar_() {
  _tar_require_one_path "tar_ <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  tar -c -v -f "$1.tar" -- "$1"
}

untar() {
  _tar_require_one_path "untar <archive.tar>" "$@" || return
  _tar_safe_extract "$1"
}

tar_nometa() {
  local src name stage status

  _tar_require_one_path "tar_nometa <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  src="$1"

  if [[ "$OSTYPE" != darwin* ]]; then
    echo 'tar_nometa requires macOS (ditto, xattr, dot_clean)' >&2
    return 1
  fi
  if [[ -e archive.tar || -L archive.tar ]]; then
    echo 'Refusing to overwrite existing archive.tar' >&2
    return 1
  fi

  name=$(basename -- "$src") || return
  stage=$(mktemp -d) || return

  (
    # Copy without macOS metadata where possible.
    ditto --norsrc --noextattr --noacl "$src" "$stage/$name" &&

    # Strip filesystem metadata from the staging copy.
    chflags -R 0 "$stage/$name" &&
    xattr -cr "$stage/$name" &&
    chmod -RN "$stage/$name" &&
    dot_clean -m "$stage/$name" &&

    # Remove Finder/AppleDouble sidecar files.
    find "$stage/$name" -name .DS_Store -type f -delete &&
    find "$stage/$name" -name '._*' -type f -delete &&

    # Normalize permissions and mtimes too.
    find "$stage/$name" -type d -exec chmod 755 {} + &&
    find "$stage/$name" -type f -exec chmod 644 {} + &&
    TZ=UTC find "$stage/$name" -exec touch -h -t 197001010000.00 {} + &&

    # Pack with tar
    COPYFILE_DISABLE=1 tar \
      --format=ustar \
      --numeric-owner \
      --uid 0 \
      --gid 0 \
      --no-acls \
      --no-xattrs \
      --no-fflags \
      --no-mac-metadata \
      -cf archive.tar \
      -C "$stage" "$name" &&

    # Remove tar metadata
    TZ=UTC touch -h -t 197001010000.00 archive.tar &&
    echo archive.tar created
  )
  status=$?
  rm -rf -- "$stage"
  return $status
}

# Managing .tar.bz2 archives - best compression.
tarbz2() {
  _tar_require_one_path "tarbz2 <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  _tar_require_bzip2 || return
  local inf="$1"
  local outf="$1.tar.bz2"

  # Use parallel version when it exists.
  if is-callable pbzip2; then
    if ! (set -o pipefail; tar -c -v -f - -- "$inf" | pbzip2 -c > "$outf"); then
      return 1
    fi
  else
    tar -c -v -j -f "$outf" -- "$inf"
  fi
}

tarxz() {
  _tar_require_one_path "tarxz <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  local inf="$1"
  local outf="$1.tar.xz"
  XZ_OPT=-9 tar -c -v -J -f "$outf" -- "$inf"
}

untarbz2() {
  _tar_require_one_path "untarbz2 <archive.tar.bz2>" "$@" || return
  _tar_require_existing_path "$1" || return
  _tar_require_bzip2 || return

  if is-callable pbzip2; then
    _tar_safe_extract_pbzip2 "$1"
  else
    _tar_safe_extract "$1" -j
  fi
}

untarxz() {
  _tar_require_one_path "untarxz <archive.tar.xz>" "$@" || return
  _tar_safe_extract "$1" -J
}

# Extract any archive type; tar formats go through the hardened helpers.
extract() {
  local f="${1:-}"
  local f_lc

  if [ $# -ne 1 ] || [ -z "$f" ]; then
    echo 'Usage: extract <archive>' >&2
    return 2
  fi
  _tar_require_existing_path "$f" || return

  f_lc=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')

  case "$f_lc" in
    *.tar.bz2|*.tbz|*.tbz2) untarbz2 "$f" ;;
    *.tar.xz|*.txz) untarxz "$f" ;;
    *.tar.gz|*.tgz) _tar_safe_extract "$f" -z ;;
    *.tar) untar "$f" ;;
    *.zip) unzip "$f" ;;
    *.gz) gunzip -k "$f" ;;
    *.bz2) bunzip2 -k "$f" ;;
    *.xz) unxz -k "$f" ;;
    *.7z)
      if is-callable 7zz; then
        7zz x "$f"
      elif is-callable 7z; then
        7z x "$f"
      else
        echo 'extract: 7z is required' >&2
        return 1
      fi
      ;;
    *)
      echo "extract: unsupported archive type: $f" >&2
      return 1
      ;;
  esac
}
