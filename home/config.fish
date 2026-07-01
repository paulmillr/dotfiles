# Fish shell configuration for these dotfiles.

umask 022
set -g fish_greeting

set -g dev "$HOME/Developer"
set -g pm "$dev/personal"

function __pm_stat_uid_mode
  if stat -c '%u %a' / >/dev/null 2>/dev/null
    stat -c '%u %a' -- $argv
  else
    stat -f '%u %Lp' $argv
  end
end

function __pm_realpath
  if command -sq realpath
    realpath $argv
  else if command -sq perl
    perl -MCwd=abs_path -e 'print abs_path(shift)' -- $argv
  else
    return 1
  end
end

function __pm_is_trusted_path
  set -l target "$argv[1]"
  test -n "$target"; and test -e "$target" -o -L "$target"; or return 1

  set -l resolved (__pm_realpath "$target"); or return 1
  set -l home_resolved (__pm_realpath "$HOME"); or return 1

  string match -q -- "$home_resolved" "$resolved"; or string match -q -- "$home_resolved/*" "$resolved"
  or begin
    echo "Refusing to source $target: resolved path is outside HOME" >&2
    return 1
  end

  set -l current "$resolved"
  set -l current_uid (id -u)
  while true
    set -l stat_fields (string split ' ' -- (__pm_stat_uid_mode "$current")); or return 1
    set -l owner "$stat_fields[1]"
    set -l mode "$stat_fields[2]"

    if test "$owner" != "$current_uid"; and test "$owner" != 0
      echo "Refusing to source $current: owner is neither current user nor root" >&2
      return 1
    end

    set -l perms (string sub -s -2 -- "00$mode")
    set -l group_perm (string sub -s 1 -l 1 -- "$perms")
    set -l world_perm (string sub -s 2 -l 1 -- "$perms")
    if contains -- "$group_perm" 2 3 6 7; or contains -- "$world_perm" 2 3 6 7
      echo "Refusing to source $current: group/world-writable" >&2
      return 1
    end

    test "$current" = "$home_resolved"; and break
    set current (dirname "$current")
  end
end

function __pm_import_sh_env
  set -l file "$argv[1]"

  __pm_is_trusted_path "$file"; or return 1

  chmod go-rwx "$file" 2>/dev/null
  for entry in (env -i HOME="$HOME" USER="$USER" LOGNAME="$LOGNAME" PATH="$PATH" sh -c 'set -a; . "$1"; env -0' sh "$file" | string split0)
    set -l name (string replace -r '=.*$' '' -- "$entry")
    set -l value (string replace -r '^[^=]*=' '' -- "$entry")

    string match -rq '^[A-Za-z_][A-Za-z0-9_]*$' -- "$name"; or continue
    contains -- "$name" PWD SHLVL _; and continue
    set -gx "$name" "$value"
  end
end

set -l privenv "$HOME/.private-env"
if test -e "$privenv" -o -L "$privenv"
  __pm_import_sh_env "$privenv"; or echo "Skipping untrusted private env file: $privenv" >&2
end

if test -x /opt/homebrew/bin/brew
  set -gx HOMEBREW_PREFIX /opt/homebrew
  set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
  set -gx HOMEBREW_REPOSITORY /opt/homebrew
  fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
  if set -q MANPATH
    set -gx MANPATH ":$MANPATH"
  end
  set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

if test -d "$HOME/.local/bin"
  fish_add_path -g "$HOME/.local/bin"
end

if test -z "$LANG"
  for line in (locale 2>/dev/null)
    set -l name (string replace -r '=.*$' '' -- "$line")
    set -l value (string replace -r '^[^=]*=' '' -- "$line" | string trim -c '"')
    switch "$name"
      case LANG 'LC_*'
        set -gx "$name" "$value"
    end
  end
end

set -gx LESS '-F -g -i -M -R -S -w -X -z-4'
set -gx LESSHISTFILE -
set -gx PAGER less
if command -sq batcat
  alias bat=batcat
end

if test -n "$TMPDIR"; and test -d "$TMPDIR"
  set -gx TMPPREFIX (string replace -r '/$' '' -- "$TMPDIR")/fish
  if not test -d "$TMPPREFIX"
    mkdir -m 700 -p "$TMPPREFIX"
  end
  chmod 700 "$TMPPREFIX" 2>/dev/null
end

