# RepoGhost MVP Scope and Roadmap

## Purpose

This document defines what the current RepoGhost MVP is, what it is not, and what the next implementation phases should be.

It exists so future work can preserve the original product intent instead of drifting into isolated feature patches.

## MVP Definition

RepoGhost MVP is the first viable working version of the project.

Its job is to prove the end-to-end developer-sidecar flow:

- accept a repo path
- accept meeting or planning context
- run a staged workflow
- produce structured engineering outputs
- render those outputs in both compact and expanded UI forms

The MVP is not trying to be fully autonomous, production-hardened, or truly intelligent yet.

## What the MVP Includes

### Core product loop

- local repo path input
- meeting text input
- prompt input
- deterministic workflow execution
- graph-backed output bundle
- widget and workspace rendering modes

### Deterministic workflow pipeline

- Stage 1 repo and meeting context gathering
- Stage 2 reasoning and prioritization
- Stage 3 engineering artifact generation

### Primary output types

- file matches
- blockers
- planning insights
- tasks
- tickets
- standup update
- handoff note
- review scope
- trace

### Local developer experience

- `jac check`
- `jac start --dev`
- Vite client UI
- Jac API docs

## What the MVP Explicitly Does Not Include Yet

Not implemented yet:

- real OpenAI/byLLM execution
- authenticated multi-user flows
- persistence beyond the current local/deterministic memory pattern
- production deployment hardening
- desktop packaging/distribution
- automated full-suite tests
- robust repo-wide validation scripting
- hardened cross-machine HMR/WebSocket support

## Product Assumptions

The current MVP assumes:

- local development first
- one developer or small-team demo usage
- repo access is local filesystem based
- meeting context is pasted manually
- correctness is grounded by deterministic repo data, not generated guesses

## Architectural Non-Negotiables

Future work should preserve these constraints:

- deterministic file grounding remains authoritative
- workflow output shapes stay typed and stable
- client never receives raw secret material
- generated files under `.jac/` are not source of truth
- the app must still function when no OpenAI key is present

## Why the MVP Was Built This Way

The project needed a stable baseline before adding LLM behavior.

That required:

- a working Jac full-stack skeleton
- stable typed models
- a renderable workflow bundle
- repeatable local startup
- fixes for Jac type instability and client build/runtime breakage

Without that baseline, adding `by llm()` would have compounded unresolved client and orchestration issues.

## Current User Journey

1. Start the local app.
2. Open the UI on `:8000`.
3. Enter a repo path.
4. Paste meeting or planning context.
5. Enter a prompt.
6. Run the workflow.
7. Review files, blockers, plans, tickets, handoff, review scope, and trace.

This journey is the core product contract to preserve.

## Roadmap

### Phase 1: Stabilized deterministic MVP

Delivered or largely delivered:

- typed workflow and graph contracts
- deterministic pipeline
- client rendering flow
- fresh-machine rebuild fixes
- tracked build shims
- editable inputs and working prompt flow

### Phase 2: Infrastructure cleanup

Still needed:

- normalize Vite dev/HMR config across machines
- add repeatable all-Jac-files validation
- improve startup and troubleshooting docs further if necessary

### Phase 3: OpenAI/byLLM integration

Planned:

- add Jac-native `by llm()`
- preserve deterministic fallback everywhere
- keep Stage 2 hybrid
- expose `LLM`, `Hybrid`, and `Fallback` state in UI and trace

See:

- `openai-integration-implementation-notes.md`

### Phase 4: Post-LLM product hardening

Potential future work:

- better memory quality
- stronger repo-aware ranking
- richer graph semantics
- automated tests
- deployment packaging
- desktop packaging
- auth and multi-user support

## Known Risks to Watch

These are the most likely sources of regression:

- `AppShell` state logic
- generated client callback behavior
- workflow type identity/inference drift
- build assumptions tied to `.jac/`
- cross-machine Vite HMR configuration

## Definition of “Still Working”

When making future changes, the MVP should still satisfy all of these:

- `jac check main.jac` passes
- UI loads on `:8000`
- `/docs` loads on `:8001/docs`
- inputs remain editable
- one full workflow run completes
- widget and workspace both render outputs
- no generated-module browser crash appears

## Related Documents

- `system-overview.md`
- `implementation-history-and-fixes.md`
- `developer-runbook.md`
- `current-state-and-known-issues.md`
- `openai-integration-implementation-notes.md`
