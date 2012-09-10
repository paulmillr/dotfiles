#!/usr/bin/env sh

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).

git commit -a -m "$1" && git push -u origin
