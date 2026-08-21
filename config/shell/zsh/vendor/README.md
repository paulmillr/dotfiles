# Vendored Zsh plugins

These plugins are checked in as ordinary source files, not Git submodules:

- [zsh-completions](https://github.com/zsh-users/zsh-completions) at commit `d1968bd3329c9376b7ce6e37e835e61ca22baab1`
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) at commit `c4d95591843d49838b7ad30081e7aba3135a6703`

Only runtime files and upstream licenses are retained. `zsh-completions` keeps
a curated set of definitions for commands present on the reference machine,
plus these explicitly retained commands: `certbot`, `chromium`, `cmake`,
`diskutil`, `golang`, `httpie`, `mkcert`, `nftables`, `playwright`, `tox`,
`ufw`, and `virtualbox`. `zsh-syntax-highlighting` keeps its loader and the
`main` highlighter selected by `zshrc.zsh`; its other highlighters are
intentionally omitted.

When updating either plugin, exclude development files and `.git` metadata,
preserve the curated runtime subset, and update the corresponding commit above.
Run `./scripts/update-vendor.sh` from the repository root to perform that
update automatically.
