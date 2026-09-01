# Dotfiles
Colourful & robust security-minded configuration files and utilities for Mac, Linux and BSD.

```sh
git clone https://github.com/paulmillr/dotfiles.git "$HOME/Developer/personal/dotfiles"
cd "$HOME/Developer/personal/dotfiles"

curl -s https://github.com/paulmillr.gpg | gpg --import
[ "$(git log -1 --format=%GP)" = "78A89CD10959782E23FF8447697079DA6878B89B" ] || { echo 'commit is not signed with the expected key'; exit 1; }
git show --stat --oneline HEAD

./install.sh
```

The installer performs no network requests; it invokes `./scripts/link.sh` from its own checkout.
Displaced paths are preserved as `.bak`, `.bak.1`, and so on.

## Features
<img width="957" height="551" alt="Image" src="

![](https://github.com/user-attachments/assets/e7ff10bc-26a8-4f26-8db8-644ab7e2863b)
![](https://github.com/user-attachments/assets/1970df75-80b6-4f04-816e-73be674b96dc)

* **No external dependencies!** Great, when compared to oh-my-zsh or prezto.
* Auto-completion & syntax highlighing for zsh
* Security-minded:
    * The branch names, archives, directory names, and other local users are assumed hostile.
    * The installer doesn't do network and is verifiable / reversible.
    * git offers exactly ONE key to git hosts via `IdentitiesOnly=yes`
    * git log shows signature status
    * Telemetry is disabled to known scripts via env vars like `DO_NOT_TRACK=1`
* `home` has tiny files installed into `$HOME` - `zshrc`, `bashrc`, `gitconfig`
* `config/` has all the important parts:
    * `shell/` - zsh & bash setup + extra helper functions
    * `git/` - git log formatting
    * `vim/` - turns vim into full-fledged mini-IDE, with tree view and other plugins
    * `terminal-themes/` - color scheme for apple terminal, iterm and ghostty (where it's shipped by default)
    * `ghostty/`, `vscode/` - some settings for terminal and editor

## Git setup

Specify git author:

```sh
git config --global user.name "Diogenes of Sinope"
git config --global user.email "diogenes@barrel.com"
```

To enable checkboxes in git logs, also add `config/git/mailmap`:

```text
ME <diogenes@barrel.com> <diogenes@barrel.com>
ME <diogenes@barrel.com> <diogenes@agora.example>
```

Enable GPG commit signing:

```sh
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

## License

The MIT License (MIT)

Copyright (c) 2011 Paul Miller [(paulmillr.com)](https://paulmillr.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
