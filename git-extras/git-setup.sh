#!/usr/bin/env sh

dirname="$1"
user="$2"
repo=""

if [[ -z "$user" ]]; then
  user="paulmillr"
fi
repo="git@github.com:$user/$dirname"

mkdir "$dirname" && \
  cd "$dirname" && \
  git init && \
  touch "README.md" "CHANGELOG.md" ".gitignore" && \
  git add "*" && \
  git commit -m 'Initial commit.' && \
  git remote add origin "$repo" && \
  git push -u origin master
