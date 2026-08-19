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

# Key bindings.
# Pick the keymap explicitly. Left to itself, zsh picks vi mode whenever
# $EDITOR/$VISUAL basename starts with "vi" (vi, vim -- but not nvim), so the
# line editor would silently change behaviour depending on which editor a
# machine happens to have installed.
bindkey -e

# zsh's stock keymaps only cover the sequences xterm sends in application mode,
# so keys that terminals encode differently end up on undefined-key: emacs mode
# swallows the "^[[1" prefix and self-inserts the rest (a literal ";3D"), and vi
# mode takes the ^[ as vi-cmd-mode and runs the tail as commands. Bind every
# encoding in common use rather than relying on the terminal to agree with zsh.
function _zshrc_bindkeys() {
  local widget="$1" key
  shift
  for key in "$@"; do
    bindkey -- "$key" "$widget"
  done
}

# Word-wise motion, i.e. option/alt + arrows:
#   ^[[1;3X  alt (xterm and most modern terminals, tmux with xterm-keys)
#   ^[[1;9X  option when iTerm2 reports it as meta
#   ^[^[[X   alt as esc-prefix (older tmux/screen, rxvt)
#   ^[[1;5X  ctrl (xterm), ^[[5X  ctrl (rxvt)
_zshrc_bindkeys backward-word '^[b' '^[[1;3D' '^[[1;9D' '^[^[[D' '^[[1;5D' '^[[5D'
_zshrc_bindkeys forward-word  '^[f' '^[[1;3C' '^[[1;9C' '^[^[[C' '^[[1;5C' '^[[5C'

# Home/End. zsh binds only the application-mode forms (^[OH/^[OF), which leaves
# both keys dead under tmux/screen and on the linux console -- their terminfo
# khome/kend are ^[[1~ and ^[[4~. ^[[H/^[[F are normal-mode xterm, ^[[7~/^[[8~
# are rxvt.
_zshrc_bindkeys beginning-of-line '^[[H' '^[OH' '^[[1~' '^[[7~'
_zshrc_bindkeys end-of-line       '^[[F' '^[OF' '^[[4~' '^[[8~'

# Forward word deletion: alt+delete and ctrl+delete. Plain delete (^[[3~) and
# alt+backspace (^[^?) are already bound by zsh.
_zshrc_bindkeys kill-word '^[[3;3~' '^[[3;5~'

# Shift+tab, to walk backwards through the completion menu.
_zshrc_bindkeys reverse-menu-complete '^[[Z'

# Up/down search history by what is already typed: enter "git " and only past
# git commands are offered. The history-search-end contrib function leaves the
# cursor at end of line; fall back to the builtin widgets where it is missing.
# ^P/^N are deliberately left alone as a plain, unfiltered history walk.
autoload -Uz history-search-end
if [[ -n ${^fpath}/history-search-end(#qN[1]) ]]; then
  zle -N history-beginning-search-backward-end history-search-end
  zle -N history-beginning-search-forward-end history-search-end
  _zshrc_bindkeys history-beginning-search-backward-end '^[[A' '^[OA'
  _zshrc_bindkeys history-beginning-search-forward-end  '^[[B' '^[OB'
else
  _zshrc_bindkeys history-beginning-search-backward '^[[A' '^[OA'
  _zshrc_bindkeys history-beginning-search-forward  '^[[B' '^[OB'
fi

# Ctrl+backspace deletes the previous word. Terminals that use ^H as their
# erase character are skipped, since there it would break plain backspace.
if [[ ! -t 0 || "$(stty -a 2> /dev/null)" != *'erase = ^H'* ]]; then
  _zshrc_bindkeys backward-kill-word '^H'
fi

unfunction _zshrc_bindkeys

# Load and execute the prompt theming system.
if [[ -n "$curr" ]]; then
  _zshrc_source_trusted "$curr/terminal/prompt_pm_setup"
fi

if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)" # For git commit signing
fi

# bat picks light vs dark by asking the terminal for its background colour
# (an OSC 11 query) and giving up if the reply is slow. Over ssh that reply
# has to cross the network, and since TERM arrives as xterm-256color bat
# can't recognise the terminal to allow it a longer budget -- so it times out
# and quietly falls back to dark. Prefer an explicit answer forwarded by the
# client in LC_TERM_BG (sshd already accepts LC_*, the same trick iTerm2 uses
# for LC_TERMINAL); probe only when nobody told us.
#
# BAT_THEME has to name a real theme: unlike --theme it does not accept the
# "light"/"dark" aliases, and warns "Unknown theme" if given one.
#
# delta needs the same answer, and needs it twice over: it has its own OSC 11
# probe for the diff backgrounds (with the same ssh timeout), but its
# syntax-theme just reads BAT_THEME -- so detection alone flips the +/- hunk
# backgrounds and leaves the code inside them highlighted for the other one.
# The `+` prefix adds to the features from gitconfig, keeping navigate = true.
# Nothing produces LC_TERM_BG on its own: it is our own name, not something any
# terminal implements. iTerm2 really does export LC_TERMINAL, which is why that
# trick works for free; Ghostty exports TERM/GHOSTTY_* and nothing about the
# background. So the client end has to answer. `defaults` exists only on macOS
# and only a non-ssh shell sits at a real terminal, so the two tests together
# scope this to the laptop. This tracks the system appearance, which is right
# when Ghostty is configured `theme = light:...,dark:...`; if yours is pinned to
# one theme, replace the whole block with a plain export of that value.
if [[ -z "$SSH_CONNECTION" ]] && (( $+commands[defaults] )); then
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]]; then
    export LC_TERM_BG=dark
  else
    export LC_TERM_BG=light
  fi
fi

# Herdr's persistent server keeps the environment from the SSH login that
# originally started it, so even brand-new panes otherwise inherit a stale
# LC_TERM_BG after a later client reconnects.  Cache the value seen by each
# ordinary SSH login, then let shells spawned inside Herdr recover the newest
# value.  If multiple SSH clients are connected, the most recent login wins.
_term_bg_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
_term_bg_cache="$_term_bg_cache_dir/terminal-background"
if [[ -n "$SSH_CONNECTION" && -z "$HERDR_ENV" ]]; then
  case "$LC_TERM_BG" in
    light|dark)
      if [[ -d "$_term_bg_cache_dir" ]] || mkdir -m 700 -p -- "$_term_bg_cache_dir" 2>/dev/null; then
        print -r -- "$LC_TERM_BG" >| "$_term_bg_cache" 2>/dev/null
        chmod 600 "$_term_bg_cache" 2>/dev/null
      fi
      ;;
  esac
elif [[ -n "$SSH_CONNECTION" && -n "$HERDR_ENV" && -r "$_term_bg_cache" ]]; then
  _term_bg_cached="$(<"$_term_bg_cache")"
  case "$_term_bg_cached" in
    light|dark) export LC_TERM_BG="$_term_bg_cached" ;;
  esac
  unset _term_bg_cached
fi
unset _term_bg_cache _term_bg_cache_dir

export BAT_THEME_LIGHT="Monokai Extended Light"
export BAT_THEME_DARK="Monokai Extended"
case "$LC_TERM_BG" in
  light) export BAT_THEME="$BAT_THEME_LIGHT"; export DELTA_FEATURES="+light-mode" ;;
  dark)  export BAT_THEME="$BAT_THEME_DARK";  export DELTA_FEATURES="+dark-mode"  ;;
  *)     export BAT_THEME="$BAT_THEME_DARK";  export DELTA_FEATURES="+dark-mode"  ;;
esac
