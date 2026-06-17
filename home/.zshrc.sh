#!/usr/bin/env zsh

if [[ -n "${pm:-}" ]]; then
  curr="$pm/dotfiles"
else
  curr=''
  print -u2 'pm is not set; skipping dotfiles startup files'
fi

function _zshrc_is_trusted_path() {
  local target="$1"
  local path
  local home
  local -A st

  if [[ -z "$target" || ( ! -e "$target" && ! -L "$target" ) ]]; then
    print -u2 "Refusing to trust missing path: $target"
    return 1
  fi

  zmodload zsh/stat 2> /dev/null || {
    print -u2 'Refusing to trust startup files: zsh/stat is unavailable'
    return 1
  }

  path="${target:A}"
  home="${HOME:A}"
  if [[ "$path" != "$home" && "$path" != "$home"/* ]]; then
    print -u2 "Refusing to trust $path: outside HOME"
    return 1
  fi

  while true; do
    zstat -H st -- "$path" || return 1

    if (( st[uid] != EUID && st[uid] != 0 )); then
      print -u2 "Refusing to trust $path: owner is neither current user nor root"
      return 1
    fi

    if (( st[mode] & 0002 )); then
      print -u2 "Refusing to trust $path: world-writable"
      return 1
    fi

    if (( (st[mode] & 0020) && st[gid] != EGID )); then
      print -u2 "Refusing to trust $path: writable by another group"
      return 1
    fi

    [[ "$path" == "$home" ]] && break
    path="${path:h}"
  done
}

function _zshrc_source_trusted() {
  local file="$1"

  _zshrc_is_trusted_path "$file" || return 1
  source -- "$file"
}

# Load main files.
# To benchmark startup: brew install coreutils, uncomment lines
# echo "Load start\t" $(gdate "+%s-%N")
if [[ -n "$curr" ]]; then
  _zshrc_source_trusted "$curr/terminal/startup.sh"
  _zshrc_source_trusted "$curr/terminal/completion.sh"
  _zshrc_source_trusted "$curr/terminal/highlight.sh"
fi
# echo "Load end\t" $(gdate "+%s-%N")

function _zshrc_colors() {
  (( ${+fg[blue]} )) || { autoload -U colors && colors }
}

# Load and execute the prompt theming system.
if [[ -n "$curr" ]] \
  && _zshrc_is_trusted_path "$curr/terminal" \
  && _zshrc_is_trusted_path "$curr/terminal/prompt_pm_setup"
then
  _zshrc_source_trusted "$curr/terminal/prompt_pm_setup"
fi

# The icrnl setting tells the terminal driver in the kernel to convert the CR character
# to LF on input. This way, applications only need to worry about one newline character;
# the same newline character that ends lines in files also ends lines of user input on
# the terminal, so the application doesn't need to have a special case for that.
# Fixes <Return> key bugs with some secure keyboards etc
if [[ -t 0 ]]; then
  stty icrnl
  export GPG_TTY="$(tty)" # For git commit signing
fi

# ==================================================================
# = Aliases =
# ==================================================================
# Some MacOS-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Short-cuts for copy-paste.
  alias p='pbpaste'

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fli'
else
  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fl'
  alias update-debian='sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y'
  alias ctl='systemctl'
  alias jctl='journalctl'
fi

# Git short-cuts.
alias g='git'
alias ga='git add'
alias gd='git diff'
alias gf='git fetch'
alias gp='git push'
alias gs='git status --short'
alias gu='git pull'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
alias gcl='git clone'
alias gch='git checkout'
alias gds='git diff --staged'
alias gdisc='git reset --hard HEAD'
alias gitnames='git log --no-merges --pretty="format:%an <%ae>" | sort | uniq -c | sort -r'
alias gitauthors='git log --no-merges --pretty="format:%an <%ae>" | sort | uniq -c | sort -r'
alias gitsubmodules='git submodule update --init --recursive'
function gback() {
  subj=$(git log -1 --format='%s')
  _zshrc_colors
  echo "reverting ${fg[yellow]}${subj}${reset_color}"
  git reset HEAD~1
}
function gc() {
  local args="$*"
  local ndate
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE="$ndate" GIT_COMMITTER_DATE="$ndate" git commit -m "$args"
}
function gcam() {
  local args="$*"
  local ndate
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE="$ndate" GIT_COMMITTER_DATE="$ndate" git commit --amend -m "$args"
}
function gcp() {
  local title="$*"
  local ndate
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE="$ndate" GIT_COMMITTER_DATE="$ndate" git commit -am "$title" && git push -u origin
}
function gl() {
  git --no-pager log -10 --graph
}
function grmtag() {
  local tag="$1"
  if [[ -z "$tag" ]]; then
    print -u2 'Usage: grmtag <tag>'
    return 2
  fi

  git tag -d -- "$tag"
  git push origin ":refs/tags/${tag}"
}


function gitcherry() {
  is_range=''
  case "$1" in # `sh`-compatible substring.
    *\.*)
    is_range='1'
  ;;
  esac
  # Check if it's one commit vs set of commits.
  if [ "$#" -eq 1 ] && [[ $is_range ]]; then
    log=$(git rev-list --reverse --topo-order "$1" | xargs)
    setopt sh_word_split 2> /dev/null # Ignore for `sh`.
    commits=(${log}) # Convert string to array.
    unsetopt sh_word_split 2> /dev/null # Ignore for `sh`.
  else
    commits=("$@")
  fi

  total=${#commits[@]} # Get last array index.
  echo "Picking $total commits:"
  for commit in "${commits[@]}"; do
    echo "$commit"
    git cherry-pick -n -- "$commit" || break
    [[ CC -eq 1 ]] && cherrycc "$commit"
  done
}
function gitdates() {
  git log --pretty="format:%ae---%ad---%cd" --date=format:'%Y-%m-%dT%H:%M:%S%z' | python3 <(cat <<END
import sys
res = []
for line in sys.stdin:
  (m, ad, cd) = line.strip().split('---')
  if ad == cd:
    res.append('{} {}'.format(m, ad))
  else:
    res.append('{} {} {}'.format(m, ad, cd))
for item in res:
  print(item)
END
)
}

# Shortcuts
alias cl='clear'
alias serve='python3 -m http.server --bind 127.0.0.1'
alias server='serve'
alias hist='history 0 | grep' # for searching command history. Usage: "hist git"
alias history-stats="history 0 | awk '{print \$2}' | sort | uniq -c | sort -r | head"
alias net="ping google.com | grep -E --color=never '[0-9\.]+ ms'"
alias remove-node-modules="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
# Node.js
alias ni='npm install'
alias nr='npm run'
alias nt='npm test'
alias nrb='npm run build'
alias nrel='npm run build && npm run build:release'
alias nrf='npm run format'
alias npm-dry='npm pack --dry-run'
alias jsr-dry='jsr publish --dry-run'
alias nibir='npm install && npm run build'


# Functions
# Opens file in EDITOR.
function edit() {
  local dir=$1
  local -a editor
  [[ -z "$dir" ]] && dir='.'
  editor=(${(z)${EDITOR:-vi}})
  command "${editor[@]}" -- "$dir"
}
alias e=edit

# Execute commands for each file in current directory.
function each() {
  local dir
  local oldpwd="$PWD"

  if (( $# == 0 )); then
    print -u2 'Usage: each <command> [args...]'
    return 2
  fi

  for dir in *(/N); do
    # echo "${dir}:"
    builtin cd -- "$dir" || continue
    "$@"
    builtin cd -- "$oldpwd" || return
  done
}

# Better find(1)
function find-file() {
  find . -iname "*${1:-}*"
}

# Find files and exec commands at them.
# $ find-exec .js cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

function _calcram() {
  local sum
  sum=0
  for i in `ps aux | grep -i "$1" | grep -v "grep" | awk '{print $6}'`; do
    sum=$(($i + $sum))
  done
  sum=$(echo "scale=2; $sum / 1024.0" | bc)
  echo $sum
}

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM
function ram() {
  local sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
    return 0
  fi

  sum=$(_calcram "$app")
  _zshrc_colors
  if [[ $sum != "0" ]]; then
    echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM"
  else
    echo "No active processes matching pattern '${fg[blue]}${app}${reset_color}'"
  fi
}

# Same, but tracks RAM usage in realtime. Will run until you stop it.
# $ ram-streaming safari
function ram-streaming() {
  local sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
    return 0
  fi

  while true; do
    sum=$(_calcram "$app")
    _zshrc_colors
    if [[ $sum != "0" ]]; then
      echo -en "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM\r"
    else
      echo -en "No active processes matching pattern '${fg[blue]}${app}${reset_color}'\r"
    fi
    sleep 0.1
  done
}

# $ size dir1 file2.js
function size() {
  # du -scBM | sort -n
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
function compute() {
  while true; do head -n 100 /dev/urandom; sleep 0.1; done \
    | hexdump -C | grep "ca fe"
}

# Load all CPU cores at once.
function maxcpu() {
  cores=$(sysctl -n hw.ncpu)
  dn=/dev/null
  i=0
  while (( i < $((cores)) )); do
    yes > $dn &
    (( ++i ))
  done
  echo "Loaded $cores cores. To stop: 'killall yes'"
}

# Simple tar archiving and extraction.
function _tar_require_one_path() {
  local usage="$1"
  shift

  if (( $# != 1 )) || [[ -z "$1" ]]; then
    print -u2 "Usage: $usage"
    return 2
  fi
}

function _tar_require_existing_path() {
  local path="$1"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    print -u2 "No such path: $path"
    return 1
  fi
}

function _tar_reject_unsafe_members() {
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

function _tar_reject_unsafe_member_names() {
  local listing="$1"
  local member

  for member in "${(@f)listing}"; do
    if [[ "$member" == /* || "$member" == .. || "$member" == ../* || "$member" == */.. || "$member" == */../* ]]; then
      print -u2 "Refusing to extract unsafe archive member: $member"
      return 1
    fi
  done
}

function _tar_reject_unsafe_member_types() {
  local listing="$1"
  local member

  for member in "${(@f)listing}"; do
    if [[ "${member[1]}" == [lhbcp] ]]; then
      print -u2 "Refusing to extract archive with special member: $member"
      return 1
    fi
  done
}

function _tar_safe_extract() {
  local archive="$1"
  shift

  _tar_require_existing_path "$archive" || return
  _tar_reject_unsafe_members "$archive" "$@" || return
  tar "$@" -x -v -k -o -f "$archive"
}

function _tar_safe_extract_pbzip2() {
  local archive="$1"
  local listing
  local verbose_listing
  _tar_require_existing_path "$archive" || return
  setopt local_options pipefail
  if ! listing=$(pbzip2 -d -c -- "$archive" | tar -t -f -); then
    return 1
  fi
  _tar_reject_unsafe_member_names "$listing" || return

  if ! verbose_listing=$(pbzip2 -d -c -- "$archive" | tar -t -v -f -); then
    return 1
  fi
  _tar_reject_unsafe_member_types "$verbose_listing" || return

  pbzip2 -d -c -- "$archive" | tar -x -v -k -o -f -
}

function _tar_require_bzip2() {
  if (( ! $+commands[pbzip2] && ! $+commands[bzip2] )); then
    print -u2 "bzip2 or pbzip2 is required for .tar.bz2 archives"
    return 1
  fi
}

function tar_() {
  _tar_require_one_path "tar_ <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  tar -c -v -f "$1.tar" -- "$1"
}

function untar() {
  _tar_require_one_path "untar <archive.tar>" "$@" || return
  _tar_safe_extract "$1"
}

# Managing .tar.bz2 archives - best compression.
function tarbz2() {
  _tar_require_one_path "tarbz2 <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  _tar_require_bzip2 || return
  local inf="$1"
  local outf="$1.tar.bz2"

  # Use parallel version when it exists.
  if (( $+commands[pbzip2] )); then
    setopt local_options pipefail
    tar -c -v -f - -- "$inf" | pbzip2 -c > "$outf"
  else
    tar -c -v -j -f "$outf" -- "$inf"
  fi
}

function tarxz() {
  _tar_require_one_path "tarxz <path>" "$@" || return
  _tar_require_existing_path "$1" || return
  local inf="$1"
  local outf="$1.tar.xz"
  XZ_OPT=-9 tar -c -v -J -f "$outf" -- "$inf"
}

function untarbz2() {
  _tar_require_one_path "untarbz2 <archive.tar.bz2>" "$@" || return
  _tar_require_existing_path "$1" || return
  _tar_require_bzip2 || return

  if (( $+commands[pbzip2] )); then
    _tar_safe_extract_pbzip2 "$1"
  else
    _tar_safe_extract "$1" -j
  fi
}

function untarxz() {
  _tar_require_one_path "untarxz <archive.tar.xz>" "$@" || return
  _tar_safe_extract "$1" -J
}

# >>> Codex installer >>>
export PATH="/home/user/.local/bin:$PATH"
# <<< Codex installer <<<
