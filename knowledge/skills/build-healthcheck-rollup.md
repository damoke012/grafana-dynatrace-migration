# Skill: build the aggregated health-check view

Goal: reproduce the single-pane "every cluster x every signal = OK/red" grid
that aggregates the migrated dashboards.

## Two ways to build it
1. **1:1 port (fidelity first).** One `singleValue` tile per cluster x signal,
   each with the OK/red threshold rules. Faithful, but many tiles.
2. **Native rollup (recommended once trusted).** ONE DQL query produces a table
   of cluster x signal x status, rendered as a **honeycomb** tile — every cell
   from a single statement.

## Rollup sketch (honeycomb)
```
timeseries bad = sum(<signal-metric>), by:{k8s.cluster.name}, filter:{ <breach> }
| fieldsAdd status = if(bad[] > 0, "CRIT", else:"OK")
```
Then tile `visualization: "honeycomb"`, color by `status`.

## Order of operations
- Migrate + verify the SOURCE dashboards first.
- Build the rollup only on signals you've already confirmed render correctly.
- A rollup fed by an unverified source just hides bad data behind a green cell.
