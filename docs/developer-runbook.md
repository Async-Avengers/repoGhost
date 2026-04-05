# RepoGhost Developer Runbook

## Purpose

This is the operational guide for running, rebuilding, validating, and recovering the current RepoGhost MVP.

## Prerequisites

Required tools:

- Python
- Jac CLI
- Bun

Python dependencies:

- install from `requirements.txt`

Frontend/build dependency:

- Bun is required for the Jac client/Vite pipeline

## Standard Setup

From repo root:

```bash
python -m pip install -r requirements.txt
jac install
jac check main.jac
jac start --dev main.jac
```

## Local URLs

- UI: `http://127.0.0.1:8000`
- API docs: `http://127.0.0.1:8001/docs`

Important:

- `jac start --dev main.jac` is a long-running dev server
- it is expected to stay attached to the terminal until stopped
- run it in a dedicated shell

## Validation Workflow

Current baseline validation:

```bash
jac check main.jac
```

Recommended local validation before committing:

1. run `jac check main.jac`
2. start the app with `jac start --dev main.jac`
3. open the UI on `:8000`
4. confirm `/docs` still works on `:8001/docs`
5. run one realistic workflow scenario

## Smoke-Test Scenario

Use:

- a real local repo path
- meeting notes or transcript text
- a realistic prompt such as:
  - `Turn this meeting into tickets`
  - `What files are probably involved?`
  - `Prepare a handoff`

Verify:

- inputs are editable
- workflow runs
- chat thread updates
- files, blockers, planning, tickets, handoff, review, and trace render

## Fresh-Machine Recovery

If a clean checkout behaves strangely:

```bash
python -m pip install -r requirements.txt
jac install
jac check main.jac
jac start --dev main.jac
```

If stale generated client output appears to be the issue:

- stop the dev server
- remove `.jac/`
- rerun setup

Safe reset flow:

```powershell
Remove-Item -Recurse -Force .jac
python -m pip install -r requirements.txt
jac install
jac check main.jac
jac start --dev main.jac
```

## Environment Notes

- `.env.local` is ignored by git
- `OPENAI_API_KEY` has been discussed for future integration
- current deterministic MVP does not yet use OpenAI/byLLM at runtime

Future integration notes:

- see `docs/openai-integration-implementation-notes.md`

## Build Notes

Important tracked build helpers:

- `vite.repoghost.resolve.mjs`
- `typing.repoghost.js`

These exist because repo-critical client behavior must not depend on generated files under `.jac/`.

## Current Troubleshooting Checklist

### UI does not load but `/docs` works

Check:

- open `:8000` for the UI
- open `:8001/docs` for API docs

### Fresh machine shows generated-module import errors

Check:

- Bun is installed
- `jac install` completed
- `.jac/` is not stale

### Inputs appear frozen

The current source already contains the fixes for this. If it happens again:

- rebuild generated client output with a clean `.jac/`
- verify `AppShell`, `WidgetShell`, and `WorkspaceShell` compiled output matches source fixes

### Dev server appears “stuck”

That is normal for:

```bash
jac start --dev main.jac
```

It is a server, not a one-shot command.
