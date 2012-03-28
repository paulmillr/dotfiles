#!/bin/sh

CHANGELOG='CHANGELOG.md'
DATE=`date +'%B %d, %Y'`
HEAD="## Project x.y.z ($DATE)"

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
