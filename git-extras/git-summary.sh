#!/usr/bin/env sh

git log --pretty=format:"%ae" | sort | uniq -c | sort -r
