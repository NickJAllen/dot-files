#!/bin/bash
# Used to show status of VCS in tmux

# Move to the pane's current directory
cd "$1" 2>/dev/null || exit

# 1. Check for Jujutsu (jj)
if jj root >/dev/null 2>&1; then
  # Returns the change ID and branch/description summary
  echo "jj:$(jj log -r @ -n 1 --template 'description.first_line()')"
  exit
fi

# 2. Check for Mercurial (hg)
if hg root >/dev/null 2>&1; then
  echo "hg:$(hg branch)"
  exit
fi

# 3. Check for Git
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "git:$(git branch --show-current)"
  exit
fi
