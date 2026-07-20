#!/usr/bin/env bash
# Reduce an exported Grafana dashboard to the structure you actually need to
# rebuild it in Dynatrace: one row per panel target, plus thresholds and layout.
#
# Metric names alone are not enough -- a health grid is defined by its panel
# layout, its threshold colours, and the aggregation in each expression.
#
# Usage: ./dashboard-inventory.sh [source.grafana.json]
# Writes: inventory.tsv (human/diffable), panels.json (machine-readable)
set -euo pipefail
SRC="${1:-source.grafana.json}"
[[ -f "$SRC" ]] || { echo "no $SRC -- run grafana-export.sh <UID> first" >&2; exit 1; }

# Flatten rows so nested panels are counted too.
jq '[ .panels[]? | if .type == "row" then (.panels[]? // empty) else . end ]' "$SRC" > .panels.flat.json

jq '[ .[] | {
      id, title, type,
      datasource: (.datasource.type // .datasource // null),
      grid: (.gridPos // {}),
      unit: (.fieldConfig.defaults.unit // null),
      thresholds: [ .fieldConfig.defaults.thresholds.steps[]? | {color, value} ],
      mappings:  [ .fieldConfig.defaults.mappings[]? ],
      targets:   [ .targets[]? | {refId, expr: (.expr // .query // null), legend: (.legendFormat // null), instant: (.instant // false)} ]
    } ]' .panels.flat.json > panels.json

{
  printf 'PANEL_ID\tTYPE\tTITLE\tREF\tEXPR\tTHRESHOLDS\n'
  jq -r '.[] as $p
         | ($p.thresholds | map("\(.color):\(.value // "base")") | join(",")) as $th
         | if ($p.targets | length) == 0
           then [$p.id, $p.type, $p.title, "-", "-", $th] | @tsv
           else $p.targets[] | [$p.id, $p.type, $p.title, .refId, (.expr // "-"), $th] | @tsv
           end' panels.json
} > inventory.tsv

rm -f .panels.flat.json

# Metric extraction. Strip the parts of an expression that contain identifiers
# which are NOT metrics -- label matchers inside {...} and the label list in
# by()/without() -- before pulling names out. Otherwise label names like
# "cluster" get reported as metrics.
jq -r '.[].targets[]?.expr // empty' panels.json \
  | sed -E 's/\{[^}]*\}//g; s/\[[^]]*\]//g' \
  | sed -E 's/\b(by|without|on|ignoring|group_left|group_right)\s*\([^)]*\)//g' \
  | grep -oE '[a-zA-Z_:][a-zA-Z0-9_:]*' \
  | grep -vE '^(sum|avg|min|max|count|count_values|rate|irate|increase|and|or|unless|topk|bottomk|absent|absent_over_time|clamp|clamp_max|clamp_min|round|ceil|floor|abs|exp|ln|log2|log10|sqrt|delta|idelta|deriv|predict_linear|holt_winters|histogram_quantile|label_replace|label_join|time|timestamp|vector|scalar|sort|sort_desc|offset|le|quantile|stddev|stdvar|changes|resets|last_over_time|avg_over_time|max_over_time|min_over_time|sum_over_time|count_over_time|stddev_over_time|quantile_over_time|Inf|NaN)$' \
  | grep -vE '^[0-9]+$' \
  | sort -u > metrics.txt

printf '\npanels: %s   targets: %s   metrics: %s\n' \
  "$(jq 'length' panels.json)" \
  "$(( $(wc -l < inventory.tsv) - 1 ))" \
  "$(wc -l < metrics.txt)" >&2
printf 'wrote inventory.tsv, panels.json, metrics.txt\n' >&2
