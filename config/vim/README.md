# Vim configuration

A small, terminal-only Vim setup. Plugins are bundled in `pack/`, so no plugin manager is required. The leader key is **Space**.

## Plugins

| Plugin | Purpose | Useful keys |
| --- | --- | --- |
| [CSS Color](pack/language/start/css-color) | Shows color literals using their actual color in CSS, HTML, and Vim files. | None |
| [Bclose](pack/navigation/start/bclose) | Closes a buffer without destroying its split. | `<Space>q` close, `<Space><C-q>` force close |
| [NERDTree](pack/navigation/start/nerdtree) | Provides the file tree, which opens automatically. | `<Space>n` toggle, `<Space>m` focus, `<Space>M` reveal current file |
| [NERDTree Git Status](pack/navigation/start/nerdtree-git-plugin) | Adds Git status to the tree and dims ignored files. | None |
| [NERDCommenter](pack/text/start/nerdcommenter) | Comments or uncomments the current line or visual selection. | `<Space>c<Space>` toggle |
| [Sleuth](pack/text/start/sleuth) | Detects indentation settings from nearby files. | None |
| [Signify](pack/ui/start/signify) | Shows added, changed, and deleted lines in the sign column. | `]c`/`[c` next/previous change, `]C`/`[C` last/first change |
| Matchit (built into Vim) | Extends `%` matching to tags and language structures. | `%` match forward, `g%` match backward |

Inside NERDTree, use `o` to open, `i` for a horizontal split, `s` for a vertical split, `t` for a tab, `m` for the file menu, and `?` for its built-in key reference.

## Themes

Available themes are `ice`, `bubblegum`, `gotham`, `gruvbox`, `ir_black`, `pokemon`, `prismatic`, `pyte`, `sailormoon`, and `vantablack`. Vim follows the same `LC_TERM_BG` value as bat and delta, choosing `ice` in dark mode and `sailormoon` in light mode; an absent or unknown value defaults to dark. Switch manually with `:colorscheme NAME`.

`ice` is a Vim port of Matthew Holt's [Ice Ice OLED](https://github.com/mholt/ice-ice-oled) theme.

`prismatic` is a Vim port of Chen Hui Jing's colourful front-end-focused [Prismatic](https://github.com/huijing/Prismatic) theme.

`pokemon` and `sailormoon` are Vim ports of Marko Nikolajevic's [MangaMode](https://github.com/MarkoNikolajevic/manga-mode-theme) themes. `vantablack` ports Bjarne Oeverli's [VS Code Vantablack](https://github.com/bjarneo/vantablack-vscode).

## Other useful keys

| Keys | Action |
| --- | --- |
| `<C-h>` / `<C-l>` | Previous/next buffer |
| `<Space>h/j/k/l` | Move between splits |
| `<Space>Q` | Close the current split |
| `<Space>a` | Search the project with ripgrep |
| `<Space>b` | Clear search highlighting |
| `<Space>s` | Toggle visible whitespace |
| `<Space>ev` / `<Space>es` | Edit/reload this vimrc |
| `Command-C` | Copy the visual selection on macOS in Ghostty |
| `=j` | Format the current buffer as JSON with Python 3 |

## Requirements

Vim, Git, [ripgrep](https://github.com/BurntSushi/ripgrep), and Python 3.
