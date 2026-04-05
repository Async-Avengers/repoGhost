# RepoGhost Current State and Known Issues

## Current State

The repo currently has a deterministic MVP that:

- type-checks with `jac check main.jac`
- exposes a Vite-driven UI
- exposes Jac API docs on `:8001/docs`
- runs a staged workflow from repo path and meeting text
- renders graph, files, blockers, planning, tickets, standup, handoff, review, and trace outputs

The current workflow is designed as the baseline for future OpenAI/byLLM integration.

## What Is Working

### Server/workflow

- deterministic repo scan
- deterministic search ranking
- deterministic docs sync
- deterministic meeting parsing
- deterministic memory updates
- deterministic Stage 2 reasoning
- deterministic Stage 3 artifact generation
- graph build and workflow bundle assembly

### Client

- app shell renders
- widget and workspace both render
- input fields are editable
- prompt submission updates the chat thread
- workflow error state renders
- graph/planning/output summary cards render

### Build/runtime support

- tracked typing shim exists outside `.jac/`
- repo has Python-side requirements file
- README contains fresh-machine setup steps

## Known Issues

### 1. Cross-machine Vite HMR WebSocket reliability

Status:

- open

Observed behavior:

- another machine can serve `localhost:8000` over HTTP
- Vite HMR WebSocket may fail to connect

Likely cause:

- dev config and HMR host assumptions still need normalization

Impact:

- can make a healthy app appear broken on a different environment

Planned fix:

- part of the OpenAI/byLLM rollout preparation
- see `docs/openai-integration-implementation-notes.md`

### 2. OpenAI integration not yet implemented

Status:

- open

Current behavior:

- deterministic only

Planned behavior:

- Jac `by llm()` integration
- deterministic fallback
- Stage 2 hybrid

### 3. Repo-wide validation script not yet added

Status:

- open

Current behavior:

- validation relies mainly on `jac check main.jac`

Planned behavior:

- a repeatable all-Jac-files validation sweep aligned with the VSCode Problems expectation

## Resolved Stability Issues

These are no longer considered active blockers:

- Jac `Unknown`/type inference failures across workflow, wrappers, services, and client state
- client-side module export/import crashes
- missing tracked typing shim on fresh machines
- frozen/static input behavior
- callback generation errors in compiled client code
- AppShell warning noise from reactive state assignments

For detail on those fixes:

- see `docs/implementation-history-and-fixes.md`

## Before Calling the App Stable on a New Machine

Confirm all of these:

- `jac check main.jac` passes
- UI opens on `:8000`
- API docs open on `:8001/docs`
- repo path, meeting text, and prompt are editable
- one full workflow run completes
- no generated-module browser crash appears
- trace, tickets, handoff, and review sections populate
