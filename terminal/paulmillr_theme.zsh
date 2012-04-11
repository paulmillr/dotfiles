#
# Simple, colourful and one-line theme. Based on "sorin" theme.
#

function prompt_paulmillr_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS

  if (( $+functions[git-info] )); then
    # git-info
  fi
}

function prompt_paulmillr_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent subst)

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd prompt_paulmillr_precmd

  zstyle ':omz:module:git' action ':%%B%F{yellow}%s%f%%b'
  zstyle ':omz:module:git' added '%%B%F{green}+%f%%b'
  zstyle ':omz:module:git' branch ':%F{red}%b%f'
  zstyle ':omz:module:git' commit ':%F{green}%.7c%f'
  zstyle ':omz:module:git' deleted '%%B%F{red}!%f%%b'
  zstyle ':omz:module:git' modified '%%B%F{blue}!%f%%b'
  zstyle ':omz:module:git' info \
    'prompt'  ' %F{blue}git%f$(coalesce "%b" "%p" "%c")%s' \
    'rprompt' ' %A%B%S%a%d%m%r%U%u'

#   PROMPT='\
# %F{cyan}%1~%f${(e)git_info[prompt]}${git_info[rprompt]}\
# %(!.%B%F{red}#%f%b.%B%F{green} $%f%b) '
  PROMPT='\
%F{cyan}%1~%f\
%(!.%B%F{red}#%f%b.%B%F{green} $%f%b) '
  SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

prompt_paulmillr_setup "$@"

