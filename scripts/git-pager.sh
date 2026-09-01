#!/bin/sh
# Pager for git: delta when available, plain less otherwise.
if command -v delta >/dev/null 2>&1; then
  exec delta "$@"
elif [ "$1" = "--color-only" ]; then
  # diffFilter mode: input is already colored, pass through
  exec cat
else
  # git sets LESS=FRX itself when invoking the pager
  exec less
fi
