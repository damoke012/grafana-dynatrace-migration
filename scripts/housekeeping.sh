#!/usr/bin/env bash
# Prune merged branches and flag stale notes. Safe: only deletes MERGED branches;
# notes are flagged, never auto-deleted.
set -euo pipefail
STALE_DAYS="${STALE_DAYS:-30}"
git fetch --prune origin

echo "== local branches merged into main (deleting) =="
git branch --merged main | grep -vE '^\*| main$' | while read -r b; do
  git branch -d "$b" && echo "  deleted $b"
done

echo "== remote branches merged into origin/main (delete stragglers manually) =="
git branch -r --merged origin/main | grep -vE 'origin/main$|origin/HEAD' | sed 's#origin/#  #' || true
echo "  (delete one with: git push origin --delete <branch>)"

echo "== stale notes (>${STALE_DAYS}d since last change) =="
now=$(date +%s)
git ls-files 'knowledge/memory/*.md' | while read -r f; do
  [ "$(basename "$f")" = "MEMORY.md" ] && continue
  [ "$(basename "$f")" = "README.md" ] && continue
  last=$(git log -1 --format=%ct -- "$f")
  age=$(( (now - last) / 86400 ))
  [ "$age" -gt "$STALE_DAYS" ] && echo "  $f  (${age}d) -> review / delete"
done
echo "done."
