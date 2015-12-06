#!/usr/bin/env zsh

curr="$pm/dotfiles"

# Load main files.
# echo "Load start\t" $(gdate "+%s-%N")
source "$curr/terminal/startup.sh"
# echo "$curr/terminal/startup.sh"
source "$curr/terminal/completion.sh"
source "$curr/terminal/highlight.sh"
# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$curr/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'paulmillr'

# ==================================================================
# = Aliases =
# ==================================================================

alias -g f2='| head -n 2'
alias -g f10='| head -n 10'
alias -g l10='| tail -n 10'
# Simple clear command.
alias cl='clear'

# Disable sertificate check for wget.
alias wget='wget --no-check-certificate'

# JSHint short-cut.
alias lint=jshint

# Faster NPM for europeans.
alias npme='npm --registry http://registry.npmjs.eu'

# Some OS X-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Short-cuts for copy-paste.
  alias c='pbcopy'
  alias p='pbpaste'

  # Remove all items safely, to Trash (`brew install trash`).
  alias rm='trash'

  # Case-insensitive pgrep that outputs full path.
  alias pgrep='pgrep -fli'

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Developer tools shortcuts.
  alias tower='gittower .'
  alias t='gittower .'

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
alias gup='git pull && git push'
alias ghu='git pull hy'
alias ghp='git push hy'

alias gs='git status --short'
alias gd='git diff'
alias gds='git diff --staged'
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
  args=$@
  for commit in "$@"; do
    echo $commit
    git cherry-pick -n "$commit"
  done
}
alias gcher='cherry'

alias gp='git push'

function gcp() {
  args=$@
  git commit -a -m "$args" && git push -u origin
}
alias gcl='git clone'
alias gch='git checkout'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
alias gl='git log --no-merges'
function commits() {
  git log $1 --oneline --reverse | cut -d' ' -f 1 | tr '\n' ' '
}

# own git workflow in hy origin with Tower


# Dev short-cuts.

# Brunch.
alias bb='brunch build'
alias bbp='brunch build --production'
alias bw='brunch watch'
alias bws='brunch watch --server'

alias nr='npm run'

# Package managers.
alias bi='bower install'
alias bis='bower install --save'
alias ni='npm install'
alias nis='npm install --save'
alias nibi='npm install & bower install'
alias nibir='rm -rf {bower_components,node_modules} && npm install && bower install'
alias ns='npm search'

alias jk='jekyll serve --watch' # lol jk
# alias serve='python -m SimpleHTTPServer'
alias serve='http-server' # npm install http-server
alias server='http-server'

# Ruby.
alias bx='bundle exec'
alias bex='bundle exec'
alias migr='bundle exec rake db:migrate'

# Nginx short-cuts.
alias ngup='sudo nginx'
alias ngdown='sudo nginx -s stop'
alias ngre='sudo nginx -s stop && sudo nginx'
alias nglog='tail -f /usr/local/var/log/nginx/access.log'
alias ngerr='tail -f /usr/local/var/log/nginx/error.log'

# Checks whether connection is up.
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'"

# Pretty print json
alias json='python -m json.tool'

# Burl: better curl shortcuts (https://github.com/visionmedia/burl).
if (( $+commands[burl] )); then
  alias GET='burl GET'
  alias HEAD='burl -I'
  alias POST='burl POST'
  alias PUT='burl PUT'
  alias PATCH='burl PATCH'
  alias DELETE='burl DELETE'
  alias OPTIONS='burl OPTIONS'
fi

# Lists the ten most used commands.
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

