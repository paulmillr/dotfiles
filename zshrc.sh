#!/usr/bin/env zsh

# Path to your oh-my-zsh configuration.
ZSH=$HOME/Documents/code/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it"ll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx cloudapp brew django git github node npm pip textmate)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# Theme.
PRE='%{$fg_bold[red]%}➜'
HOSTINFO="{$fg_bold[red]%}%n{$reset_color%}@%{$fg_bold[orange]%}%m%{$reset_color%}"
CURDIR="%{$fg_bold[green]%}%p %{$fg[cyan]%}%~ %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

ISMYMAC="`uname -a | grep paulmillr`"

# Show hostname and username on remote shells.
if [[ -z "$ISMYMAC" ]]; then
  PROMPT="$PRE $HOSTINFO $CURDIR"
else
  PROMPT="$PRE $CURDIR"
fi

export PATH=$PATH:/usr/local/share/python:/usr/local/Cellar/python3/3.2.1/bin

# Count code lines in some directory.
# Example usage: `linecount .py .js .css`
function linecount() {
  total=0
  for ext in $@; do
    firstletter=$(echo $ext | cut -c1-1)
    if [[ firstletter != "." ]]; then
      ext=".$ext"
    fi
    lines=`find . -name "*$ext" -exec cat {} \; | wc -l`
    lines=${lines// /}
    total=$(($total + $lines))
    echo Lines of code for $ext: $lines
  done
  echo Total lines of code: $total
}

# Start / stop / restart nginx.
function nginx_() {
  if [[ $1 == "start" ]]; then
    sudo nginx
  elif [[ $1 == "stop" ]]; then
    pidfile="/var/run/nginx.pid"
    pid=`cat $pidfile`
    sudo kill $pid
  else
    nginx_ stop && nginx_ start
  fi
}

# Disable / enable screenshot shadow in OS X.
function scrshadow() {
  if [[ $1 == "on" ]]; then
    defaults delete com.apple.screencapture disable-shadow 
    killall SystemUIServer
  elif [[ $1 == "off" ]]; then
    defaults write com.apple.screencapture disable-shadow -bool true 
    killall SystemUIServer
  else
    echo Enter options: ON or OFF
  fi
}

function ram() {
  if [ -z "$1" ]; then
    echo "First argument - pattern to grep from processes"
  else
    sum=0
    for i in `ps aux|grep -i $1|awk "{print $6}"`; do
      sum=$(($i + $sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    echo $1 uses ${fg[green]}${sum}${reset_color} MBs of RAM.
  fi
}

export LANG=en_US.UTF-8

# yup
alias bitch,=sudo

#exec /usr/local/bin/ipython -noconfirm_exit -p sh
