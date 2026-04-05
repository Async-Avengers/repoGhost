# OpenAI Integration Implementation Notes

See also:

- `docs/README.md`
- `docs/system-overview.md`
- `docs/implementation-history-and-fixes.md`
- `docs/current-state-and-known-issues.md`
- `docs/developer-runbook.md`

## Purpose

This document is the implementation guide for the first OpenAI-backed RepoGhost version.

Goals for this pass:

- add Jac-native `by llm()` support
- preserve deterministic fallback
- keep Stage 2 hybrid and mostly deterministic
- avoid breaking the current working MVP
- fix cross-machine Vite HMR/WebSocket reliability

## Current Baseline

- RepoGhost currently works deterministically.
- `run_workflow(...)` is the stable orchestration entrypoint.
- Stage 1 is mostly deterministic extraction.
- Stage 2 is deterministic reasoning.
- Stage 3 is deterministic artifact generation.
- The UI already renders the workflow bundle, trace, planning, tickets, handoff, standup, and review outputs.

## Chosen Architecture

- Use Jac-native `by llm()`.
- Keep all OpenAI calls server-side only.
- Auto-load `.env.local` for local development, with shell environment variables taking precedence.
- Use a fast/cheap default model posture.
- Keep deterministic fallbacks for every LLM-backed step.
- Add visible UI badges for `LLM`, `Hybrid`, and `Fallback`.

## Implementation Order

### Step 1: Fix dev-runtime reliability

- Normalize Vite dev and HMR host handling.
- Make the dev config path consistent across generated config and documented dev commands.
- Ensure a fresh machine can open the UI successfully on `:8000`.

### Step 2: Add LLM runtime/config module

- Add one central byLLM runtime/config module.
- Load environment values from `.env.local` for local development.
- Provide availability and fallback helpers so startup does not fail when OpenAI config is missing.

### Step 3: LLM-enable Stage 1

- Generate `RepoSummary` from deterministic repo scan context.
- Extract `MeetingSummary` from meeting notes with structured LLM output.
- Extract doc-grounded `DecisionItem`s from synced documentation.
- Keep code search deterministic and use the LLM only for reranking or rationale refinement.

### Step 4: LLM-enable Stage 2 hybrid

- Keep deterministic candidate generation for resolved areas, blockers, impacts, and test gaps.
- Use the LLM only for refinement, prioritization, confidence shaping, and narrative cleanup.

### Step 5: LLM-enable Stage 3

- Use `by llm()` for:
  - action plan
  - tasks and tickets
  - standup
  - handoff
  - review prep

### Step 6: Add trace metadata and UI badges

- Record whether each step used `LLM`, `Hybrid`, or `Fallback`.
- Surface that state in the top-level UI and the workflow trace.

### Step 7: Add repo-wide validation and update docs

- Add a repeatable all-Jac-files validation script.
- Update the README with a pointer to this document and the new validation flow.

## Per-Agent Notes

### Repo mapper

- Keep repo scan deterministic.
- Feed deterministic scan output into the LLM to generate `RepoSummary`.
- Fall back to the existing `summarize_repo(...)`.

### Meeting interpreter

- Primary path: structured `MeetingSummary` via LLM.
- Fall back to the current parser.

### Code search

- Keep deterministic file discovery and primary ranking.
- Allow optional LLM reranking only over top candidates.
- Never allow the LLM to invent files that were not found deterministically.

### Docs sync

- Keep deterministic documentation file selection.
- Use the LLM to extract doc-grounded `DecisionItem`s.
- Fall back to the current first-meaningful-line behavior.

### Stage 2 agents

- Deterministic first pass remains mandatory.
- Use the LLM only to refine wording, confidence, ordering, and priority.

### Stage 3 agents

- Primary path should be LLM generation.
- Deterministic generators remain automatic fallback implementations.

## Fallback Rules

- Missing `OPENAI_API_KEY` must not break app startup.
- Model or provider failure must not break `run_workflow(...)`.
- Every LLM-enabled step should:
  - try the LLM path
  - catch failure
  - record fallback reason
  - use the deterministic implementation
- The final workflow bundle must always remain typed and renderable.

## Type and Trace Updates

- Extend `WorkflowTraceStep` with:
  - `execution_mode`
  - `model_name`
  - `fallback_reason`
- Add run-level LLM status metadata to the workflow bundle, or an equivalent derived status object consumed by the client.
- Keep the existing output object shapes stable.

## UI Notes

- Add visible badges in:
  - the top-level app status area
  - the widget shell
  - the workspace shell
  - trace cards
- Supported badge states:
  - `LLM`
  - `Hybrid`
  - `Fallback`
- Error UI should never expose secrets, provider tokens, or raw key material.

## Validation Notes

- Add a repeatable all-Jac-files validation command or script.
- Validation should cover:
  - `main.jac`
  - all `*.jac`
  - all `*.sv.jac`
  - all `*.cl.jac`
- Treat this as the repo-level equivalent of the VSCode Problems sweep.

## Acceptance Criteria

- The app still works with no API key.
- The app works with a valid OpenAI key.
- Cross-machine Vite dev runtime works.
- Inputs remain editable.
- The workflow trace renders correctly.
- Bundle fields render in both widget and workspace.
- `jac check` passes for the main entry and all Jac files.

## Assumptions

- File path is `docs/openai-integration-implementation-notes.md`.
- Default model posture is fast/cheap.
- Stage 2 remains hybrid, not fully LLM-driven.
- Deterministic fallback is mandatory.
- `OPENAI_API_KEY` must never be exposed client-side.
