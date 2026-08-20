# Load zsh-syntax-highlighting.

function _zsh_highlighting_load() {
  local plugin="${${(%):-%x}:A:h:h:h:h}/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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

  _zsh_highlighting_load
  rc=$?
  unfunction _zsh_highlighting_load
  return "$rc"
}
return $?
