# RepoGhost System Overview

## Purpose

RepoGhost is a Jac full-stack developer sidecar that combines:

- local repo context
- meeting context
- a staged workflow
- graph-backed project context
- structured engineering outputs

The current implementation is deterministic. It is designed so that LLM-backed behavior can be layered on later without changing the main app contract.

## Top-Level Runtime Shape

RepoGhost is split into:

- **Client UI**
  - Jac client components rendered through Vite
  - widget view and expanded workspace view
- **Server workflow**
  - Jac server functions and services
  - deterministic repo scan, meeting parsing, reasoning, artifact generation, and memory updates

Primary local URLs:

- UI: `http://127.0.0.1:8000`
- API docs: `http://127.0.0.1:8001/docs`

## Entry and UI Composition

Main entry:

- `main.jac`

UI composition:

- `app/components/Layout.cl.jac`
- `app/components/AppShell.cl.jac`
- `app/components/WidgetShell.cl.jac`
- `app/components/WorkspaceShell.cl.jac`

Current client structure:

- `Layout` loads global styling and renders `AppShell`
- `AppShell` owns the active deterministic workflow state and calls `run_workflow(...)`
- `WidgetShell` renders compact “sidecar” controls and summary output
- `WorkspaceShell` renders the larger engineering workspace, trace, files, planning, and outputs

## Workflow Layers

Primary orchestration:

- `app/orchestration/workflow.sv.jac`

The workflow is currently organized into three stages:

### Stage 1: Intake and context gathering

- repo mapping
- meeting interpretation
- code search
- docs sync
- memory updates

Relevant files:

- `app/services/repo_ingest.sv.jac`
- `app/services/search_index.sv.jac`
- `app/services/meeting_parse.sv.jac`
- `app/services/docs_sync.sv.jac`
- `app/services/memory_store.sv.jac`
- wrappers in `app/agents/`

### Stage 2: Reasoning and planning context

- context resolution
- blocker detection
- dependency impact
- test-gap identification

Relevant files:

- `app/agents/context_resolver.sv.jac`
- `app/agents/blocker_detector.sv.jac`
- `app/agents/dependency_impact.sv.jac`
- `app/agents/test_gap.sv.jac`

### Stage 3: Output generation

- action plan
- tasks
- tickets
- standup
- handoff
- review scope

Relevant files:

- `app/agents/action_planner.sv.jac`
- `app/agents/ticket_writer.sv.jac`
- `app/agents/standup_agent.sv.jac`
- `app/agents/handoff_agent.sv.jac`
- `app/agents/review_prep.sv.jac`

## Graph Layer

Graph construction:

- `app/graph/builder.jac`

The graph is not just a backend data structure. It is part of the UI-facing model:

- project summary
- file nodes
- blockers
- decisions
- ownership hints
- tasks and tickets
- output artifacts
- trace summary

UI consumers rely on:

- `GraphNodeView`
- `GraphEdgeView`
- `ProjectContextGraph`

defined in:

- `app/models/outputs.jac`

## Models and Contracts

Core types:

- `app/models/core.jac`

Workflow types:

- `app/models/workflow.jac`

Output and UI-facing types:

- `app/models/outputs.jac`

These types are important because much of the implementation work was about keeping Jac type inference stable across:

- services
- thin agent wrappers
- workflow composition
- client rendering

## Memory

Current memory is deterministic in-memory/project-scoped state:

- `app/services/memory_store.sv.jac`
- `app/memory/project_memory.jac`
- `app/memory/session.jac`

Current behavior:

- stores recent workflow session metadata
- stores simple project memory snapshots such as decisions, blockers, and tickets

## Styling and Frontend Build

Styling:

- `styles/global.css`

Client build/runtime:

- `jac.toml`
- `.jac/client/configs/vite.config.js`
- `.jac/client/configs/vite.dev.config.js`
- `vite.repoghost.resolve.mjs`
- `typing.repoghost.js`

Important constraints:

- the Jac client pipeline depends on Bun
- `.jac/` is generated and ignored
- tracked shims must live outside `.jac/` if fresh-machine rebuilds need them

## Current Architectural Intention

The project is intentionally split so that future LLM integration can be added in layers:

- deterministic file grounding remains authoritative
- typed workflow contracts remain stable
- Stage 2 can remain hybrid and mostly deterministic
- Stage 3 can become primarily LLM-backed later

The current deterministic MVP is the baseline that all future integrations should preserve.
