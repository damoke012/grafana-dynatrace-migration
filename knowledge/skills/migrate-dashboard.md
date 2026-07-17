# Skill: migrate one Grafana dashboard to Dynatrace

Do this on a SMALL dashboard (5-15 panels) first to prove the chain.

1. **Export** — `commands/grafana.md` -> `source.grafana.json`.
2. **Audit metrics** — run the REWRAP/REMAP classifier (`commands/dynatrace.md`).
   - REWRAP: metric exists -> keep key, restate as DQL.
   - REMAP: no native key -> map to a dt.* equivalent (record it in memory/).
3. **Translate** each panel:
   - PromQL target      -> DQL `timeseries`   (see promql-to-dql.md)
   - stat/threshold      -> tile `visualization` + `visualizationSettings.thresholds`
   - panel title/layout  -> tile `title` + `layouts` entry
4. **Assemble** a Dynatrace dashboard document (tiles{} map + layouts).
5. **Deploy** via Monaco (`commands/monaco.md`).
6. **Verify** it renders in Dynatrace; compare cell-by-cell with the Grafana source.
7. Only then point the same machine at the big all-cluster grid.

> Share breakages / "help me modify" via /remotecontrol — keep real JSON out of git.
