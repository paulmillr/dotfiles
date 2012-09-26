#
# Sets Prezto options.
#

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':prezto:module:editor' keymap 'emacs'

# Auto convert .... to ../..
zstyle ':prezto:module:editor' dot-expansion 'no'

# Set case-sensitivity for completion, history lookup, etc.
zstyle ':prezto:*:*' case-sensitive 'no'

# Color output (auto set to 'no' on dumb terminals).
zstyle ':prezto:*:*' color 'yes'

# Auto set the tab and window titles.
zstyle ':prezto:module:terminal' auto-title 'yes'

# Set the Zsh modules to load (man zshmodules).
# zstyle ':prezto:load' zmodule 'attr' 'stat'

# Set the Zsh functions to load (man zshcontrib).
zstyle ':prezto:load' zfunction 'zargs' 'zmv'

# Set the Prezto modules to load (browse modules).
# The order matters.
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'prompt' \
  'syntax-highlighting' \
  'git' \
  'archive' \
  'osx' \
  'node' \
  'python' \
  'ruby'

# Set the prompt theme to load.
# Setting it to 'random' loads a random theme.
# Auto set to 'off' on dumb terminals.
zstyle ':prezto:module:prompt' theme 'off'
