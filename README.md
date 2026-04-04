# RepoGhost

RepoGhost is a desktop-ready Jac fullstack application that ingests a permitted repository path and meeting context, builds a graph-native project context, and turns developer conversation into structured engineering output.

## Current build
- Dark polished widget + expanded workspace shell
- Typed workflow/result contracts
- Graph-native domain model contracts
- Real Stage 1 repo ingestion, search, docs sync, meeting parsing, and memory services
- Unified project context graph merged from Stage 1 outputs
- Stage 2 reasoning agents for context resolution, blockers, dependency impact, and test gaps
- Stage 3 output agents for action planning, ticket writing, standup generation, handoff notes, and review prep
- Final structured outputs rendered across the widget and workspace
- Loading, status, and error-state polish for demo flow
- Desktop-target readiness notes for compact widget and expanded workspace modes

## Run locally
```bash
jac install
jac start --dev main.jac
```

Open the app at the local Jac dev URL, typically `http://127.0.0.1:8001`.

## Build notes
- Use `jac install` after dependency or `jac.toml` changes.
- Use `jac start --dev main.jac` for local iteration.
- RepoGhost is currently optimized for local demo mode with no auth requirement.
- The compact widget and expanded workspace are both available in the same dev UI shell.

## Short test checklist
- Start the app and confirm the page renders without a blank screen.
- Confirm the header shows graph, planning, risk, and output metrics.
- Change the mode in the widget and verify the selected mode updates.
- Edit the repo path, meeting text, and prompt, then run the workflow.
- Confirm the chat thread appends the new user request and assistant response.
- Open the Files, Tickets, Blockers, Handoff, Review, and Trace tabs and verify structured content appears.
- Trigger an invalid run state, such as an empty prompt, and confirm the error state is visible.

## Desktop / Tauri readiness
RepoGhost is structured to be desktop-friendly:
- compact floating widget shell for sidecar-style use
- expanded workspace shell for deeper review and planning
- local-first workflow for demo-friendly offline-ish behavior
- no auth dependency for local demo mode
- desktop metadata is noted in `jac.toml` under `tool.repoghost.desktop`

For a future Tauri packaging pass:
- wrap the Jac client app in a Tauri shell
- configure the compact window as always-on-top
- expose a larger resizable workspace window
- keep local file permissions scoped to permitted repo paths
- package the current frontend shell and Jac backend together for desktop distribution

## Product pillars
- Compact always-on-top side widget
- Expanded engineering workspace
- Visible multi-agent execution trace
- Session and project memory
- Repo-aware structured outputs
- Unified project context graph
- Execution planning context
- Action plans, tickets, standups, handoffs, and review scope
