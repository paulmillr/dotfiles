#!/usr/bin/env zsh

curr="$pm/dotfiles"

# Load main files.
# To benchmark startup: brew install coreutils, uncomment lines
# echo "Load start\t" $(gdate "+%s-%N")
source "$curr/terminal/startup.sh"
source "$curr/terminal/completion.sh"
source "$curr/terminal/highlight.sh"
# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$curr/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'pm'

# The icrnl setting tells the terminal driver in the kernel to convert the CR character
# to LF on input. This way, applications only need to worry about one newline character;
# the same newline character that ends lines in files also ends lines of user input on
# the terminal, so the application doesn't need to have a special case for that.
# Fixes <Return> key bugs with some secure keyboards etc
stty icrnl
export GPG_TTY=$(tty) # For git commit signing

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
function gback() {
  subj=$(git log -1 --format='%s')
  echo "reverting ${fg[yellow]}${subj}${reset_color}"
  git reset HEAD~1
}
function gc() {
  args=$@
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE=$ndate GIT_COMMITTER_DATE=$ndate git commit -m "$args"
}
function gcam() {
  args=$@
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE=$ndate GIT_COMMITTER_DATE=$ndate git commit --amend -m "$args"
}
function gcp() {
  title="$@"
  ndate=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  GIT_AUTHOR_DATE=$ndate GIT_COMMITTER_DATE=$ndate git commit -am $title && git push -u origin
}
function gl() {
  git --no-pager log -10 --graph
}
function grmtag() {
  tag=$1
  git tag -d $tag
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
    log=$(git rev-list --reverse --topo-order $1 | xargs)
    setopt sh_word_split 2> /dev/null # Ignore for `sh`.
    commits=(${log}) # Convert string to array.
    unsetopt sh_word_split 2> /dev/null # Ignore for `sh`.
  else
    commits=("$@")
  fi

  total=${#commits[@]} # Get last array index.
  echo "Picking $total commits:"
  for commit in ${commits[@]}; do
    echo $commit
    git cherry-pick -n $commit || break
    [[ CC -eq 1 ]] && cherrycc $commit
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
  [[ -z "$dir" ]] && dir='.'
  $EDITOR $dir
}
alias e=edit

# Execute commands for each file in current directory.
function each() {
  for dir in *; do
    # echo "${dir}:"
    cd $dir
    $@
    cd ..
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

  sum=$(_calcram $app)
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
    sum=$(_calcram $app)
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

# Simple .tar archiving.
function tar_() {
  tar -cvf "$1.tar" "$1"
}

function untar() {
  tar -xvf $1
}

# Managing .tar.bz2 archives - best compression.
function tarbz2() {
  inf="$1"
  outf="$1.tar.bz2"
  # Use parallel version when it exists.
  if (( $+commands[pbzip2] )); then
    tar --use-compress-program pbzip2 -cf "$outf" "$inf"
  else
    tar -cvjf "$outf" "$inf"
  fi
}
function tarxz() {
  inf="$1"
  outf="$1.tar.xz"
  XZ_OPT=-9 tar -Jcvjf "$outf" "$inf"
}

alias untarbz2='tar -xvjf'
alias untarxz='tar -xvf'
