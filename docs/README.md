# RepoGhost Docs Index

This folder is the implementation and operations context for RepoGhost.

Use these documents together:

- `system-overview.md`
  - architecture, subsystem responsibilities, runtime split, and workflow data flow
- `source-map-and-ownership.md`
  - folder-by-folder and file-by-file responsibility map for the tracked codebase
- `implementation-history-and-fixes.md`
  - what was built, what broke during implementation, how it was fixed, and what remains open
- `mvp-scope-and-roadmap.md`
  - what the current MVP includes, what it deliberately excludes, and the next planned phases
- `developer-runbook.md`
  - setup, run, rebuild, validation, fresh-machine recovery, and day-to-day commands
- `current-state-and-known-issues.md`
  - what is working now, what is still pending, and what to verify before calling the app stable
- `openai-integration-implementation-notes.md`
  - planned OpenAI/byLLM rollout with deterministic fallback and Stage 2 hybrid behavior

Recommended reading order for a new engineer:

1. `system-overview.md`
2. `source-map-and-ownership.md`
3. `implementation-history-and-fixes.md`
4. `mvp-scope-and-roadmap.md`
5. `developer-runbook.md`
6. `current-state-and-known-issues.md`
7. `openai-integration-implementation-notes.md`

If the goal is to get the app running on a new machine, start with `developer-runbook.md`.
If the goal is to understand why the repo looks the way it does, start with `implementation-history-and-fixes.md`.
If the goal is to decide where code changes belong, start with `source-map-and-ownership.md`.
