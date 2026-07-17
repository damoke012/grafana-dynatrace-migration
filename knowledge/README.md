# knowledge/

Structured, **generic-only** knowledge base for this migration effort.

| Folder | Holds | Rule |
|--------|-------|------|
| `commands/` | Parameterised command templates | Copy locally, fill in real values, **never commit the filled-in version** |
| `skills/`   | Step-by-step playbooks / procedures | Reusable, environment-agnostic |
| `memory/`   | Durable facts learned along the way | No hostnames, tokens, metric names, or output |

## Golden rule (this repo is PUBLIC)
Everything here uses placeholders (`$GRAFANA_URL`, `$DT_ENV`, `<UID>`, ...).
Real data — actual dashboard JSON, audit output, terminal results, anything
with internal cluster/metric/host names — **never lands here**. It stays inside
the environment and reaches Claude via **/remotecontrol** or a screenshot.

## Workflow
1. Pull a template from `commands/` (raw URL, no login).
2. Fill in your real env values **locally only**.
3. Run it. If it breaks or needs tweaking, share the result via /remotecontrol.
4. Reusable procedures get written up in `skills/`; durable lessons in `memory/`.
