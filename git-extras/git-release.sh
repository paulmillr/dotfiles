#!/usr/bin/env sh

# git-release(1)
# Usage:
# git release 1.5.2

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).

hook() {
  local hook=".git/hooks/$1.sh"
  if test -f $hook; then
    echo "... $1"
    . $hook
  fi
}

if test $# -gt 0; then
  echo "... releasing $1"
  git commit -a -m "Release $1." \
    && git tag $1 \
    && git push \
    && git push --tags \
    && test -f 'package.json' && npm publish
  echo "... complete"
else
  echo "tag required" 1>&2 && exit 1
fi
