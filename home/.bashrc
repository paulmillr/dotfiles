# Intentionally not linked by scripts/link.sh; source this file manually.

_dotfiles_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
_dotfiles_shared="$_dotfiles_root/config/shell/shared.sh"

if [ -r "$_dotfiles_shared" ]; then
  . "$_dotfiles_shared"
else
  printf 'Dotfiles shared shell configuration is unavailable: %s\n' \
    "$_dotfiles_shared" >&2
fi

unset _dotfiles_shared _dotfiles_root

if [[ $- == *i* ]]; then
  # Simple prompt.
  #
  # dotfiles ❯ (default)
  # dotfiles master ❯ (in git repository)
  #
  # * is appended to the Git branch name if the repository is dirty.
  # ❯ is green or red depending on the previous command's exit status.
  _bash_prompt_exit_status=0
  _bash_prompt_symbol='❯'
  _bash_prompt_symbol_color=$'\033[1;32m'
  _bash_prompt_vcs_info=''

  _bash_prompt_capture_status() {
    _bash_prompt_exit_status=$?
    return "$_bash_prompt_exit_status"
  }

  _bash_prompt_update() {
    local dirty=''
    local git_status
    local ref

    _bash_prompt_vcs_info=''
    if ref=$(command git symbolic-ref --short -q HEAD 2> /dev/null); then
      if git_status=$(command git status --porcelain=v1 --ignore-submodules=all 2> /dev/null); then
        [[ -n $git_status ]] && dirty='*'
        _bash_prompt_vcs_info=" ${ref}${dirty}"
      fi
    fi

    if (( EUID == 0 )); then
      _bash_prompt_symbol='#'
      _bash_prompt_symbol_color=$'\033[1;31m'
    elif (( _bash_prompt_exit_status == 0 )); then
      _bash_prompt_symbol='❯'
      _bash_prompt_symbol_color=$'\033[1;32m'
    else
      _bash_prompt_symbol='❯'
      _bash_prompt_symbol_color=$'\033[1;31m'
    fi
  }

  PS1='\[\033[94m\]\W\[\033[0m\]${_bash_prompt_vcs_info} \[${_bash_prompt_symbol_color}\]${_bash_prompt_symbol}\[\033[0m\] '

  if [[ -z ${_dotfiles_bash_prompt_installed:-} ]]; then
    _dotfiles_bash_prompt_installed=1
    _dotfiles_previous_prompt_command=${PROMPT_COMMAND-}
    PROMPT_COMMAND='_bash_prompt_capture_status'
    if [[ -n $_dotfiles_previous_prompt_command ]]; then
      PROMPT_COMMAND+=$'\n'"$_dotfiles_previous_prompt_command"
    fi
    PROMPT_COMMAND+=$'\n_bash_prompt_update'
    unset _dotfiles_previous_prompt_command
  fi
fi
