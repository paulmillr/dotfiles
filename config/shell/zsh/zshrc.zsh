#!/usr/bin/env zsh

umask 022

# Repository root.
curr="${${(%):-%x}:A:h:h:h:h}"

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

_zshrc_source_trusted "$curr/config/shell/shared.sh"

# Completion and syntax highlighting only matter on a real terminal;
# skip them in tty-less shells (e.g. tool-spawned `zsh -i -c ...`).
if [[ -t 1 ]]; then
  if [[ "$TERM" != dumb ]]; then
    fpath=("$curr/config/shell/zsh/vendor/completions/src" $fpath)

    # Keep generated completion data private. Fall back to an uncached
    # initialization if the cache path is unsafe or unusable.
    () {
      local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"

      autoload -Uz compinit
      if [[ ! -L "$cache_dir" ]] &&
        { [[ -d "$cache_dir" ]] || mkdir -m 700 -p "$cache_dir"; } &&
        [[ -O "$cache_dir" ]] && chmod 700 "$cache_dir" 2> /dev/null; then
        compinit -i -d "$cache_dir/zcompdump"
        zstyle ':completion:*' use-cache yes
        zstyle ':completion:*' cache-path "$cache_dir"
      else
        print -u2 "Ignoring unsafe completion cache directory: $cache_dir"
        compinit -i -D
      fi
    }

    setopt COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS AUTO_MENU AUTO_LIST AUTO_PARAM_SLASH
    unsetopt MENU_COMPLETE FLOW_CONTROL CASE_GLOB

    # Case-insensitive, partial-word, substring, and typo-tolerant matching.
    zstyle ':completion:*' matcher-list \
      'm:{a-zA-Z}={A-Za-z}' \
      'r:|[._-]=* r:|=*' \
      'l:|=* r:|=*'
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*:match:*' original only
    zstyle -e ':completion:*:approximate:*' max-errors \
      'reply=($((($#PREFIX + $#SUFFIX) / 3))numeric)'

    # Selection menu and descriptions.
    zstyle ':completion:*' menu select
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
    zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
    zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

    # Useful context-specific behavior.
    zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
    zstyle ':completion:*' squeeze-slashes true
    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
    zstyle ':completion:*:*:*:*:processes' command 'ps -u "$USER" -o pid,user,comm -w'
    zstyle ':completion:*:*:kill:*' menu select
    zstyle ':completion:*:*:kill:*' insert-ids single
    zstyle ':completion:*:manuals' separate-sections true
    zstyle ':completion:*:manuals.(^1*)' insert-sections true
  fi

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
  source -- "$curr/config/shell/zsh/vendor/highlighting/zsh-syntax-highlighting.zsh"
fi

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

# Simple prompt.
#
# dotfiles ❯ (default)
# dotfiles master ❯ (in git repository)
# root@serv dotfiles master ❯ (with SSH)
#
# * is appended to the Git branch name if the repository is dirty.
# ❯ is green or red depending on previous command exit status.
vcs_info=''
setopt PROMPT_CR PROMPT_PERCENT
unsetopt PROMPT_SUBST

function get-vcs-info {
  local ref
  local dirty=''
  local git_status

  vcs_info=''
  if ref=$(command git symbolic-ref --short -q HEAD 2> /dev/null); then
    if git_status=$(command git status --porcelain=v1 --ignore-submodules=all 2> /dev/null); then
      [[ -n "$git_status" ]] && dirty='*'
      # PROMPT_SUBST stays disabled so branch text cannot be evaluated. Escape
      # percent signs separately because they are native prompt sequences.
      ref=${ref//\%/%%}
      vcs_info=" ${ref}${dirty}"
    fi
  fi

  PROMPT="%F{12}%1~%f${vcs_info}%(!.%B%F{red}#%f%b.%B %(?.%F{green}.%F{red})❯%f%b) "
}

function _zsh_prompt_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd get-vcs-info
  # add-zsh-hook chpwd list-files
  # if [[ -n "${SSH_TTY:-}" ]]; then
  #   prompt_ssh_info='%n@%m '
  # fi
  get-vcs-info
  RPROMPT=''
  SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

_zsh_prompt_setup "$@"
unfunction _zsh_prompt_setup
