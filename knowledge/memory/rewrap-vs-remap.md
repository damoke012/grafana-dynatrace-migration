---
name: rewrap-vs-remap
description: Before translating a panel, classify each metric REWRAP (key exists in Dynatrace) vs REMAP (needs a native dt.* equivalent)
type: reference
---
Metrics reach Dynatrace by two paths, often mixed:
- **REWRAP** — the Prometheus key was ingested into Grail as-is; keep the key,
  just restate the query in DQL.
- **REMAP** — no native key; find the equivalent `dt.*` metric.
Classify mechanically via the Metrics API (`?text=<metric>`): a hit = REWRAP,
empty = REMAP. Do this BEFORE translating so you know which panels are trivial.
