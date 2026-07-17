# grafana-dynatrace-migration

Backend/CLI toolkit to migrate Grafana dashboards to Dynatrace (Grail/Platform
dashboards) and rebuild an aggregated health-check view on top.

## Why this repo exists
It's a **one-way bridge**: pull these generic scripts onto a locked-down
workstation via the raw URLs below — no login required (public repo).

### Ground rule
Push **nothing environment-specific** here (it's public):
- no exported dashboard JSON with real metric/cluster/host names
- no terminal output, no incident data
Everything is parameterised with env vars (`GRAFANA_URL`, `GRAFANA_TOKEN`,
`DT_ENV`, `DT_METRICS_TOKEN`). Set those locally; they never live in git.

## Pull a single script (no auth, works in a browser or curl)
    curl -sO https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main/scripts/grafana-export.sh
    curl -sO https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main/scripts/metric-audit.sh

## Flow
1. `scripts/grafana-export.sh`  — list dashboards, export one by UID
2. `scripts/metric-audit.sh`    — classify each metric REWRAP vs REMAP
3. translate PromQL -> DQL, assemble a Dynatrace dashboard document
4. `monaco/` — deploy the document as config-as-code

## knowledge base
See [`knowledge/`](knowledge/) — generic commands, skills, and migration memory.
