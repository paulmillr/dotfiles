#!/usr/bin/env zsh

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$pm/dotfiles/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'paulmillr'

# Simple clear command.
alias cl='clear'

# Process grep should output full paths to binaries.
alias pgrep='pgrep -fl'

# JSHint short-cut.
alias lint=jshint

# Useful global aliases.
alias -g 'H'='| head'     # git log H
alias -g 'T'='| tail'     # git log T
alias -g 'F'='| head -n'  # git log F 15
alias -g 'L'='| tail -n'  # git log L 10
alias -g 'C'='| wc -l'    # git log C

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

  # Python virtualenv shortcuts.
  alias venv-init='virtualenv venv -p /usr/local/bin/python --no-site-packages'
  alias venv-activate='source venv/bin/activate'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Developer tools shortcuts.
  alias tower='gittower --status'
  alias t='tower'

  function cded() {
    cd $1
    $EDITOR .
  }

  export NODE_PATH='/usr/local/lib/node_modules'

  # Gets password from OS X Keychain.
  # $ get-pass github
  function get-pass() {
    keychain="$HOME/Library/Keychains/login.keychain"
    security -q find-generic-password -g -l $@ $keychain 2>&1 |\
      awk -F\" '/password:/ {print $2}';
  }
fi

# Git short-cuts.
alias ga='git add'
alias gr='git rm'
alias gf='git fetch'
alias gu='git pull'
alias gs='git status --short'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit --message'
alias gp='git push'
alias gcp='git cpush'
alias gcl='git clone'
alias gl='git log'

# Dev short-cuts.
alias bw='brunch watch'
alias bws='brunch watch --server'

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

BROWSER=''
unset BROWSER

# Opens file in EDITOR.
function edit() {
  local dir=$1
  [[ -z "$dir" ]] && dir='.'
  $EDITOR $dir
}
alias e=edit

# Find files and exec commands at them.
# $ find-exec .coffee cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
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

function size() {
  du -sh "$@" 2>&1 | grep -v '^du:'
}

# Determines the max number of tweeple who saw some tweet.
# If tweet x was retweeted by users A (500 followers) and B (10 followers),
# influence would be 500 + 10 + x-authors-followers.
# $ tweet-influence https://twitter.com/chaplinjs/status/303718187437015040
# # => 11851
function tweet-influence() {
  url_or_id=$1
  count=$(ruby -e "require 'twitter'; id = /\d{10,}/.match('$url_or_id')[0]; initial = Twitter.status(id)[:user][:followers_count]; retweets = Twitter.retweets(id).map(&:user).map(&:followers_count).inject(:+); puts initial + retweets")
  echo ${fg[green]}${count}${reset_color}
}

# $ git log --no-merges --pretty=format:"%ae" | stats
# 514 a@example.com
# 200 b@example.com
function stats() {
  sort | uniq -c | sort -r
}

# Shortcut for searching commands history.
function hist() {
  history 0 | grep $@
}

# Execute commands for each file in current directory.
function each() {
  for dir in *; do
    echo "${dir}:"
    cd $dir
    $@
    cd ..
  done
}

# Pack files with zip and password.
function zip-pass() {
  zip -e $(basename $PWD).zip $@
}

# Compress files to one .tar.gz archive.
function pack-tar() {
  [[ -z "$1" ]] && echo "Usage: pack-tar file1 [file2...]" && exit 1
  archive="archive.tar.gz"
  tar -zcvf $archive $@
}

# Uncopress .tar.gz archive.
function unpack-tar() {
  tar -zxvf $1
}

# Shortens GitHub URLs.
# By Sorin Ionescu <sorin.ionescu@gmail.com>
function gitio() {
  local url="$1"
  local code="$2"

  [[ -z "$url" ]] && print "usage: $0 url code" >&2 && exit
  [[ -z "$code" ]] && print "usage: $0 url code" >&2 && exit

  curl -s -i 'http://git.io' -F "url=$url" -F "code=$code"
}

# 4 lulz.
function compute() {
  while true; do head -n 100 /dev/urandom; sleep 0.1; done \
    | hexdump -C | grep "ca fe"
}
