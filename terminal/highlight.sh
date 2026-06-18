# Load zsh-syntax-highlighting.

function _terminal_highlight_load() {
  local plugin="${${(%):-%x}:A:h}/highlight/zsh-syntax-highlighting.zsh"

  if [[ ! -r "$plugin" ]]; then
    print -u2 "zsh-syntax-highlighting is unavailable: $plugin"
    return 1
  fi

  typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS
  typeset -gA ZSH_HIGHLIGHT_STYLES

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

  source -- "$plugin"
}

() {
  local rc

  _terminal_highlight_load
  rc=$?
  unfunction _terminal_highlight_load
  return "$rc"
}
return $?
