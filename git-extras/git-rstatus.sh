#!/usr/bin/env sh

autoload colors && colors

ls -1 | while read line; do
  cd $line
  line_count=$(git status --porcelain 2> /dev/null | wc -l)
  if [[ "$line_count" -ne "0" ]]; then
    echo "${fg[blue]}$line$reset_color:"
    git status --short
    echo ""
  fi
  cd ..
done
