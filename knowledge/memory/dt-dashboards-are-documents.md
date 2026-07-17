---
name: dt-dashboards-are-documents
description: New Dynatrace (Grail/Platform) dashboards are documents, deployed via Monaco type document/kind dashboard
type: reference
---
The Platform Dashboards app (apps.dynatrace.com/ui/apps/dynatrace.dashboards)
stores dashboards as **documents**, not the classic dashboard API. Deploy via:
- Monaco: `type: { document: { kind: dashboard } }` + a template JSON.
- Documents API: `POST /platform/document/v1/documents` (multipart, type=dashboard).
Auth is **OAuth / platform token**, not a classic API token. See [[public-repo-generic-only]].
