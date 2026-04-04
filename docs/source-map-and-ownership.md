# RepoGhost Source Map and Ownership Guide

## Purpose

This document is the codebase map for RepoGhost.

Use it when answering:

- where a behavior lives
- which file is the right place for a change
- which layer owns a specific responsibility
- which files are generated versus tracked

This is not a strict team-ownership file. It is a responsibility map for the current MVP.

## Repo Root

Primary tracked root files:

- `main.jac`
  - app entrypoint
  - exposes the client app
- `jac.toml`
  - Jac project, serve, build, and client configuration
- `requirements.txt`
  - Python-side dependency bootstrap
- `README.md`
  - top-level setup and usage guide
- `vite.repoghost.resolve.mjs`
  - custom Vite resolver support for Jac-generated client output
- `typing.repoghost.js`
  - tracked shim used by the generated client pipeline
- `.gitignore`
  - excludes generated and local-only state such as `.jac/` and `.env.local`

Generated local state:

- `.jac/`
  - generated Jac environment, compiled client output, local virtual environment, and related artifacts
  - should be treated as rebuildable, not source of truth

## Application Package Layout

Top-level app folders:

- `app/components`
- `app/hooks`
- `app/orchestration`
- `app/services`
- `app/agents`
- `app/models`
- `app/graph`
- `app/memory`
- `app/lib`

### `app/components`

Client rendering layer.

- `Layout.cl.jac`
  - loads global styling
  - mounts the main app shell
- `AppShell.cl.jac`
  - top-level client state owner
  - handles prompt flow, run state, chat thread, and workflow invocation
- `WidgetShell.cl.jac`
  - compact sidecar UI
  - summary-oriented view
- `WorkspaceShell.cl.jac`
  - expanded workspace view
  - trace, files, planning, tickets, review, handoff, and other detailed output surfaces
- `EmptyState.cl.jac`
  - pre-run UI state
- `ErrorBanner.cl.jac`
  - visible workflow error rendering

If the problem is:

- input editability
- prompt submission
- workspace rendering
- widget/workspace layout split

start in `app/components`.

### `app/hooks`

Client-to-server workflow access layer.

- `useRepoGhost.cl.jac`
  - client hook used to call the server workflow and surface bundle/state to the UI

If a change is about:

- client workflow fetch behavior
- workflow run state
- client/server call boundary

start here, then inspect `AppShell`.

### `app/orchestration`

Workflow coordination and UI-friendly trace assembly.

- `workflow.sv.jac`
  - main deterministic orchestration entrypoint
  - merges all stage outputs into the final bundle consumed by the UI
- `trace.sv.jac`
  - trace helpers and step/status shaping for UI display

If a change affects:

- end-to-end workflow behavior
- ordering of agent/service calls
- final bundle assembly
- trace output

start in `app/orchestration`.

### `app/services`

Deterministic extraction and utility layer.

- `repo_ingest.sv.jac`
  - scans repository structure and summarizes files
- `search_index.sv.jac`
  - search-oriented file matching and ranking support
- `docs_sync.sv.jac`
  - documentation file discovery and decision extraction
- `meeting_parse.sv.jac`
  - deterministic meeting-note parsing
- `memory_store.sv.jac`
  - deterministic persistence/update helpers
- `demo_data.sv.jac`
  - demo/default workflow data support

These files should remain the ground-truth deterministic layer even after LLM integration.

### `app/agents`

Thin workflow-facing reasoning and output generators.

Stage 1 wrappers:

- `repo_mapper.sv.jac`
- `meeting_interpreter.sv.jac`
- `code_search.sv.jac`
- `docs_sync.sv.jac`
- `decision_memory.sv.jac`

Stage 2 reasoning:

- `context_resolver.sv.jac`
- `blocker_detector.sv.jac`
- `dependency_impact.sv.jac`
- `test_gap.sv.jac`

Stage 3 outputs:

- `action_planner.sv.jac`
- `ticket_writer.sv.jac`
- `standup_agent.sv.jac`
- `handoff_agent.sv.jac`
- `review_prep.sv.jac`

This is the most likely future insertion point for `by llm()` behavior.

### `app/models`

Typed contracts shared across workflow layers.

- `core.jac`
  - foundational typed entities such as file matches, decisions, blockers, tasks, and related core data
- `outputs.jac`
  - output-facing graph and render data types
- `workflow.jac`
  - workflow request/response and bundle-level types

If a change affects:

- cross-layer data shape
- type stability
- UI/server contract

start in `app/models`.

### `app/graph`

Project graph structures and graph construction.

- `nodes.jac`
  - graph node archetypes
- `edges.jac`
  - graph edge archetypes
- `builder.jac`
  - converts workflow data into a UI-facing project context graph

If a change affects the graph visualization or relationships shown in the UI, start here.

### `app/memory`

Deterministic project/session memory.

- `project_memory.jac`
  - project-scoped memory representation
- `session.jac`
  - session/run-level memory representation

### `app/lib`

Small shared helpers used by the client or app state.

- `ui_state.cl.jac`
  - client UI state shaping helpers

## Data Flow Reference

Current high-level path:

1. `main.jac`
2. `app/components/Layout.cl.jac`
3. `app/components/AppShell.cl.jac`
4. `app/hooks/useRepoGhost.cl.jac`
5. `app/orchestration/workflow.sv.jac`
6. `app/services/*` and `app/agents/*`
7. `app/graph/builder.jac`
8. final workflow bundle rendered by `WidgetShell` and `WorkspaceShell`

## Where Recent Stability Fixes Landed

Most important recent fixes landed in:

- `app/components/AppShell.cl.jac`
  - client state correctness and warning cleanup
- `app/components/WidgetShell.cl.jac`
  - callback wrapper fix for editable inputs
- `app/components/WorkspaceShell.cl.jac`
  - callback wrapper fix for editable inputs
- `app/orchestration/workflow.sv.jac`
  - type-stability and deterministic bundle assembly cleanup
- `vite.repoghost.resolve.mjs`
  - fresh-machine client resolution support
- `typing.repoghost.js`
  - tracked client shim replacing ignored generated dependency assumptions

For the full narrative, see:

- `implementation-history-and-fixes.md`

## Change Routing Heuristics

Use these rules before editing:

- change the UI shell when the issue is presentation or user interaction
- change the hook when the issue is client/server request flow
- change orchestration when the issue is stage ordering, bundle assembly, or trace
- change services when the issue is deterministic extraction or repo parsing
- change agents when the issue is reasoning/output shaping
- change models first when multiple layers disagree about a data shape
- change graph files when the issue is graph nodes, edges, or visual relationships
- change root build files when the issue is startup, Vite resolution, Bun, or fresh-machine rebuilds

## Files That Should Be Treated Carefully

These areas have caused repeated integration issues and should be edited conservatively:

- `app/components/AppShell.cl.jac`
- `app/components/WidgetShell.cl.jac`
- `app/components/WorkspaceShell.cl.jac`
- `app/orchestration/workflow.sv.jac`
- `app/models/*`
- `vite.repoghost.resolve.mjs`
- `jac.toml`

When changing those files, always re-run:

- `jac check main.jac`

and then do a local UI smoke test.
