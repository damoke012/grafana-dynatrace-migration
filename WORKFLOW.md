# Working in this repo

**Everything is branch-based. Nothing is committed straight to `main`.**

## One task = one branch
```bash
scripts/new-work.sh <short-topic>      # e.g. new-work.sh export-audit
# ...edit, then...
git add -A && git commit -m "..."
git push -u origin HEAD
gh pr create --fill
gh pr merge --squash --delete-branch   # branch auto-deletes on merge
```
- Branch names: `work/<short-topic>`.
- Merge with `--squash` so `main` stays one-commit-per-task.
- The branch is deleted automatically (repo setting + `--delete-branch`).

## Housekeeping — run frequently (start & end of a session)
```bash
scripts/housekeeping.sh
```
It will:
- `fetch --prune` and delete local branches already merged into `main`
- list merged **remote** branches so you can delete stragglers
- flag **stale notes** in `knowledge/memory/` (default >30 days) for review/deletion

## Notes hygiene
Memory notes are point-in-time. When one is obsolete or superseded, **delete it**
and drop its line from `knowledge/memory/MEMORY.md`. Housekeeping only *flags*
stale notes — deletion is a human call, never automatic.
