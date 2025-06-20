# Dotfiles
Colourful & robust configuration files and utilities for Mac, Linux and BSD. Installation is done with a simple command:

```sh
curl -L https://git.io/pmdot | sh
```

The short URL expands to GitHub-hosted `install.sh`,
and then `etc/symlink-dotfiles.sh`,
which can be easily audited.

## Usage

- **MacOS:** Ensure you have XCode or dev tools. It can be downloaded from the app store.
    - Optionally `sh etc/bootstrap-macos.sh`
- **Linux and BSD:** Ensure you have `git` and `zsh` installed.
- **MacOS terminal:** `terminal/macos-term/monokai_pro_spectrum.terminal` (Settings -> Profiles -> Press "gear" -> Import).
- **Git:** Don't forget to adjust `home/.gitconfig` or you'll have improper commit author

## Features

![](https://user-images.githubusercontent.com/574696/61765243-eb19dc00-ade4-11e9-8d16-5a402a0fdfec.png)
![](https://user-images.githubusercontent.com/574696/61765242-eb19dc00-ade4-11e9-8db0-ac607e1eed8a.png)

* **No external dependencies!** Great, when compared to oh-my-zsh.
* Auto-completion
* Syntax highlighting
* Useful utilities:
    * `ff file-name-or-pattern` - fast recursive search for a file name in directories.
    * `tarbz2`, `untarbz2` - best archive compression. Utilizes parallel `pbzip2` when available.
    * `ram safari` — show app RAM usage
    * `curl http://site/v1/api.json | json` - pretty-print JSON
* `git-extras` - useful git functions, defined in `home/.gitconfig`:
    * Opinionated `git log`, `git graph`
    * `gcp` for fast `git commit -m ... && git push`
    * `git sign` for PGP-signed git
    * `git cleanup` — clean up merged git branches. Very useful if
    you’re doing github pull requests in topic branches.
    * `git summary` — outputs commit email statistics.
    * `git release` and `git sign-release` — commit and tag the commit. Publishes to NPM for node projects.
    * `git url` - opens GitHub repo for current git repo.
    * `git-changelog`, `git-setup` etc.
* `etc` — MacOS fine tuning
* `vscode` — Sublime Text theme & settings
* Sets terminal tab and window title to current directory
* [homesick](https://github.com/technicalpickles/homesick) /
  [homeshick](https://github.com/andsens/homeshick)-compatible

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
