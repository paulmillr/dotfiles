#!/bin/sh

[ "${SHELL##/*/}" != "zsh" ] && echo 'You might need to change default shell to zsh: `chsh -s /bin/zsh`'
dev="$HOME/Developer/test"
mkdir -p $dev && cd $dev
git clone --filter=blob:none --depth 1 --recurse-submodules --shallow-submodules https://github.com/paulmillr/dotfiles.git
cd dotfiles && rm -rf .git vim/.git terminal/completion/.git terminal/highlight/.git
sh etc/symlink-dotfiles.sh
