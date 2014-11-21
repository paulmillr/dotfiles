# Defines environment variables.
privenv="$HOME/.private-env"
[[ -f "$privenv" ]] && source $privenv

# Browser.
# --------
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

# Editors.
# --------
export EDITOR='/usr/local/bin/subl'
export VISUAL='/usr/local/bin/subl'
export PAGER='less'

# Language.
# ---------
if [[ -z "$LANG" ]]; then
  eval "$(locale)"
fi

# Git log colors.
zstyle -s ':prezto:module:git:log:medium' format '_git_log_medium_format' \
  || _git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
zstyle -s ':prezto:module:git:log:oneline' format '_git_log_oneline_format' \
  || _git_log_oneline_format='%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
zstyle -s ':prezto:module:git:log:brief' format '_git_log_brief_format' \
  || _git_log_brief_format='%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'

# Status
zstyle -s ':prezto:module:git:status:ignore' submodules '_git_status_ignore_submodules' \
  || _git_status_ignore_submodules='none'

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
br="$dev/brunch"
ch="$dev/chaplinjs"
com="$dev/com"
pm="$dev/paulmillr"
as="$HOME/Library/Application Support"

# Set the the list of directories that cd searches.
cdpath=(
  $cdpath
)

# Set the list of directories that info searches for manuals.
infopath=(
  /usr/local/share/info
  /usr/share/info
  $infopath
)

# Set the list of directories that man searches for manuals.
manpath=(
  /usr/local/share/man
  /usr/share/man
  $manpath
)

for path_file in /etc/manpaths.d/*(.N); do
  manpath+=($(<$path_file))
done
unset path_file

# Set the list of directories that Zsh searches for programs.
# export PYTHONPATH=/usr/local/lib/python2.7/site-packages
path=(
  /usr/local/{bin,sbin}
  /usr/local/opt/ruby/bin
  /usr/local/lib/python2.7/site-packages
  /usr/local/share/npm/bin
  /usr/{bin,sbin}
  /{bin,sbin}
  $path
)

for path_file in /etc/paths.d/*(.N); do
  path+=($(<$path_file))
done
unset path_file

# Temporary Files.
if [[ -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
  fi
fi


BROWSER=''
unset BROWSER

export NODE_PATH='/usr/local/lib/node_modules'
