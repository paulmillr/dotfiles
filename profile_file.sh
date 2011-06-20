# MacPorts Installer addition on 2010-02-21_at_15:38:12: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

# MacPorts Installer addition on 2010-02-21_at_15:38:12: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH=/opt/local/share/man:$MANPATH
# Finished adapting your MANPATH environment variable for use with MacPorts.

autoload colors; colors

export TERM=xterm-color
export CLICOLOR=1
export LSCOLORS=fxfxcxdxbxegedabagacad
export PS1="%B%{$fg[blue]%}%~%B%{$reset_color%}%b "
#export PS1="%B[%{$fg[red]%}%n%{$reset_color%}%b@%B%{$fg[yellow]%}%m%b%{$reset_color%}:%~%B]%b "

alias apache2ctl='sudo /opt/local/apache2/bin/apachectl'
alias apache='sudo /opt/local/apache2/bin/apachectl'
alias cdgit='cd ~/Documents/git/'
DJANGODIR='/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/django/'
alias hosts='mate /etc/hosts'
alias wget='wget --no-check-certificate'

function count_lines() {
    total=0
    for ext in $@; do
        lines=`find . -name "*.$ext" -exec cat {} \; | wc -l`
        lines=${lines// /}
        total=`expr $total + $lines`
        echo Lines of code for $ext: $lines
    done
    echo Total lines of code: $total
}

function log() {
    DIR='/opt/local/logs/'
    if [[ $1 == 'cd' ]]; then
        cd $DIR
    else
        tail -f $DIR/$1.log
    fi
}

function nginx_() {
    if [[ $1 == 'start' ]]; then
        sudo nginx
    elif [[ $1 == 'stop' ]]; then
        pidfile='/opt/local/logs/nginx.pid'
        pid=`cat $pidfile`
        sudo kill $pid
    else
        nginx_ stop && nginx_ start
    fi
}

function scrshadow() {
    if [[ $1 == 'on' ]]; then
        defaults delete com.apple.screencapture disable-shadow 
        killall SystemUIServer
    elif [[ $1 == 'off' ]]; then
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
        SUM=0
        for i in `ps aux|grep -i $1|awk '{print $6}'`; do
            SUM=`expr $i + $SUM`
        done
        echo ${fg[green]}${SUM}${reset_color} KB
    fi
}

##
# Your previous /Users/paul/.profile file was backed up as /Users/paul/.profile.macports-saved_2011-01-25_at_22:28:33
##

# MacPorts Installer addition on 2011-01-25_at_22:28:33: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

