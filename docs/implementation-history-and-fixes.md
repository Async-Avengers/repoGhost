# RepoGhost Implementation History and Fixes

## Purpose

This document records the main implementation work that shaped the current RepoGhost MVP, including the major issues encountered during development and how they were addressed.

It is intended to answer:

- what was built
- why certain patterns were chosen
- what broke during implementation
- what the fixes were
- which issues are resolved versus still pending

## Major Delivered Workstreams

The current MVP was assembled through these workstreams:

- Jac full-stack project setup
- typed workflow, output, and graph contracts
- deterministic Stage 1 repo, docs, meeting, search, and memory services
- deterministic Stage 2 reasoning agents
- deterministic Stage 3 output agents
- compact widget UI
- expanded workspace UI
- graph-backed workflow bundle rendering
- Vite/Jac client build wiring
- fresh-machine setup and validation guidance

## Key Problems Encountered and Their Fixes

### 1. Jac type inference and LSP `Unknown` errors

Symptoms:

- many files reported errors such as:
  - `Cannot assign <Unknown> ...`
  - `Type is Unknown, cannot access attribute ...`
  - same-name type identity mismatches across modules

Affected areas:

- thin agent wrappers
- workflow composition
- AppShell state access
- service wrapper returns

Root cause:

- Jac/LSP was unstable around selective imports, wrapped return values, and cross-module type identity in a few places.

Fix strategy used:

- prefer `include ...` where the checker needed local visibility of concrete return types
- move sensitive field access into local typed scope
- avoid unnecessary wrapper indirection around typed results
- avoid duplicating type identity across module boundaries where the analyzer behaved inconsistently

Outcome:

- `jac check main.jac` passes
- the large class of `Unknown`/field-access problems was eliminated

### 2. Client bundle import/export failures

Symptoms:

- browser runtime failures from generated modules
- missing exports for model types in compiled client imports

Root cause:

- client code was depending on symbols that should remain server-side or should not have been emitted as browser imports in that form

Fix strategy used:

- simplify client-side typing surfaces
- avoid leaking server-only model expectations into the client bundle
- keep the client focused on renderable bundle data instead of importing unnecessary server model archetypes

Outcome:

- the main client-side module export crash was eliminated

### 3. Missing `typing.js` on fresh machines

Symptoms:

- another machine could rebuild the repo but fail because generated `.jac/client/compiled/typing.js` did not exist

Root cause:

- the build path relied on a generated file under `.jac/`
- `.jac/` is ignored and therefore absent on a fresh checkout

Fix strategy used:

- add tracked shim:
  - `typing.repoghost.js`
- update client resolver:
  - `vite.repoghost.resolve.mjs`

Outcome:

- the typing shim is now tracked in the repo instead of depending on generated local state

### 4. Frozen/static UI inputs

Symptoms:

- textarea and input fields appeared locked or reverted immediately
- submit behavior also behaved incorrectly

Root cause A:

- generated client code turned callbacks into constructor calls such as:
  - `new onDraft(...)`
  - `new onSubmit(...)`

Fix strategy A:

- add safe callback wrappers in:
  - `WidgetShell.cl.jac`
  - `WorkspaceShell.cl.jac`
- call callbacks using `fn.call(None, value)`

Root cause B:

- `AppShell` was reassigning stale state back into:
  - `repoPath`
  - `meetingText`
  - `draftPrompt`
  - `prompt`
  - `error`

Fix strategy B:

- remove stale self-overwrite patterns
- remove `tap_str(...)` based reassignments
- update chat thread immutably instead of mutating in place

Outcome:

- client code regenerated with normal callback invocation
- stale input-reset behavior was removed

### 5. AppShell warning churn

Symptoms:

- VSCode/Jac warnings such as:
  - `'repoPath' is defined but never used`
  - `'draftPrompt' is defined but never used`

Root cause:

- reactive Jac client assignments were being treated by the analyzer like plain locals

Fix strategy used:

- add a minimal `mark_used(...)` helper in `AppShell.cl.jac`
- touch assigned reactive values in a harmless way that does not change behavior

Outcome:

- warnings were cleared without reintroducing stale state behavior

### 6. Fresh-machine setup gaps

Symptoms:

- project recreated on another device did not have enough setup guidance
- Bun and Jac prerequisites were not obvious

Fix strategy used:

- add `requirements.txt`
- update README with:
  - Python install step
  - `jac install`
  - `jac check main.jac`
  - `jac start --dev main.jac`
- explicitly note that Bun is required for the Jac client/Vite pipeline

Outcome:

- setup is significantly more repeatable on a clean machine

### 7. Confusion about the two local ports

Symptoms:

- `/docs` worked while the main UI appeared broken

Root cause:

- the repo exposes:
  - Vite UI on `:8000`
  - Jac API docs on `:8001/docs`

Fix strategy used:

- document the split clearly in README and troubleshooting notes

Outcome:

- the expected UI/API split is now documented

## Remaining Open or Partially Resolved Items

### Cross-machine Vite HMR / WebSocket issue

Observed symptom:

- another machine reached `localhost:8000` over HTTP but Vite HMR WebSocket failed to connect

Current understanding:

- the repo still has dev-config drift and HMR-host assumptions that are stable locally but may not be stable across machines or network setups

Status:

- identified
- documented
- not fully fixed yet

Planned fix area:

- normalize dev/HMR host configuration
- make the active dev config path consistent

### OpenAI/byLLM integration

Status:

- planned
- not yet implemented

Reference:

- `docs/openai-integration-implementation-notes.md`

## Current Design Lessons

The current repo reflects a few strong implementation lessons:

- keep deterministic file grounding authoritative
- keep client state logic simple and explicit
- do not rely on generated files inside ignored folders for repo-critical behavior
- prefer tracked shims over hidden generated assumptions
- use local typed helpers when Jac inference becomes unstable
- verify generated client output when frontend bugs look impossible from source alone
