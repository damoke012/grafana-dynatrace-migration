---
name: promql-count-to-dql-singlevalue
description: A Grafana count()>0 health cell maps to a DQL timeseries + singleValue tile with 0=green/>=1=red thresholds
type: reference
---
The recurring health-grid cell (green "OK" / red count) is, in Grafana, a stat
panel over `count(<m> > 0)`. In Dynatrace it becomes a `singleValue` tile whose
query sums the breaching series and whose `visualizationSettings.thresholds` map
`0 -> green "OK"` and `1 -> red`. This one shape repeats per signal. See [[rewrap-vs-remap]].
