#!/usr/bin/env zsh

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export EDITOR='/usr/local/bin/subl'
autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$pm/dotfiles/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'paulmillr'

# Useful global aliases.
alias -g 'F'='| head -n'  # git log F 15
alias -g 'L'='| tail -n'  # git log L 10

# Some OS X-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Short-cuts for copy-paste
  alias c='pbcopy'
  alias p='pbpaste'

  # Remove all items safely, to Trash.
  alias rm='trash'

  # Case-insensitive pgrep that outputs full path.
  alias pgrep='pgrep -fli'

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Python virtualenv shortcuts.
  alias venv-init='virtualenv venv -p /usr/local/bin/python --no-site-packages'
  alias venv-activate='source venv/bin/activate'

  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Developer tools shortcuts.
  alias tower='gittower -s'

  function cdedit() {
    cd $1
    gittower -s .
    $EDITOR .
  }

  export NODE_PATH='/usr/local/lib/node_modules'
fi

BROWSER=''
unset BROWSER

# Find files and exec commands at them.
# $ find-exec .coffee cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

function edit() {
  local dir=$1
  if [[ -z "$dir" ]]; then
    dir='.'
  fi
  $EDITOR $dir
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

function compute() {
  while true; do head -n 100 /dev/urandom; sleep .1; done \
    | hexdump -C | grep "ca fe"
}

# Replace pygments output for github style stuff.
# $ ./pygmentize < demo.ls -f html -l livescript | rpfg | pbcopy
function rpfg() {
  sed -E -e :a -e '$!N; s/\n/<\/div><div class="line">/g; ta' \
    | sed -e 's/<div class="highlight"><pre>/<div class="highlight"><pre><div class="line">/' \
    | sed -e 's/<div class="line"><\/pre><\/div>/<\/pre><\/div>/'
}
