# Dynatrace — generic commands

Set locally (do NOT commit):
```bash
export DT_ENV="<tenant>"              # e.g. abc12345
export DT_METRICS_TOKEN="<token>"     # Metrics read scope
```

## Does a metric key already exist? (REWRAP vs REMAP)
```bash
curl -sH "Authorization: Api-Token $DT_METRICS_TOKEN" \
  "https://$DT_ENV.live.dynatrace.com/api/v2/metrics?text=<metric>&pageSize=5&fields=+displayName" \
  | jq -r '.metrics[].metricId'
```
Returns a key -> REWRAP (keep the metric, restate as DQL).
Empty       -> REMAP  (find the native dt.* equivalent).

## DQL timeseries shape (Grail dashboards)
```
timeseries bad = sum(<metric>), filter:{ <label> == "<value>" }, by:{ k8s.cluster.name }
```

## Deploy a dashboard document via the Documents API (one-off)
```bash
curl -X POST "https://$DT_ENV.apps.dynatrace.com/platform/document/v1/documents" \
  -H "Authorization: Bearer $DT_PLATFORM_TOKEN" \
  -F "name=Platform Cluster Health" \
  -F "type=dashboard" \
  -F "content=@cluster-health.json;type=application/json"
```
> For repeatable deploys, prefer Monaco (see monaco.md) over this.
