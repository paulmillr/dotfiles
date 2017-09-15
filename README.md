# Dotfiles
Colourful & robust macOS configuration files and utilities.

Installation is done with simple command set (see “building system from scratch” for setup of new system):

```
curl --silent https://raw.githubusercontent.com/paulmillr/dotfiles/master/install.sh | sh
```

## Additional steps

1. Create `~/Developer/`
2. Change default shell to ZSH: `chsh -s /bin/zsh`.
3. Install XCode.
4. Install [Hermit](https://pcaro.es/p/hermit/#downloads) font.
5. Change Terminal.app theme to `terminal/paulmillr.terminal` (Settings -> Profiles -> Press gear -> Import).

## Features

![](https://cloud.githubusercontent.com/assets/574696/3210643/80f11554-eed7-11e3-8c8f-5509bc304fc7.png)

![](https://cloud.githubusercontent.com/assets/574696/3210642/7ecc9a00-eed7-11e3-9357-27c2a8576f80.png)

Shell (zsh):

* **NO DEPENDENCIES!**
* Auto-completion
* Syntax highlighting
* Automatic setting up of terminal tab / window title to current dir
* `rm` moves file to the macOS trash
* A bunch of useful functions:
    * `extract archive.tar.bz` — unpack any archive (supports many extensions)
    * `ram safari` — show app RAM usage
    * `openfiles` — real-time disk usage monitoring with `dtrace`.
    * `loc py coffee js html css` — count lines of code
    in current dir in a colourful way.
    * `ff file-name-or-pattern` - fast recursive search for a file name in directories.
    * `curl http://site/v1/api.json | json` - pretty-print JSON
    * `aes-enc`, `aes-dec` - safely encrypt files.
* Neat git extras:
    * Opinionated `git log`, `git graph`
    * `gcp` for fast `git commit -m ... && git push`
    * `git pr <pull-req> [origin]` for fetching pull request branches
    * `git cleanup` — clean up merged git branches. Very useful if
    you’re doing github pull requests in topic branches.
    * `git summary` — outputs commit email statistics.
    * `git release` — save changes, tag commit. If used on node.js project, also push to npm.
    * `git url` - opens GitHub repo for current git repo.
    * `git-changelog`, `git-setup` etc.
* [homesick](https://github.com/technicalpickles/homesick) /
  [homeshick](https://github.com/andsens/homeshick)-compatible

## Structure
* `bin` — files that are symlinked to any directory with binaries in `$PATH`
* `etc` — various stuff like macOS text substitutions / hosts backup
* `git-extras` — useful git functions, defined in `home/gitconfig`. Don't forget to change your git author to a proper name.
* `home` — files that are symlinked to `$HOME` directory
* `sublime` — sublime text 2 theme & settings
* `terminal` — terminal theme & prompt

## Building system from scratch (reminder)

* Insert proper hosts from `etc/hosts` to system’s `/etc/hosts`.
* Clone this project (dotfiles **RECURSIVELY** `--recursive`) and run `sh bootstrap-new-system.sh`
* Download the Yosemite style [Sublime Text icon](https://dribbble.com/shots/1840393-Sublime-Text-Yosemite-Icon?list=searches&tag=sublime_text) (instructions on usage are included in download)
* Install Sublime packages with Package Control: "Seti UI"

## License

[MIT](https://github.com/paulmillr/mit) (c) 2016 Paul Miller (https://paulmillr.com)
