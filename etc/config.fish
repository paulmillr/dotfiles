# Test file for [fish shell](http://fishshell.com).

set dev $HOME/Development
set pm $dev/paulmillr
set br $dev/brunch
set ch $dev/chaplinjs
set com $dev/com
set as "$HOME/Library/Application Support"
set GEM_HOME "$HOME/Library/Ruby/Gems/1.8"

set PATH $GEM_HOME/bin /usr/local/bin /usr/local/share/{python,python3} /usr/local/share/npm/bin $PATH

# macOS trash (`brew install trash`) util.
function rm
  trash $argv
end

function lock
  /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
end

function sniff
  sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'
end

function tower
  gittower --status
end

function edit
  set dir $argv[1]
  subl $dir
end

# TODO: add ram, hist, zip-pass, pack-tar, unpack-tar

function fish_prompt
  # set_color yellow
  # echo -n (date +'%H:%M') ' '
  # set_color cyan
  # echo -n (pwd)
  # set_color green
  #echo -n ' ❯'

  if not set -q -g __fish_robbyrussell_functions_defined
  set -g __fish_robbyrussell_functions_defined
  function _git_branch_name
    echo (git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
  end

  function _is_git_dirty
    echo (git status -s --ignore-submodules=dirty ^/dev/null)
  end
  end

  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l blue (set_color -o blue)
  set -l green (set_color -o green)
  set -l normal (set_color normal)

  set -l arrow "$yellow" (date +'%H:%M') ' '
  set -l cwd $cyan(basename (prompt_pwd))

  if [ (_git_branch_name) ]
  set -l git_branch $red(_git_branch_name)
  set git_info "$blue git:$git_branch$blue"

  if [ (_is_git_dirty) ]
    set -l dirty "$yellow ✗"
    set git_info "$git_info$dirty"
  end
  end

  echo -n -s $arrow $cwd $git_info $green ' ❯ ' $normal

end
