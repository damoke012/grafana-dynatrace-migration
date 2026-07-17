#!/usr/bin/env bash
# List Grafana dashboards, or export one by UID.
# Requires: GRAFANA_URL, GRAFANA_TOKEN
set -euo pipefail
: "${GRAFANA_URL:?set GRAFANA_URL (e.g. https://your-grafana/grafana)}"
: "${GRAFANA_TOKEN:?set GRAFANA_TOKEN}"
H=(-H "Authorization: Bearer ${GRAFANA_TOKEN}")

if [[ "${1:-}" == "" ]]; then
  echo "UID<TAB>TITLE  (pass a UID as arg to export)" >&2
  curl -s "${H[@]}" "${GRAFANA_URL}/api/search?type=dash-db" \
    | jq -r '.[] | "\(.uid)\t\(.title)"'
else
  curl -s "${H[@]}" "${GRAFANA_URL}/api/dashboards/uid/$1" \
    | jq '.dashboard' > "source.grafana.json"
  echo "wrote source.grafana.json" >&2
fi
