#!/bin/sh

# Git pretty formats cannot conditionally render fields. Bring paged git-log
# output in line with gl: show a check for U, omit the current year, and hide
# the mailmapped author name ME while retaining other authors.
reset=$(printf '\033[m')
gray=$(printf '\033[90m')
green=$(printf '\033[32m')
blue=$(printf '\033[34m')
current_year=$(date +%y)

awk \
  -v reset="$reset" \
  -v gray="$gray" \
  -v green="$green" \
  -v blue="$blue" \
  -v current_year="$current_year" '
  {
    signature_marker = reset " " green
    signature_marker_at = index($0, signature_marker)
    if (index($0, gray) == 1 && signature_marker_at) {
      status_at = signature_marker_at + length(signature_marker)
      if (substr($0, status_at, 1) == "U") {
        $0 = substr($0, 1, status_at - 1) "✓" substr($0, status_at + 1)
      } else {
        $0 = substr($0, 1, signature_marker_at + length(reset)) \
          substr($0, status_at + length(reset) + 2)
      }
    }

    date_at = index($0, blue "(")
    if (date_at) {
      year_suffix = "/" current_year ")" reset
      year_at = index(substr($0, date_at), year_suffix)
      if (year_at) {
        year_at += date_at - 1
        $0 = substr($0, 1, year_at - 1) substr($0, year_at + 3)
      }
    }

    mine = " " gray "ME" reset
    mine_at = index($0, mine)
    if (mine_at) {
      $0 = substr($0, 1, mine_at - 1) substr($0, mine_at + length(mine))
    }

    print
  }
'
