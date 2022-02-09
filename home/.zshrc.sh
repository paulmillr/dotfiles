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
prompt 'paulmillr'

# path=(/usr/local/opt/ruby/bin $HOME/.cargo/bin $path) # changing .zshenv doesn't work
export GPG_TTY=$(tty) # For git commit signing

# ==================================================================
# = Aliases =
# ==================================================================
# Simple clear command.
alias cl='clear'

# Disable sertificate check for wget.
# alias wget='wget --no-check-certificate'

# Some MacOS-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Short-cuts for copy-paste.
  alias c='pbcopy'
  alias p='pbpaste'

  # Remove all items safely, to Trash (`brew install trash`).
  [[ -z "$commands[trash]" ]] || alias rm='trash' 2>&1 > /dev/null

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fli'
else
  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fl'
fi

# Git short-cuts.
alias g='git'
alias ga='git add'
alias gr='git rm'
alias gf='git fetch'
alias gu='git pull'
alias gs='git status --short'
alias gd='git diff'
alias gdisc='git discard'

function gc() {
  args=$@
  git commit -m "$args"
}
function gca() {
  args=$@
  git commit --amend -m "$args"
}

function cherry() {
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

alias gp='git push'

function gcp() {
  title="$@"
  git commit -am $title && git push -u origin
}
alias gcl='git clone'
alias gch='git checkout'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
function gl() {
  count=$1
  [[ -z "$1" ]] && count=10
  git --no-pager log --graph --no-merges --max-count=$count
}

# own git workflow in hy origin with Tower

# ===============
# Dev short-cuts.
# ===============

# Brunch.
alias bb='brunch build'
alias bbp='brunch build --production'
alias bw='brunch w'
alias bws='brunch w --server'

# Package managers.
alias nr='npm run'
alias jk='jekyll serve --watch' # lol jk
# alias serve='http-serve' # npm install http-server
alias serve='python -m SimpleHTTPServer'
alias server='serve'

# Ruby.
alias bx='bundle exec'
alias bex='bundle exec'
alias migr='bundle exec rake db:migrate'

# $ git log --no-merges --pretty=format:"%ae" | stats
# # => 514 a@example.com
# # => 200 b@example.com
alias stats='sort | uniq -c | sort -r'
# Lists the ten most used commands.
alias history-stats="history 0 | awk '{print \$2}' | stats | head"

# Checks whether connection is up.
alias net="ping google.com | grep -E --only-match --color=never '[0-9\.]+ ms'"

# Pretty print json
if (( $+commands[pygmentize] )); then
  alias json='pygmentize -l json -g'
  alias markdown='pygmentize -l md -g'
  alias md='pygmentize -l md -g'
else
  alias json='python -m json.tool'
fi
alias pygm=pygmentize

# ==================================================================
# = Functions =
# ==================================================================
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

# Find files and exec commands at them.
# $ find-exec .coffee cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Better find(1)
function ff() {
  find . -iname "*${1:-}*"
}

# Count code lines in some directory.
# $ loc py js css
# # => Lines of code for .py: 3781
# # => Lines of code for .js: 3354
# # => Lines of code for .css: 2970
# # => Total lines of code: 10105
function loc() {
  local total
  local firstletter
  local ext
  local lines
  total=0
  for ext in $@; do
    firstletter=$(echo $ext | cut -c1-1)
    if [[ firstletter != "." ]]; then
      ext=".$ext"
    fi
    lines=`find-exec "*$ext" cat | wc -l`
    lines=${lines// /}
    total=$(($total + $lines))
    echo "Lines of code for ${fg[blue]}$ext${reset_color}: ${fg[green]}$lines${reset_color}"
  done
  echo "${fg[blue]}Total${reset_color} lines of code: ${fg[green]}$total${reset_color}"
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
# $ rams safari
function rams() {
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
    sleep 1
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

# Shortcut for searching commands history.
# hist git
alias hist='history 0 | grep'

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

# $ retry ping google.com
function retry() {
  echo Retrying "$@"
  $@
  sleep 1
  retry $@
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

alias untarbz2='tar -xvjf'

function tarbzage() {
  file="$1"
  tarf="$file.tar.bz2"
  agef="$file.tar.bz2.age"
  tarbz2 $file
  age -p $tarf > $agef
  rm $tarf
}

function untarbzage() {
  agef="$1"
  tarf="${agef/.age/}"
  file="${tarf/.tar.bz2/}"
  age -d $agef > $tarf
  tar -xf $tarf
  rm $tarf
}

function tarage() {
  file="$1"
  tarf="$file.tar"
  agef="$file.tar.age"
  tar -cf "$tarf" "$file"
  age -p $tarf > $agef
  rm $tarf
}

function untarage() {
  agef="$1"
  tarf="${agef/.age/}"
  file="${tarf/.tar.bz2/}"
  age -d $agef > $tarf
  tar -xf $tarf
  rm $tarf
}

function remove-node-modules() {
  find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +
}

function update-debian() {
  sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
}

function update-mac() {
  brew update && brew upgrade
}

alias logs='journalctl -fu'
alias logs-all='journalctl -u'
alias ctl='systemctl'

function nginx-edit() {
  sudo vim /etc/nginx/sites-available
}
