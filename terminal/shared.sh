# Shared environment variables, aliases and functions, sourced by both
# zsh (via .zshrc.sh) and bash.
#
# Kept bash/zsh-compatible on purpose: no zsh-only parameter-expansion flags
# (${(z)}, ${(f)}, ${(L)}, ...), glob qualifiers, or emulate/setopt calls,
# except where explicitly guarded by `[ -n "$ZSH_VERSION" ]`. Prefer plain
# `[ ]`/`[[ ]]`, `case`, and `read` over shell-specific string/array tricks
# so this file behaves the same way in both shells.

# ==================================================================
# = Shell options =
# ==================================================================

# Don't let `>` clobber an existing file; use `>|` to force (portable).
# `set -o` is POSIX, so unlike `setopt` it applies in both bash and zsh.
# (In zsh this also blocks `>>` from creating a new file.)
set -o noclobber

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
_color_reset=$'\033[0m'

# ==================================================================
# = Environment variables =
# ==================================================================
# zsh-only env setup (path dedup, ~/.private-env, TMPPREFIX) stays in
# home/.zshrc.sh; everything here must work in bash too.

# Commonly used directories.
dev="$HOME/Developer"
pm="$dev/personal"

export NODE_REPL_HISTORY=''
export OLLAMA_NOHISTORY=1
export OLLAMA_NO_CLOUD=1
export JSBT_FAST=0.5
export JSBT_QUIET=1
export MSHOULD_FAST=12
export MSHOULD_QUIET=1

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

gl() {
  git --no-pager log -10 --graph
}

git_release() {
  local tag="$1"

  if [ -z "$tag" ]; then
    echo 'Usage: git_release <tag>' >&2
    return 2
  fi

  echo "... releasing $tag"
  _git_with_utc_dates commit -a -m "Release $tag." &&
    _git_with_utc_dates tag -m '' -- "$tag" &&
    command git push &&
    command git push --tags &&
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
