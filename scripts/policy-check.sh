#!/usr/bin/env bash
# Fail if anything environment-specific has crept into this PUBLIC repo.
# Run before every push. Exit 1 = do not push.
#
#   scripts/policy-check.sh
#
# Add your own org/product/estate terms to .policy-terms (gitignored, local only)
# so this catches them without naming them in a public file.
set -uo pipefail
cd "$(dirname "$0")/.."
FAIL=0

hit() { printf '\n[!] %s\n' "$1"; shift; printf '%s\n' "$@"; FAIL=1; }

# Public/vendor domains that are fine to reference.
ALLOW='raw\.githubusercontent\.com|github\.com|githubusercontent|live\.dynatrace\.com|apps\.dynatrace\.com|sso\.dynatrace\.com|grafana\.com|prometheus\.io|kubernetes\.io'

out=$(grep -rInE '\b([a-z0-9-]+\.){2,}[a-z]{2,}\b' --exclude-dir=.git --exclude=.policy-terms . 2>/dev/null \
      | grep -vE "$ALLOW" \
      | grep -vE '\.(json|yaml|yml|sh|md|tsv|txt)\b' || true)
[[ -n "$out" ]] && hit "possible internal hostname/FQDN" "$out"

out=$(grep -rInE '\b(([0-9]{1,3}\.){3}[0-9]{1,3})\b' --exclude-dir=.git . 2>/dev/null || true)
[[ -n "$out" ]] && hit "IP address" "$out"

out=$(grep -rInE '(dt0c01\.[A-Z0-9]{24}|gh[pousr]_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.)' --exclude-dir=.git . 2>/dev/null || true)
[[ -n "$out" ]] && hit "credential-shaped string" "$out"

# Real exported artefacts must never be committed.
out=$(git ls-files | grep -E '(source\.grafana\.json|inventory\.tsv|panels\.json|metrics\.txt|redaction\.map|extra-terms\.txt)$' || true)
[[ -n "$out" ]] && hit "exported artefact tracked by git" "$out"

# Local term list: one per line. Never committed.
if [[ -f .policy-terms ]]; then
  while IFS= read -r t; do
    [[ -z "$t" || "$t" == \#* ]] && continue
    out=$(grep -rIniE -- "$t" --exclude-dir=.git --exclude=.policy-terms . 2>/dev/null || true)
    [[ -n "$out" ]] && hit "local policy term matched (term not shown)" "$(printf '%s\n' "$out" | cut -d: -f1,2)"
  done < .policy-terms
fi

if [[ $FAIL -eq 0 ]]; then
  printf 'policy-check: clean\n'
else
  printf '\npolicy-check: FAILED — do not push until resolved\n'
fi
exit $FAIL
