# Defines environment variables.
privenv="$HOME/.private-env"
[[ -f "$privenv" ]] && source $privenv
unset privenv

# Browser.
# --------
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

# Editors.
# --------
export PAGER='less'

# Language.
# ---------
if [[ -z "$LANG" ]]; then
  eval "$(locale)"
fi

# Less.
# -----
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Paths.
# ------
typeset -gU cdpath fpath mailpath manpath path
typeset -gUT INFOPATH infopath

# Commonly used directories.
dev="$HOME/Developer"
com="$dev/com"
pm="$dev/personal"
as="$HOME/Library/Application Support"

# path=($HOME/.cargo/bin /usr/local/opt/ruby/bin $path) # changing .zshenv doesn't work
if [ -f "/opt/homebrew/bin/brew" ]; then
  # export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

  # Note: you can do this instead of the lines below
  # It's more reliable, but can be 0.1s (etc) slower
  eval $(/opt/homebrew/bin/brew shellenv)

  # export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  # export HOMEBREW_REPOSITORY=/opt/homebrew
  # path=(
  #   /opt/homebrew/bin
  #   /opt/homebrew/sbin
  #   /opt/homebrew/opt/ruby/bin
  #   /usr/local/opt/ruby/bin
  #   $path
  # )
  # # export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/ruby/bin:/usr/local/opt/ruby/bin
  # export MANPATH=/opt/homebrew/share/man::
  # export INFOPATH=/opt/homebrew/share/info:
fi

# for path_file in /etc/paths.d/*(.N); do
#   path+=($(<$path_file))
# done
# unset path_file

# Temporary Files.
if [[ -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
  fi
fi


BROWSER=''
unset BROWSER

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_AUTO_UPDATE_SECS='2592000'
export HOMEBREW_NO_ENV_HINTS=1
export GPG_TTY=$(tty) # For git commit signing
gitssh="$HOME/.ssh/git"
if [[ -f $gitssh ]]; then
  export GIT_SSH_COMMAND="ssh -i $gitssh -F /dev/null"
fi
unset gitssh


if (( $+commands[code] )); then
  export EDITOR=$commands[code]
  export VISUAL=$commands[code]
else
  export EDITOR=$commands[vim]
  export VISUAL=$commands[vim]
fi

export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
