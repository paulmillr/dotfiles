#!/usr/bin/env sh

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).

branch=$1
test -z $branch && echo "branch required." 1>&2 && exit 1
git branch -D $branch
git branch -d -r origin/$branch && git push origin :$branch