set -e BROWSER
set -gx DO_NOT_TRACK 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_AUTO_UPDATE_SECS 2592000
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_CURLRC 1
set -gx CHECKPOINT_DISABLE 1
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx POWERSHELL_TELEMETRY_OPTOUT 1
set -gx SAM_CLI_TELEMETRY 0
set -gx NEXT_TELEMETRY_DISABLED 1
set -gx GATSBY_TELEMETRY_DISABLED 1
set -gx AZURE_CORE_COLLECT_TELEMETRY 0
set -gx NODE_REPL_HISTORY ''
set -gx OLLAMA_NOHISTORY 1
set -gx OLLAMA_NO_CLOUD 1

set -gx JSBT_FAST -4
set -gx JSBT_QUIET 1
set -gx MSHOULD_QUIET 1
set -gx MSHOULD_FAST 12

set -l gitssh "$HOME/.ssh/git"
if test -f "$gitssh"
  chmod go-rwx "$gitssh" 2>/dev/null
  set -gx GIT_SSH_COMMAND "ssh -F /dev/null -i "(string escape --style=script -- "$gitssh")
end

if command -sq code
  set -gx EDITOR (command -s code)
  set -gx VISUAL "$EDITOR"
else if command -sq vim
  set -gx EDITOR (command -s vim)
  set -gx VISUAL "$EDITOR"
end

set -gx SSH_AUTH_SOCK "$HOME/.gnupg/S.gpg-agent.ssh"

if status is-interactive
  stty icrnl 2>/dev/null
  set -gx GPG_TTY (tty)
end

switch (uname)
  case Darwin
    alias paste=pbpaste
    alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
    alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
    alias pgrep='pgrep -fli'
  case '*'
    alias pgrep='pgrep -fl'
    alias ctl=systemctl
    alias jctl=journalctl
end

function _git_with_utc_dates
  set -l ndate (date -u +%Y-%m-%dT%H:%M:%S%z)
  set -q GIT_AUTHOR_DATE; or set -lx GIT_AUTHOR_DATE "$ndate"
  set -q GIT_COMMITTER_DATE; or set -lx GIT_COMMITTER_DATE "$ndate"
  command git $argv
end

function gm
  _git_with_utc_dates merge $argv
end

function gu
  _git_with_utc_dates pull $argv
end

alias g=git
alias ga='git add'
alias gd='git diff'
alias gf='git fetch'
alias gp='git push'
alias gs='git status --short'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
alias gcl='git clone'
alias gch='git checkout'
alias gds='git diff --staged'
alias gdisc='git reset --hard HEAD'

function git_stats
  git log --no-merges --pretty='format:%an <%ae>' | sort | uniq -c | sort -r
end

function git_timezones
  git log --pretty='format:%an %ad' --date=format:'%z' | sort | uniq -c | sort -r
end

function git_submodules
  git submodule update --init --recursive
end

alias gitsub=git_submodules

function gback
  set -l subj (git log -1 --format='%s')
  echo -e "reverting commit\n"(set_color red)"$subj"(set_color normal)"\n"
  git reset HEAD~1
end

function gc
  _git_with_utc_dates commit -m (string join ' ' -- $argv)
end

function gcam
  _git_with_utc_dates commit --amend -m (string join ' ' -- $argv)
end

function gcp
  _git_with_utc_dates commit -am (string join ' ' -- $argv); and _git_with_utc_dates push -u origin
end

function gl
  git --no-pager log -10 --graph
end

function git_release
  set -l tag "$argv[1]"
  if test -z "$tag"
    echo 'Usage: git_release <tag>' >&2
    return 2
  end

  echo "... releasing $tag"
  _git_with_utc_dates commit -a -m "Release $tag."; and \
    _git_with_utc_dates tag -m '' -- "$tag"; and \
    command git push; and \
    command git push --tags; and \
    echo '... complete'
end

function git_rmtag
  set -l tag "$argv[1]"
  if test -z "$tag"
    echo 'Usage: grmtag <tag>' >&2
    return 2
  end

  git tag -d -- "$tag"
  git push origin ":refs/tags/$tag"
end

function git_cherry
  set -l commits
  if test (count $argv) -eq 1; and string match -q '*.*' -- "$argv[1]"
    set commits (git rev-list --reverse --topo-order "$argv[1]")
  else
    set commits $argv
  end

  set -l total (count $commits)
  echo "Picking $total commits:"
  for commit in $commits
    echo "$commit"
    git cherry-pick -n -- "$commit"; or break
    if test "$CC" = 1
      cherrycc "$commit"
    end
  end
