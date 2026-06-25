# Defines environment variables.
function _zshenv_is_trusted_path() {
  local target="$1"
  local path
  local home
  local -A st

  if [[ -z "$target" || ( ! -e "$target" && ! -L "$target" ) ]]; then
    return 1
  fi

  zmodload zsh/stat 2> /dev/null || return 1

  path="${target:A}"
  home="${HOME:A}"
  if [[ "$path" != "$home" && "$path" != "$home"/* ]]; then
    print -u2 "Refusing to source $target: resolved path is outside HOME"
    return 1
  fi

  while true; do
    zstat -H st -- "$path" || return 1

    if (( st[uid] != EUID && st[uid] != 0 )); then
      print -u2 "Refusing to source $path: owner is neither current user nor root"
      return 1
    fi

    if (( st[mode] & 8#022 )); then
      print -u2 "Refusing to source $path: group/world-writable"
      return 1
    fi

    [[ "$path" == "$home" ]] && break
    path="${path:h}"
  done
}

privenv="$HOME/.private-env"
if [[ -e "$privenv" || -L "$privenv" ]]; then
  if _zshenv_is_trusted_path "$privenv"; then
    chmod go-rwx "$privenv" 2> /dev/null
    source -- "$privenv"
  else
    print -u2 "Skipping untrusted private env file: $privenv"
  fi
fi
unset privenv

# Paths.
typeset -gU cdpath fpath mailpath manpath path
typeset -gUT INFOPATH infopath

# Commonly used directories.
dev="$HOME/Developer"
pm="$dev/personal"

if [ -f "/opt/homebrew/bin/brew" ]; then
  # option a): use brew shellenv - slow
  # option b): less reliable, faster
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
  export FPATH
  eval "$(/usr/bin/env PATH_HELPER_ROOT="/opt/homebrew" /usr/libexec/path_helper -s)"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

function _zshenv_import_locale() {
  local line
  local name
  local value
  local -a lines

  lines=("${(@f)$(locale 2> /dev/null)}") || return
  for line in "${lines[@]}"; do
    name="${line%%=*}"
    value="${line#*=}"

    case "$name" in
      LANG|LC_[A-Z_]*)
        ;;
      *)
        continue
        ;;
    esac

    if [[ "$value" == \"*\" ]]; then
      value="${value#\"}"
      value="${value%\"}"
    fi

    export "$name=$value"
  done
}

if [[ -z "${LANG:-}" ]]; then
  _zshenv_import_locale
fi

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE='-'

export PAGER='less'
if (( $+commands[batcat] )); then
  alias bat=batcat
fi
# if (( $+commands[bat] )); then
#   export PAGER='bat'
# else
#   export PAGER='less'
# fi

# for path_file in /etc/paths.d/*(.N); do
#   path+=($(<$path_file))
# done
# unset path_file

# Temporary Files.
if [[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -m 700 -p "$TMPPREFIX"
  fi
  chmod 700 "$TMPPREFIX" 2> /dev/null
fi


BROWSER=''
unset BROWSER

export DO_NOT_TRACK=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_AUTO_UPDATE_SECS='2592000' # monthly
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_CURLRC=1
export CHECKPOINT_DISABLE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export POWERSHELL_TELEMETRY_OPTOUT=1
export SAM_CLI_TELEMETRY=0
export NEXT_TELEMETRY_DISABLED=1
export GATSBY_TELEMETRY_DISABLED=1
export AZURE_CORE_COLLECT_TELEMETRY=0
export NODE_REPL_HISTORY=''
export OLLAMA_NOHISTORY=1
export OLLAMA_NO_CLOUD=1

export JSBT_FAST=-4
export JSBT_QUIET=1
export MSHOULD_QUIET=1 # micro-should, dots
export MSHOULD_FAST=12 # micro-should, workers=auto

function _zshenv_quote_sh() {
  local value="$1"
  local squote="'"

  value="${value//$squote/$squote\\$squote$squote}"
  print -r -- "$squote$value$squote"
}

gitssh="$HOME/.ssh/git"
if [[ -f $gitssh ]]; then
  chmod go-rwx "$gitssh" 2> /dev/null
  export GIT_SSH_COMMAND="ssh -F /dev/null -i $(_zshenv_quote_sh "$gitssh")"
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

unfunction _zshenv_import_locale _zshenv_is_trusted_path _zshenv_quote_sh 2> /dev/null
