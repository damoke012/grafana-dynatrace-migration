#!/usr/bin/env bash
# Redact environment-specific identifiers before anything leaves the workstation.
#
# Structure is what matters for a migration -- panel layout, thresholds, the
# shape of an expression. Real hostnames, cluster names and domains are not
# needed to translate PromQL to DQL, so strip them and keep the shape.
#
# Replacements are STABLE within a run: the same input always maps to the same
# placeholder, so joins and groupings stay readable.
#
# Usage: ./sanitize.sh <file> [more files...]
# Writes: <file>.clean  and  redaction.map  (the map NEVER leaves this machine)
set -euo pipefail
[[ $# -ge 1 ]] || { echo "usage: $0 <file> [...]" >&2; exit 1; }

MAP="redaction.map"
: > "$MAP"

# Extra terms specific to your estate, one per line, no header.
# e.g. printf 'acmecorp\ninternal-project\n' > extra-terms.txt
EXTRA="${EXTRA_TERMS:-extra-terms.txt}"

for f in "$@"; do
  [[ -f "$f" ]] || { echo "skip (missing): $f" >&2; continue; }
  out="${f}.clean"
  cp "$f" "$out"

  # --- caller-supplied terms first: most specific wins ---
  if [[ -f "$EXTRA" ]]; then
    n=0
    while IFS= read -r term; do
      [[ -z "$term" || "$term" == \#* ]] && continue
      n=$((n+1))
      esc=$(printf '%s' "$term" | sed 's/[][\.*^$/]/\\&/g')
      grep -qi -- "$term" "$out" && printf 'TERM_%02d\t%s\n' "$n" "$term" >> "$MAP"
      sed -i -E "s/${esc}/TERM_$(printf '%02d' $n)/gI" "$out"
    done < "$EXTRA"
  fi

  # --- credentials: removed outright, never placeholdered ---
  sed -i -E \
    -e 's/(Api-Token|Bearer|token|password|passwd|secret|apikey|api_key)([":= ]+)[A-Za-z0-9._\-]{8,}/\1\2<REDACTED>/gI' \
    -e 's/dt0c01\.[A-Z0-9]{24}\.[A-Za-z0-9]{64}/<REDACTED_DT_TOKEN>/g' \
    -e 's/gh[pousr]_[A-Za-z0-9]{20,}/<REDACTED_GH_TOKEN>/g' \
    -e 's/eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/<REDACTED_JWT>/g' \
    "$out"

  # --- emails, then FQDNs, then bare IPs ---
  sed -i -E 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/<EMAIL>/g' "$out"

  # FQDNs -> HOST_n, stable per distinct host. Public registries kept: they are
  # not sensitive and blanking them destroys useful context.
  grep -oE '\b([a-z0-9]([a-z0-9-]*[a-z0-9])?\.){2,}[a-z]{2,}\b' "$out" 2>/dev/null \
    | grep -vE '(github\.com|githubusercontent\.com|dynatrace\.com|grafana\.com|prometheus\.io|kubernetes\.io|docker\.io|quay\.io|redhat\.com)$' \
    | sort -u | awk '{printf "HOST_%02d\t%s\n", NR, $0}' >> "$MAP" || true

  while IFS=$'\t' read -r ph host; do
    [[ "$ph" == HOST_* ]] || continue
    esc=$(printf '%s' "$host" | sed 's/[][\.*^$/]/\\&/g')
    sed -i -E "s/${esc}/${ph}/g" "$out"
  done < "$MAP"

  sed -i -E 's/\b(10|127)\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b/<IP>/g;
             s/\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b/<IP>/g;
             s/\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b/<IP>/g' "$out"

  echo "wrote $out" >&2
done

cat >&2 <<EOF

$MAP holds the placeholder -> real-value mapping. It stays here.
Do not paste it, commit it, or attach it anywhere.

Review before sharing:   grep -nE 'HOST_|TERM_|<REDACTED' <file>.clean | head -30
Anything still recognisable?  add it to $EXTRA and re-run.
EOF