end

function git_raw
  set -l sep (printf '\x1f')
  git log --pretty='tformat:%H%x1f%an%x1f%ae%x1f%ad%x1f%cd%x1f%s' --date=format:'%Y-%m-%dT%H:%M:%S%z' |
    while read -l line
      set -l fields (string split "$sep" -- "$line")
      set -l hash "$fields[1]"
      set -l name "$fields[2]"
      set -l email "$fields[3]"
      set -l author_date "$fields[4]"
      set -l committer_date "$fields[5]"
      set -l title "$fields[6]"

      if test "$author_date" = "$committer_date"
        echo (set_color red)"$hash"(set_color normal)" $title "(set_color green)"($author_date) "(set_color yellow)"$name <$email>"(set_color normal)
      else
        echo (set_color red)"$hash"(set_color normal)" $title "(set_color green)"($author_date, cmt=$committer_date) "(set_color yellow)"$name <$email>"(set_color normal)
      end
    end
end

alias cl=clear
alias serve='python3 -m http.server --bind 127.0.0.1'
alias server=serve
alias hist='history search --contains'
alias history-stats="history | awk '{print \$1}' | sort | uniq -c | sort -r | head"
alias net="ping google.com | grep -E --color=never '[0-9\.]+ ms'"
alias remove-node-modules="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
alias ni='npm install'
alias nr='node --run'
alias nt='node --run test'
alias nrb='node --run build'
alias bench='node --run benchmark'
alias npm-dry='npm pack --dry-run'
alias jsr-dry='jsr publish --dry-run'

function npm-reinstall
  rm package-lock.json
  rm -r node_modules
  npm install
end

function sshtunnel
  set -l usage "usage: sshtunnel PORT_OURS PORT_THEIRS HOST\nsshtunnel 1234 5678 example.com"
  set -l port_ours "$argv[1]"
  set -l port_theirs "$argv[2]"
  set -l hostn "$argv[3]"

  string match -rq '^[0-9]+$' -- "$port_ours"; and string match -rq '^[0-9]+$' -- "$port_theirs"; and test -n "$hostn"
  or begin
    echo -e "$usage"
    return 1
  end

  if test "$port_ours" -lt 1 -o "$port_ours" -gt 65535 -o "$port_theirs" -lt 1 -o "$port_theirs" -gt 65535
    echo -e "$usage"
    return 1
  end

  set -l all "$port_ours:127.0.0.1:$port_theirs"
  echo "Tunnelling $all on $hostn"
  ssh -L "$all" -- "$hostn"
end

function edit
  set -l dir "$argv[1]"
  test -n "$dir"; or set dir .
  set -l editor_cmd "$EDITOR"
  test -n "$editor_cmd"; or set editor_cmd vi
  set -l editor (string split ' ' -- "$editor_cmd")
  command $editor -- "$dir"
end

alias e=edit

function each
  if test (count $argv) -eq 0
    echo 'Usage: each <command> [args...]' >&2
    return 2
  end

  set -l oldpwd "$PWD"
  for dir in */
    test -d "$dir"; or continue
    builtin cd -- "$dir"; or continue
    $argv
    builtin cd -- "$oldpwd"; or return
  end
end

function find-file
  find . -iname "*$argv[1]*"
end

function find-exec
  set -l pattern "$argv[1]"
  set -l cmd "$argv[2]"
  test -n "$cmd"; or set cmd file
  find . -type f -iname "*$pattern*" -exec "$cmd" '{}' ';'
end

function terminal-colors-256
  set -l color 0
  while test "$color" -lt 256
    printf '\033[38;5;%sm%3s\033[0m ' "$color" "$color"
    set color (math "$color + 1")
    if test (math "$color % 16") -eq 0
      printf '\n'
    end
  end
end

function _calcram_kib
  set -l app (string lower -- "$argv[1]")
  test -n "$app"; or return 2
  ps axww -o rss= -o command= | awk -v app="$app" '
    {
      rss=$1
      $1=""
      if (index(tolower($0), app) > 0) sum += rss
    }
    END { print sum + 0 }
  '
end

