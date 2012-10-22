#!/usr/bin/env zsh

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).
autoload -U colors && colors

total=0  # Total number of commits.
output=''

git log --no-merges --pretty=format:"%ae" |\
  sort |\
  uniq -c |\
  sort -r |\
  while read line; do
    count_email=("${(s/ /)line}")
    login_domain=("${(s/@/)count_email[2]}")
    count="$count_email[1]"
    login="$login_domain[1]"
    domain="$login_domain[2]"
    total=$(($count + $total))
    output="$output\n$fg[red]$count $fg[blue]$login$reset_color@$domain"
  done

echo "$fg[red]$total$reset_color commits totally:"
echo $output
