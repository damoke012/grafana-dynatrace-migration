#!/usr/bin/env bash
# Classify every metric used by source.grafana.json as REWRAP (key exists in
# Dynatrace) or REMAP (needs a native dt.* equivalent).
# Requires: DT_ENV (e.g. abc12345), DT_METRICS_TOKEN (Metrics read scope)
set -euo pipefail
: "${DT_ENV:?set DT_ENV (the tenant id, e.g. abc12345)}"
: "${DT_METRICS_TOKEN:?set DT_METRICS_TOKEN}"
SRC="${1:-source.grafana.json}"

jq -r '.. | .expr? // empty' "$SRC" \
  | grep -oE '[a-z_:][a-zA-Z0-9_:]+' \
  | grep -E '_(total|count|bytes|seconds|phase|info|status|ratio)|^kube_|^node_|^container_' \
  | sort -u > metrics.txt

while read -r m; do
  hit=$(curl -s -H "Authorization: Api-Token ${DT_METRICS_TOKEN}" \
    "https://${DT_ENV}.live.dynatrace.com/api/v2/metrics?text=${m}&pageSize=5&fields=+displayName" \
    | jq -r '.metrics[].metricId' | head -1)
  if [[ -n "$hit" ]]; then echo -e "REWRAP\t$m\t-> $hit"
  else echo -e "REMAP \t$m\t(no native key, needs dt.* equivalent)"; fi
done < metrics.txt | sort
