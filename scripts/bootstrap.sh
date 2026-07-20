#!/usr/bin/env bash
# Pull the whole toolkit onto a locked-down workstation in one command.
# Public repo -> raw URLs need no auth.
#
#   curl -sL https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main/scripts/bootstrap.sh | bash
#
# Writes ./gdm-toolkit/ and does nothing else. No env vars needed to fetch.
set -euo pipefail

BASE="https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main"
DEST="${1:-gdm-toolkit}"
mkdir -p "$DEST"

for s in grafana-export.sh dashboard-inventory.sh metric-audit.sh sanitize.sh; do
  curl -fsSL "$BASE/scripts/$s" -o "$DEST/$s" && chmod +x "$DEST/$s"
  echo "  $DEST/$s"
done

# Output belongs to the workstation, never to git.
cat > "$DEST/.gitignore" <<'EOF'
*
EOF

cat >&2 <<'EOF'

Fetched. Next:

  export GRAFANA_URL='https://<your-grafana>/grafana'
  export GRAFANA_TOKEN='...'
  cd gdm-toolkit

  ./grafana-export.sh                    # list dashboards -> pick a UID
  ./grafana-export.sh <UID>              # -> source.grafana.json
  ./dashboard-inventory.sh               # -> inventory.tsv + panels.json
  ./metric-audit.sh                      # needs DT_ENV + DT_METRICS_TOKEN

Before sharing ANYTHING back:

  ./sanitize.sh inventory.tsv            # -> inventory.tsv.clean + redaction.map (map stays local)

EOF
