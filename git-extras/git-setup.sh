#!/usr/bin/env sh

repo="$1"

if [[ -z "$repo" ]]; then
  echo "Syntax: git setup user/project"
  echo "Example: git setup paulmillr/ostio"
  exit
fi

mkdir -p "$dev/$repo" && \
  cd "$dev/$repo" && \
  git init && \
  touch 'README.md' 'CHANGELOG.md' && \
  cp "$HOME/.gitignore" '.gitignore' && \
  git add "*" && git add '.gitignore' && \
  git commit -m 'Initial commit.' && \
  git remote add origin "git@github.com:$repo" && \
  git push -u origin master
