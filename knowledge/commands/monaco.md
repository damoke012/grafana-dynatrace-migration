# Monaco — deploy dashboards as config-as-code

Platform dashboards deploy as `type: document`, `kind: dashboard`.

Set locally (do NOT commit):
```bash
export DT_CLIENT_ID="<oauth-client-id>"
export DT_CLIENT_SECRET="<oauth-client-secret>"
```

## Validate then deploy
```bash
monaco deploy manifest.yaml --environment <env-name> --dry-run
monaco deploy manifest.yaml --environment <env-name>
```

## Project layout (see ../../monaco/ in this repo)
```
manifest.yaml
projects/<project>/dashboards/
  config.yaml          # id + type.document.kind: dashboard + template
  <dashboard>.json     # the dashboard document
```