# ==================================================================
# = Functions =
# ==================================================================
# Show man page in Preview.app.
# $ manp cd
function manp {
  local page
  if (( $# > 0 )); then
    for page in "$@"; do
      man -t "$page" | open -f -a Preview
    done
  else
    print 'What manual page do you want?' >&2
  fi
}

# Show current Finder directory.
function finder {
  osascript 2>/dev/null <<EOF
    tell application "Finder"
      return POSIX path of (target of window 1 as alias)
    end tell
EOF
}

# Gets password from OS X Keychain.
# $ get-pass github
function get-pass() {
  keychain="$HOME/Library/Keychains/login.keychain"
  security -q find-generic-password -g -l $@ $keychain 2>&1 |\
    awk -F\" '/password:/ {print $2}';
}

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

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM.
function ram() {
  local sum
  local items
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
  else
    sum=0
    for i in `ps aux | grep -i "$app" | grep -v "grep" | awk '{print $6}'`; do
      sum=$(($i + $sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    if [[ $sum != "0" ]]; then
      echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM."
    else
      echo "There are no processes with pattern '${fg[blue]}${app}${reset_color}' are running."
    fi
  fi
}

# $ size dir1 file2.js
function size() {
  # du -sh "$@" 2>&1 | grep -v '^du:' | sort -nr
  du -shck "$@" | sort -rn | awk '
      function human(x) {
          s="kMGTEPYZ";
          while (x>=1000 && length(s)>1)
              {x/=1024; s=substr(s,2)}
          return int(x+0.5) substr(s,1,1)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
}

# $ git log --no-merges --pretty=format:"%ae" | stats
# # => 514 a@example.com
# # => 200 b@example.com
function stats() {
  sort | uniq -c | sort -r
}

# Shortcut for searching commands history.
# hist git
function hist() {
  history 0 | grep $@
}

# $ aes-enc file.zip
function aes-enc() {
  openssl enc -aes-256-cbc -e -in $1 -out "$1.aes"
}

# $ aes-dec file.zip.aes
function aes-dec() {
  openssl enc -aes-256-cbc -d -in $1 -out "${1%.*}"
}

# Converts a.mkv to a.m4v.
function mkv2mp4() {
  for file in "$@"; do
    ffmpeg -i $file -map 0 -c copy "${file%.*}.m4v"
  done
}

function mkv2mp4_1() {
  for file in "$@"; do
    ffmpeg -i $file -map 0:0 -map 0:1 -c copy -c:s mov_text "${file%.*}.m4v"
  done
}

function mkv2mp4_2() {
  for file in "$@"; do
    ffmpeg -i $file -map 0:0 -map 0:2 -c copy -c:s mov_text "${file%.*}.m4v"
  done
}

function mkv2mp4_3() {
  for file in "$@"; do
    ffmpeg -i $file -map 0:0 -map 0:3 -c copy -c:s mov_text "${file%.*}.m4v"
  done
}

# Adds subs from a.srt to a.m4v.
function addsubs() {
  for file in "$@"; do
    local raw="${file%.*}"
    local old="$raw.m4v"
    local new="$raw-sub.m4v"
    ffmpeg -i $old -i $file -map 0 -map 1 -c copy -c:s mov_text $new
    mv $new $old
    rm $file
  done
}


# Shortens GitHub URLs. By Sorin Ionescu <sorin.ionescu@gmail.com>
function gitio() {
  local url="$1"
  local code="$2"

  [[ -z "$url" ]] && print "usage: $0 url code" >&2 && exit
  [[ -z "$code" ]] && print "usage: $0 url code" >&2 && exit

  curl -s -i 'http://git.io' -F "url=$url" -F "code=$code"
}

# Monitor IO in real-time (open files etc).
function openfiles() {
  sudo dtrace -n 'syscall::open*:entry { printf("%s %s",execname,copyinstr(arg0)); }'
}

# 4 lulz.
function compute() {
  while true; do head -n 100 /dev/urandom; sleep 0.1; done \
    | hexdump -C | grep "ca fe"
}

# Load 8 cores at once.
function maxcpu() {
  dn=/dev/null
  yes > $dn & yes > $dn & yes > $dn & yes > $dn &
  yes > $dn & yes > $dn & yes > $dn & yes > $dn &
}

# $ retry ping google.com
function retry() {
  echo Retrying "$@"
  $@
  sleep 1
  retry $@
}

# Open curr dir in preview.app.
function preview() {
  local item=$1
  [[ -z "$item" ]] && item='.'
  open $1 -a 'Preview'
}
