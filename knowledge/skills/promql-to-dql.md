# Skill: PromQL -> DQL translation patterns

| Intent | PromQL | DQL (Grail) |
|--------|--------|-------------|
| Sum a gauge by cluster | `sum(<m>) by (cluster)` | `timeseries s = sum(<m>), by:{k8s.cluster.name}` |
| Filter label | `<m>{phase="Failed"}` | `timeseries ..., filter:{phase == "Failed"}` |
| Count breaching | `count(<m> > 0)` | `timeseries bad = sum(<m>), filter:{...}` then singleValue tile |
| Rate | `rate(<m>[5m])` | `timeseries r = rate(<m>)` |
| Ratio / % | `sum(a)/sum(b)` | compute two series, divide in the tile expression |

## Health cell (the OK / red-count pattern)
Grafana stat panel with thresholds -> Dynatrace `singleValue` tile:
```json
"visualization": "singleValue",
"visualizationSettings": {
  "thresholds": [
    { "value": 0, "color": "green", "label": "OK" },
    { "value": 1, "color": "red" }
  ]
}
```

Notes:
- Metric key depends on the audit: REWRAP keeps it; REMAP swaps to dt.*.
- Grafana `$cluster` template var -> Dynatrace dashboard `variables` + `by:{}`.
