#!/bin/sh

[ "${SHELL##/*/}" != "zsh" ] && echo 'You might need to change default shell to zsh: `chsh -s /bin/zsh`'
dev="$HOME/Developer/personal"
mkdir -p $dev && cd $dev
git clone --filter=blob:none --depth 1 --recurse-submodules --shallow-submodules https://github.com/paulmillr/dotfiles.git
cd dotfiles
sh etc/symlink-dotfiles.sh

# Optional: remove .git directories
# rm -rf .git vim/.git terminal/completion/.git terminal/highlight/.git .gitmodules
# Optional: remove scripts
# rm install.sh etc/symlink-dotfiles.sh README.md
