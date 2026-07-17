#!/usr/bin/env bash
# Start a new branch-based unit of work.
set -euo pipefail
[ -n "${1:-}" ] || { echo "usage: new-work.sh <short-topic>"; exit 1; }
git checkout main
git pull --ff-only
git checkout -b "work/$1"
echo "On branch work/$1. When done:"
echo "  git add -A && git commit -m '...' && git push -u origin HEAD"
echo "  gh pr create --fill && gh pr merge --squash --delete-branch"
