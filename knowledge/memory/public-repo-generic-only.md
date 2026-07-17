---
name: public-repo-generic-only
description: This repo is a one-way (Claude->desktop) bridge for generic, parameterised content only; real data never lands here
type: reference
---
Built to move tooling onto a locked-down workstation where Codespace, Google,
Teams-mobile, and email are blocked/tracked. Public repo raw URLs need no login,
so the desktop can `curl` them. **Direction is one-way.** Real dashboard JSON,
audit output, terminal results, and any internal cluster/metric/host names never
get committed — they reach Claude via /remotecontrol or a screenshot.
