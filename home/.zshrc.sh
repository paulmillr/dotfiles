#!/usr/bin/env zsh

umask 022

# Commonly used directories.
dev="$HOME/Developer"
pm="$dev/personal"

if [[ -n "${pm:-}" ]]; then
  curr="$pm/dotfiles"
else
  curr=''
  print -u2 'pm is not set; skipping dotfiles startup files'
fi

# Paths.
typeset -gU cdpath fpath mailpath manpath path
typeset -gUT INFOPATH infopath

# Temporary Files.
if [[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -m 700 -p "$TMPPREFIX"
  fi
  chmod 700 "$TMPPREFIX" 2> /dev/null
fi

# Trust a path only if it and every parent up to $HOME are owned by the
# current user or root and are not group/world-writable.
function _zshrc_is_trusted_path() {
  local p home="${HOME:A}"
  local -A st

  if [[ ! -e "$1" && ! -L "$1" ]]; then
    print -u2 "Refusing to trust missing path: $1"
    return 1
  fi
  zmodload zsh/stat 2> /dev/null || {
    print -u2 'Refusing to trust startup files: zsh/stat is unavailable'
    return 1
  }

  p="${1:A}"
  if [[ "$p" != "$home" && "$p" != "$home"/* ]]; then
    print -u2 "Refusing to trust $p: outside HOME"
    return 1
  fi
  while :; do
    zstat -H st -- "$p" || return 1
    if (( (st[uid] != EUID && st[uid] != 0) || st[mode] & 8#022 )); then
      print -u2 "Refusing to trust $1: $p has untrusted owner or is group/world-writable"
      return 1
    fi
    [[ "$p" == "$home" ]] && return 0
    p="${p:h}"
  done
}

function _zshrc_source_trusted() {
  _zshrc_is_trusted_path "$1" && source -- "$1"
}

# Private environment variables, kept out of the repo.
privenv="$HOME/.private-env"
if [[ -e "$privenv" || -L "$privenv" ]] && _zshrc_is_trusted_path "$privenv"; then
  chmod go-rwx "$privenv" 2> /dev/null
  source -- "$privenv"
fi
unset privenv

# Directory options.
setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt AUTO_NAME_DIRS       # Auto add variable-stored paths to ~ list.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.

# Smart URLs
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# History options
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt SHARE_HISTORY             # Share history between all sessions; implies incremental append.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_NO_FUNCTIONS         # Do not record function definitions.
setopt HIST_NO_STORE             # Do not record history commands.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.

# History
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"       # The path to the history file.
HISTSIZE=10000                   # The maximum number of events to save in the internal history.
SAVEHIST=10000                   # The maximum number of events to save in the history file.

if [[ -n "$HISTFILE" ]]; then
  _histdir="${HISTFILE:h}"
  if [[ -d "$_histdir" ]] || mkdir -p "$_histdir" 2> /dev/null; then
    : >>! "$HISTFILE" 2> /dev/null
    chmod go-rwx "$HISTFILE" 2> /dev/null
  fi
  unset _histdir
fi

# Load main files.
# To benchmark startup: brew install coreutils, uncomment lines
# echo "Load start\t" $(gdate "+%s-%N")
if [[ -n "$curr" ]]; then
  _zshrc_source_trusted "$curr/terminal/shared.sh"
  # Completion and syntax highlighting only matter on a real terminal;
  # skip them in tty-less shells (e.g. tool-spawned `zsh -i -c ...`).
  if [[ -t 1 ]]; then
    _zshrc_source_trusted "$curr/terminal/completion.sh"
    _zshrc_source_trusted "$curr/terminal/highlight.sh"
  fi
fi
# echo "Load end\t" $(gdate "+%s-%N")

# Load and execute the prompt theming system.
if [[ -n "$curr" ]]; then
  _zshrc_source_trusted "$curr/terminal/prompt_pm_setup"
fi

if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)" # For git commit signing
fi

# Print a random, hopefully interesting, adage. The tty guard keeps
# fortune out of captured output from `zsh -i -c ...` invocations.
if [[ -t 1 ]] && (( $+commands[fortune] )); then
  fortune -a
  print
fi
