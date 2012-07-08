#!/usr/bin/env zsh

# Profiler.
# zmodload zsh/zprof

export PATH="/usr/local/bin:$PATH"

#
# Sets Oh My Zsh options.
# 

# Set the path to Oh My Zsh.
export OMZ="$HOME/Development/oh-my-zsh"

# Auto convert .... to ../..
zstyle ':omz:module:editor' dot-expansion 'no'

# Set case-sensitivity for completion, history lookup, etc.
zstyle ':omz:*:*' case-sensitive 'no'

# Color output (auto set to 'no' on dumb terminals).
zstyle ':omz:*:*' color 'yes'

# Auto set the tab and window titles.
zstyle ':omz:module:terminal' auto-title 'yes'

# Set the Zsh modules to load (man zshmodules).
# zstyle ':omz:load' zmodule 'attr' 'stat'

# Set the Zsh functions to load (man zshcontrib).
zstyle ':omz:load' zfunction 'zargs' 'zmv'

# Set the Oh My Zsh modules to load (browse modules).
zstyle ':omz:load' omodule \
  'environment' 'terminal' 'history' \
  'directory' 'spectrum' 'utility' \
  'completion' 'prompt' 'syntax-highlighting' 'git' \
  'archive' 'osx' 'node' 'python' 'ruby'

# Set the prompt theme to load.
# Setting it to 'random' loads a random theme.
# Auto set to 'off' on dumb terminals.
zstyle ':omz:module:prompt' theme 'sorin'

# This will make you shout: OH MY ZSHELL!
source "$OMZ/init.zsh"

autoload -U colors && colors

export EDITOR="/usr/local/bin/mate -w"

# Commonly used directories.
dev="$HOME/Development"
brunch="$dev/brunch"
chaplin="$dev/chaplinjs"
forks="$dev/forks"
pm="$dev/paulmillr"

if [[ "$OSTYPE" == darwin* ]]; then
  alias rm=trash
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
  alias venv-init='virtualenv venv -p /usr/local/bin/python --no-site-packages'
  alias venv-activate='source venv/bin/activate'
  tm="$HOME/Library/Application Support/Avian/Bundles"
  export NODE_PATH='/usr/local/lib/node_modules'
fi

BROWSER=''
unset BROWSER

function each-file() {
  for file in *; do
    $1 $file
  done
}

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

# Show process information & PID.
# $ proc safari
# # => 44371 ...
function proc() {
  ps -ex | grep -i "$1" | grep -v "grep"
}

# Recursively convert mp3 tags in directory from CP1251 to UTF8.
function convert-tags() {
  python "$dev/dotfiles/tag2utf.py" "$1"
}

# Profiler end.
# zprof
