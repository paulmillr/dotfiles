#!/usr/bin/env sh

# ghpull(1)
# =========

# Script for automizing creating of pull requests from command line.
# You will need to set GITHUB_USERNAME and GITHUB_PASSWORD
# environment variables. Steps the script does:
#
# 1. Fork repo.
# 2. Clone forked git repo to <current-dir>/<repo>.
# 3. Create 'upstream' local branch from original repo.
# 4. Create new topic branch from upstream with prefix 'topics/', publish it to remote.
# 5. Echo URL where you can send pull request after commits.
#
# Usage:
#
#     git ghpull <original-user>/<original-repo> <topic-branch-name>
#     git ghpull paulmillr/ostio add-ie11-support
#
# Workflow:
#
#     git ghpull paulmillr/ostio add-ie11-support && $EDITOR .
#     # edit stuff
#     git commit -m 'Add stuff.' && git push -u origin
#
# (c) 2012 Paul Miller (paulmillr.com).
# The script can be redistributed under the MIT License.

syntax="git ghpull <original-user>/<original-repo> <topic-branch-name>"
err="Invalid syntax. Expected '$syntax'"
enverr='You need to specify $GITHUB_USERNAME and $GITHUB_PASSWORD env vars'

full_upstream_repo=$1  # Full repo name in format <user>/<repo>.
branch="topics/$2"  # Topic branch name.

[[ -z $GITHUB_PASSWORD ]] && echo "Enter GitHub password:" && \
  read -s GITHUB_PASSWORD

user=$GITHUB_USERNAME
password=$GITHUB_PASSWORD

[[ -z "$1" ]] && echo $err && exit 1
[[ -z "$2"  ]] && echo $err && exit 1
[[ -z "$user" ]] && echo $enverr && exit 1
[[ -z "$password" ]] && echo $enverr && exit 1

set `echo $full_upstream_repo | tr '/' ' '`
owner=$1  # Owner of original repo.
repo=$2  # Repository name (identical in forked and original variants).

api='https://api.github.com'
url="https://github.com/$user/$repo/pull/new/$owner:master...$user:$branch"

fork() {
  echo "Forking repository..."
  curl -s "$api/repos/$owner/$repo/forks" --user "$user:$password" -X POST > /dev/null
  sleep 6  # Sleep six seconds, because forking is async. TODO: remove this workaround.
}

clone() {
  echo "Cloning repository..."
  git clone -q "git@github.com:$user/$repo.git" "$repo"
}

create_upstream_branch() {
  echo "Fetching 'upstream' branch..."
  git remote add upstream "git://github.com/$owner/$repo.git"
  git checkout -q -b upstream
  git pull -q upstream master
}

create_new_topic_branch() {
  echo "Switching to branch '$branch'..."
  git checkout -b "$branch" upstream -q
  git push origin "$branch" -q
}

echo_url() {
  echo 'Edit the item, open URL in order to submit pull request:'
  echo "cd $repo && edit . && open '$url'"
}

fork && clone && cd $repo \
  && create_upstream_branch \
  && create_new_topic_branch \
  && echo_url
