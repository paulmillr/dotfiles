#!/bin/sh

git filter-branch -f --env-filter '

newn=""
newm=""
oldm=""

if [ "$GIT_COMMITTER_EMAIL" = "$oldm" ]
then
    cn="$newn"
    cm="$newm"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$oldm" ]
then
    an="$newn"
    am="$newm"
fi

export GIT_AUTHOR_NAME="$newn"
export GIT_AUTHOR_EMAIL="$newm"
export GIT_COMMITTER_NAME="$newn"
export GIT_COMMITTER_EMAIL="$newm"
'
