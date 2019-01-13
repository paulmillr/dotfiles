# Dotfiles
Colourful & robust configuration files and utilities for Mac, Linux and BSD. Installation is done with a simple command:

```sh
curl -L https://git.io/pmdot | sh
```

The short URL expands to GitHub-hosted `install.sh`

## Usage

- **MacOS:** Ensure you have latest XCode or dev tools. It can be downloaded from the app store.
    - Optionally `sh etc/bootstrap-macos.sh`
- **Linux and BSD:** Ensure you have `git` and `zsh` installed.
- **Terminal theme:** `terminal/pm.terminal` (Settings -> Profiles -> Press gear -> Import).
- **Git:** Don't forget to adjust `home/.gitconfig` or you'll have improper commit author

## Features

![](https://cloud.githubusercontent.com/assets/574696/3210643/80f11554-eed7-11e3-8c8f-5509bc304fc7.png)

![](https://cloud.githubusercontent.com/assets/574696/3210642/7ecc9a00-eed7-11e3-9357-27c2a8576f80.png)

* **NO DEPENDENCIES!** Great when compared to oh-my-zsh.
* Auto-completion
* Syntax highlighting
* Sets terminal tab and window title to current directory
* `rm` moves file to the MacOS trash with `brew install trash`
* Useful utilities:
    * `ff file-name-or-pattern` - fast recursive search for a file name in directories.
    * `aes-enc`, `aes-dec` - safely encrypt files.
    * `tarbz2`, `untarbz2` - best archive compression. Utilizes parallel `pbzip2` when available.
    * `extract archive.tar.bz` — unpack any archive (supports many extensions)
    * `ram safari` — show app RAM usage
    * `loc py coffee js html css` — count lines of code
    * `curl http://site/v1/api.json | json` - pretty-print JSON
* `git-extras` - useful git functions, defined in `home/.gitconfig`:
    * Opinionated `git log`, `git graph`
    * `gcp` for fast `git commit -m ... && git push`
    * `git pr <pull-req> [origin]` for fetching pull request branches
    * `git cleanup` — clean up merged git branches. Very useful if
    you’re doing github pull requests in topic branches.
    * `git summary` — outputs commit email statistics.
    * `git release` — save changes, tag commit. If used on node.js project, also push to npm.
    * `git url` - opens GitHub repo for current git repo.
    * `git-changelog`, `git-setup` etc.
* `etc` — MacOS fine tuning
* `sublime` — Sublime Text theme & settings
* [homesick](https://github.com/technicalpickles/homesick) /
  [homeshick](https://github.com/andsens/homeshick)-compatible

## Not included

- Cool [Sublime Text icon](https://dribbble.com/shots/1840393-Sublime-Text-Yosemite-Icon)
- Great Sublime themes: Glacier, Nil, Seti UI

## License

The MIT License (MIT)

Copyright (c) 2019 Paul Miller [(paulmillr.com)](https://paulmillr.com)

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