function _ram_format_mib
  set -l kib "$argv[1]"
  test -n "$kib"; or set kib 0
  awk -v kib="$kib" 'BEGIN { printf "%.2f", kib / 1024 }'
end

function _calcram
  set -l kib (_calcram_kib "$argv[1]"); or return
  _ram_format_mib "$kib"
end

function ram
  set -l app "$argv[1]"
  if test -z "$app"
    echo 'First argument - process name or command substring'
    return 0
  end

  set -l kib (_calcram_kib "$app"); or return
  set -l sum (_ram_format_mib "$kib")
  if test "$kib" -gt 0
    echo (set_color blue)"$app"(set_color normal)" uses "(set_color green)"$sum"(set_color normal)" MiB of RAM"
  else
    echo "No active processes matching substring '"(set_color blue)"$app"(set_color normal)"'"
  end
end

function ram-streaming
  set -l app "$argv[1]"
  if test -z "$app"
    echo 'First argument - process name or command substring'
    return 0
  end

  while true
    set -l kib (_calcram_kib "$app"); or return
    set -l sum (_ram_format_mib "$kib")
    if test "$kib" -gt 0
      printf '\r\033[K%s uses %s MiB of RAM' (set_color blue)"$app"(set_color normal) (set_color green)"$sum"(set_color normal)
    else
      printf '\r\033[KNo active processes matching substring %s' "'"(set_color blue)"$app"(set_color normal)"'"
    end
    sleep 0.1
  end
end

