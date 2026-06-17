# Load zsh-syntax-highlighting.

function _terminal_highlight_load() {
  local context=':prezto:module:syntax-highlighting'
  local plugin="${${(%):-%x}:A:h}/highlight/zsh-syntax-highlighting.zsh"
  local style
  local -A styles

  zstyle -t "$context" color || return 1

  if [[ ! -r "$plugin" ]]; then
    print -u2 "zsh-syntax-highlighting is unavailable: $plugin"
    return 1
  fi

  typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS
  typeset -gA ZSH_HIGHLIGHT_STYLES

  zstyle -a "$context" highlighters ZSH_HIGHLIGHT_HIGHLIGHTERS
  (( ${#ZSH_HIGHLIGHT_HIGHLIGHTERS[@]} > 0 )) || ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

  zstyle -a "$context" styles styles
  for style in "${(@k)styles}"; do
    ZSH_HIGHLIGHT_STYLES[$style]="${styles[$style]}"
  done

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
