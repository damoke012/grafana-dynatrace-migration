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

## Pull the toolkit (no auth — public raw URLs)
    curl -sL https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main/scripts/bootstrap.sh | bash

Or one script at a time:

    curl -sO https://raw.githubusercontent.com/damoke012/grafana-dynatrace-migration/main/scripts/grafana-export.sh

## Flow
1. `scripts/grafana-export.sh`      — list dashboards, export one by UID
2. `scripts/dashboard-inventory.sh` — panels, targets, thresholds, metric list
3. `scripts/metric-audit.sh`        — classify each metric REWRAP vs REMAP
4. translate PromQL -> DQL, assemble a Dynatrace dashboard document
5. `monaco/` — deploy the document as config-as-code

## Before sharing anything back
    scripts/sanitize.sh inventory.tsv

Redacts hostnames, domains, emails, IPs and any terms you list in
`extra-terms.txt`; strips credentials outright. Writes `<file>.clean` plus
`redaction.map` — **the map stays on the workstation.**

## knowledge base
See [`knowledge/`](knowledge/) — generic commands, skills, and migration memory.

## workflow
Branch-based — see [`WORKFLOW.md`](WORKFLOW.md). Housekeeping: `scripts/housekeeping.sh`.