function size
  du -shck $argv | sort -rn | awk '
      function human(x) {
          s="kMGTEPYZ";
          while (x>=1000 && length(s)>1)
              {x/=1024; s=substr(s,2)}
          return int(x+0.5) substr(s,1,1)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
end

function compute
  while true
    head -n 100 /dev/urandom
    sleep 0.1
  end | hexdump -C | grep 'ca fe'
end

function maxcpu
  if command -sq nproc
    set cores (nproc)
  else
    set cores (sysctl -n hw.ncpu)
  end

  set -l i 0
  while test "$i" -lt "$cores"
    yes >/dev/null &
    set i (math "$i + 1")
  end
  echo "Loaded $cores cores. To stop: 'killall yes'"
end

function _tar_require_one_path
  set -l usage "$argv[1]"
  set -e argv[1]

  if test (count $argv) -ne 1; or test -z "$argv[1]"
    echo "Usage: $usage" >&2
    return 2
  end
end

function _tar_require_existing_path
  set -l path "$argv[1]"
  if not test -e "$path" -o -L "$path"
    echo "No such path: $path" >&2
    return 1
  end
end

function _tar_reject_unsafe_member_names
  for member in $argv
    switch "$member"
      case '/*' '..' '../*' '*/..' '*/../*'
        echo "Refusing to extract unsafe archive member: $member" >&2
        return 1
    end
  end
end

function _tar_reject_unsafe_member_types
  for member in $argv
    set -l typechar (string sub -s 1 -l 1 -- "$member")
    if contains -- "$typechar" l h b c p
      echo "Refusing to extract archive with special member: $member" >&2
      return 1
    end
  end
end

function _tar_reject_unsafe_members
  set -l archive "$argv[1]"
  set -e argv[1]

  set -l listing (tar $argv -t -f "$archive"); or return 1
  _tar_reject_unsafe_member_names $listing; or return

  set -l verbose_listing (tar $argv -t -v -f "$archive"); or return 1
  _tar_reject_unsafe_member_types $verbose_listing
end

function _tar_safe_extract
  set -l archive "$argv[1]"
  set -e argv[1]

  _tar_require_existing_path "$archive"; or return
  _tar_reject_unsafe_members "$archive" $argv; or return
  tar $argv -x -v -k -o -f "$archive"
end

function _tar_safe_extract_pbzip2
  set -l archive "$argv[1]"
  _tar_require_existing_path "$archive"; or return

  set -l listing (pbzip2 -d -c -- "$archive" | tar -t -f -); or return 1
  _tar_reject_unsafe_member_names $listing; or return

  set -l verbose_listing (pbzip2 -d -c -- "$archive" | tar -t -v -f -); or return 1
  _tar_reject_unsafe_member_types $verbose_listing; or return

  pbzip2 -d -c -- "$archive" | tar -x -v -k -o -f -
end

function _tar_require_bzip2
  if not command -sq pbzip2; and not command -sq bzip2
    echo 'bzip2 or pbzip2 is required for .tar.bz2 archives' >&2
    return 1
  end
end

function tar_
  _tar_require_one_path 'tar_ <path>' $argv; or return
  _tar_require_existing_path "$argv[1]"; or return
  tar -c -v -f "$argv[1].tar" -- "$argv[1]"
end

function untar
  _tar_require_one_path 'untar <archive.tar>' $argv; or return
  _tar_safe_extract "$argv[1]"
end

function tar_nometa
  set -l src "$argv[1]"
  set -l name (basename "$src")
  set -l stage (mktemp -d)

  ditto --norsrc --noextattr --noacl "$src" "$stage/$name"
  chflags -R 0 "$stage/$name"
  xattr -cr "$stage/$name"
  chmod -RN "$stage/$name"
  dot_clean -m "$stage/$name"
  find "$stage/$name" -name .DS_Store -type f -delete
  find "$stage/$name" -name '._*' -type f -delete
  find "$stage/$name" -type d -exec chmod 755 '{}' +
  find "$stage/$name" -type f -exec chmod 644 '{}' +
  env TZ=UTC find "$stage/$name" -exec touch -h -t 197001010000.00 '{}' +
  env COPYFILE_DISABLE=1 tar \
    --format=ustar \
    --numeric-owner \
    --uid 0 \
    --gid 0 \
    --no-acls \
    --no-xattrs \
    --no-fflags \
    --no-mac-metadata \
    -cf archive.tar \
    -C "$stage" "$name"
  env TZ=UTC touch -h -t 197001010000.00 archive.tar
  echo archive.tar created
end

function tarbz2
  _tar_require_one_path 'tarbz2 <path>' $argv; or return
  _tar_require_existing_path "$argv[1]"; or return
  _tar_require_bzip2; or return

  set -l inf "$argv[1]"
  set -l outf "$argv[1].tar.bz2"
  if command -sq pbzip2
    tar -c -v -f - -- "$inf" | pbzip2 -c > "$outf"
  else
    tar -c -v -j -f "$outf" -- "$inf"
  end
end

function tarxz
  _tar_require_one_path 'tarxz <path>' $argv; or return
  _tar_require_existing_path "$argv[1]"; or return
  env XZ_OPT=-9 tar -c -v -J -f "$argv[1].tar.xz" -- "$argv[1]"
end

function untarbz2
  _tar_require_one_path 'untarbz2 <archive.tar.bz2>' $argv; or return
  _tar_require_existing_path "$argv[1]"; or return
  _tar_require_bzip2; or return

  if command -sq pbzip2
    _tar_safe_extract_pbzip2 "$argv[1]"
  else
    _tar_safe_extract "$argv[1]" -j
  end
end

function untarxz
  _tar_require_one_path 'untarxz <archive.tar.xz>' $argv; or return
  _tar_safe_extract "$argv[1]" -J
end

function __pm_prompt_pwd
  if test "$PWD" = "$HOME"
    echo '~'
  else if test "$PWD" = /
    echo /
  else
    basename "$PWD"
  end
end

function __pm_prompt_vcs
  set -l ref (command git symbolic-ref --short -q HEAD 2>/dev/null); or return 0
  set -l git_status (command git status --porcelain=v1 --ignore-submodules=all 2>/dev/null); or return 0
  set -l dirty
  if test (count $git_status) -gt 0
    set dirty '*'
  end
  printf ' %s%s' "$ref" "$dirty"
end

function fish_prompt
  set -l last_status $status

  if test -n "$SSH_TTY"
    printf '%s@%s ' "$USER" (hostname -s 2>/dev/null; or hostname)
  end

  printf '\033[38;5;12m%s%s' (__pm_prompt_pwd) (set_color normal)
  __pm_prompt_vcs

  if test (id -u) -eq 0
    printf ' %s%s#%s ' (set_color --bold red) '' (set_color normal)
  else if test "$last_status" -eq 0
    printf ' %s%s%s ' (set_color --bold green) '❯' (set_color normal)
  else
    printf ' %s%s%s ' (set_color --bold red) '❯' (set_color normal)
  end
end

function fish_title
  __pm_prompt_pwd
end

functions -e __pm_import_sh_env __pm_is_trusted_path __pm_realpath __pm_stat_uid_mode
