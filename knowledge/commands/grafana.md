# Grafana — generic commands

Set locally (do NOT commit):
```bash
export GRAFANA_URL="https://<host>/grafana"   # placeholder
export GRAFANA_TOKEN="<api-token>"
```

## List dashboards (UID + title)
```bash
curl -sH "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/search?type=dash-db" \
  | jq -r '.[] | "\(.uid)\t\(.title)"'
```

## Export one dashboard model by UID
```bash
curl -sH "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/dashboards/uid/<UID>" | jq '.dashboard' > source.grafana.json
```

## Pull just the panels + queries (translation worklist)
```bash
jq -r '.panels[] | "\(.title)\t\(.targets[].expr)"' source.grafana.json
```

## Every distinct metric the dashboard touches
```bash
jq -r '.. | .expr? // empty' source.grafana.json \
  | grep -oE '[a-z_:][a-zA-Z0-9_:]+' | sort -u
```
