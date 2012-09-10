#!/usr/bin/env sh

# Originally taked from
# [visionmedia/git-extras](https://github.com/visionmedia/git-extras)
# (MIT License).

git log --pretty=format:"%ae" | sort | uniq -c | sort -r
