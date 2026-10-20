---
paths:
  - ".claude-plugin/sc-workflow/**"
---

# Bump the plugin version

Installed copies only update when `version` in `.claude-plugin/sc-workflow/.claude-plugin/plugin.json` changes, so every change to the plugin needs a bump. Bump once per batch of unpushed changes, at the highest level any of them needs. If the version has already changed since `origin/main`, raise it only when a later change needs a higher level.

- **Major**: breaks how people use it. A skill, agent or command is removed or renamed, or its arguments or the shape of its output change in a way that breaks existing usage.
- **Minor**: adds something without breaking anything. A new skill, agent or command, or a new optional argument or behavior.
- **Patch**: everything else. Wording, clarifications, and tightening or fixing how an existing skill or agent behaves.
