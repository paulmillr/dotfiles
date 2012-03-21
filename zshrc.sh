#!/usr/bin/env zsh

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':omz:editor' keymap 'emacs'

# Auto convert .... to ../..
zstyle ':omz:editor' dot-expansion 'yes'

# Set case-sensitivity for completion, history lookup, etc.
zstyle ':omz:*:*' case-sensitive 'no'

# Color output (auto set to 'no' on dumb terminals).
zstyle ':omz:*:*' color 'yes'

# Auto set the tab and window titles.
zstyle ':omz:terminal' auto-title 'no'

# Set the plugins to load (see $OMZ/plugins/).
zstyle ':omz:load' plugin 'archive' 'git' 'node' 'osx' 'python' 'ruby' 'z'

# Set the prompt theme to load.
# Setting it to 'random' loads a random theme.
# Auto set to 'off' on dumb terminals.
zstyle ':omz:prompt' theme 'paulmillr'

# This will make you shout: OH MY ZSHELL!
source "$HOME/Development/oh-my-zsh/init.zsh"

# Customize to your needs...

autoload colors
colors

# Solarized light LS colors.
# export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

export EDITOR="/usr/local/bin/mate -w"
export LANG=en_US.UTF-8
export PATH="\
/usr/local/bin:\
$GEM_HOME/bin:\
/usr/bin:/bin:\
/usr/sbin:/sbin:\
/usr/X11/bin:\
/usr/texbin:\
/usr/local/share/python:\
/usr/local/share/python3:\
$HOME/.cabal/bin"

# Count code lines in some directory.
# Example usage: `loc .py .js .css`
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
    lines=`find . -name "*$ext" -exec cat {} \; | wc -l`
    lines=${lines// /}
    total=$(($total + $lines))
    echo "Lines of code for ${fg[blue]}$ext${reset_color}: ${fg[green]}$lines${reset_color}"
  done
  echo "${fg[blue]}Total${reset_color} lines of code: ${fg[green]}$total${reset_color}"
}

# Disable / enable screenshot shadow in OS X.
function scrshadow() {
  if [[ $1 == true ]]; then
    defaults delete com.apple.screencapture disable-shadow 
    killall SystemUIServer
  elif [[ $1 == false ]]; then
    defaults write com.apple.screencapture disable-shadow -bool true 
    killall SystemUIServer
  else
    local value="$(defaults read com.apple.screencapture disable-shadow 2> /dev/null)"
    if [[ -z "$value" ]]; then
      echo "Screen shadow is enabled"
    else
      echo "Screen shadow is disabled"
    fi
  fi
}

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM.
function ram() {
  local sum
  local items
  local app

  app="$1"
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

function server() {
  local port="$1"
  if [ -z "$port" ]; then
    port="8000"
  fi
  python -m SimpleHTTPServer $port
}

function proc() {
  ps -ex | grep -i "$1"
}

function convert_tags() {
  python "$HOME/Development/dotfiles/tag2utf.py" "$1"
}

# Some aliases.
alias remove='/bin/rm'
alias rm=trash
alias bitch,=sudo
