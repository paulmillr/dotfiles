# Dotfiles
Colourful & robust OS X configuration files and utilities.

Installation is done with simple command set (see “building system from scratch” for setup of new system):

```
curl --silent https://raw.github.com/paulmillr/dotfiles/master/install.sh | sh
```

## Features

![](https://f.cloud.github.com/assets/574696/1608018/3ffd422c-54c0-11e3-9cc8-b8c4871a763e.png)

![](https://f.cloud.github.com/assets/574696/1608019/42dccae4-54c0-11e3-9f4f-def428e77067.png)

Shell (zsh):

* Auto-completion
* Syntax highlighting
* Automatic setting up of terminal tab / window title to current dir
* `rm` moves file to the OS X trash
* A bunch of useful functions:
    * `extract archive.tar.bz` — unpack any archive (supports many extensions)
    * `ram safari` — show app RAM usage
    * `openfiles` — real-time disk usage monitoring with `dtrace`.
    * `loc py coffee js html css` — count lines of code
    in current dir in a colourful way.
* Neat git extras:
    * Opinionated `git log`, `git graph`
    * `git pr` for fetching pull request branches
    * `git cleanup` — clean up merged git branches. Very useful if
    you’re doing github pull requests in topic branches.
    * `git summary` — outputs commit email statistics.
    * `git release` — save changes, tag commit. If used on node.js project, also push to npm.
    * `git-changelog`, `git-setup` etc.
* [homesick](https://github.com/technicalpickles/homesick) /
  [homeshick](https://github.com/andsens/homeshick)-compatible

## Structure
* `bin` — files that are symlinked to any directory with binaries in `$PATH`
* `etc` — various stuff like osx text substitutions / hosts backup
* `git-extras` — useful git functions, defined in `home/gitconfig`
* `home` — files that are symlinked to `$HOME` directory
* `sublime` — sublime text 2 theme & settings
* `terminal` — terminal theme & prompt

## Building system from scratch (reminder)

* Install [PT Mono](http://www.paratype.com/public/) font.
* Install XCode & its Command Line Tools.
* Change Terminal.app theme to `terminal/paulmillr.terminal`.
* Change default shell to ZSH: `chsh -s /bin/zsh`.
* Insert proper hosts from `etc/hosts` to system’s `/etc/hosts`.
* Create `~/Developer/`
* Clone:
    * prezto (oh-my-zsh fork) `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"`
    * this project (dotfiles) and run `sh bootstrap-new-system.sh`

## License

The MIT license.

Copyright (c) 2013 Paul Miller (http://paulmillr.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
