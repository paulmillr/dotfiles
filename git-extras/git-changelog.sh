#!/usr/bin/env sh

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).

CHANGELOG='CHANGELOG.md'
DATE=`date +'%B %d, %Y'`
PROJECT=`cat $CHANGELOG | egrep '^# (\w+)' | sed -e 's/^# \([a-zA-Z]*\).*/\1/' | head -n 1`
HEAD="# $PROJECT $1 ($DATE)"

if test "$1" = "--list"; then
  version=`git for-each-ref refs/tags --sort="-*authordate" --format='%(refname)' \
    --count=1 | sed 's/^refs\/tags\///'`
  if test -z "$version"; then
    git log --pretty="format:* %s"
  else
    git log --pretty="format:* %s" $version..
  fi
else
  tmp="/tmp/changelog"
  echo $HEAD > $tmp
  sh $0 --list >> $tmp
  echo '\n' >> $tmp
  if [ -f $CHANGELOG ]; then cat $CHANGELOG >> $tmp; fi
  mv $tmp $CHANGELOG
  test -n "$EDITOR" && $EDITOR $CHANGELOG
fi
