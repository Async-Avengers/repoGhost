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

### Prerequisites

- Jac CLI installed and available on `PATH`
- Bun installed and available on `PATH`
- Python available for the Jac runtime

This project uses the Jac client/Vite pipeline, and that currently depends on Bun on a fresh machine.

### Fresh machine setup

```bash
python -m pip install -r requirements.txt
jac install
jac check main.jac
jac start --dev main.jac
```

### Local URLs

- App UI: `http://127.0.0.1:8000`
- Jac API docs: `http://127.0.0.1:8001/docs`

`http://127.0.0.1:8001` is the API server, not the main app page.

## Docker

### Prerequisites

- Docker and Docker Compose installed

### Run with Docker Compose

```bash
docker compose up -d
```

This builds the image and starts the container. The UI is available at `http://localhost:8000` and the API at `http://localhost:8001`.

### Build the image manually

```bash
docker build -t repoghost .
docker run -d --name repoghost -p 8000:8000 -p 8001:8001 repoghost
```

### CI

A GitHub Actions workflow (`.github/workflows/docker-build.yml`) builds and validates the Docker image on every push and PR to `main`. It uses Docker Buildx with GitHub Actions caching for fast rebuilds.

## Build notes

- Use `jac install` after dependency or `jac.toml` changes.
- Bun is required for the generated client build/dev flow.
- Use `jac check main.jac` to validate the project after pulling on a new device.
- Use `jac build` to validate the production client bundle.
- Use `jac start --dev main.jac` for local iteration.
- RepoGhost is currently optimized for local demo mode with no auth requirement.
- The compact widget and expanded workspace are both available in the same dev UI shell.

## Troubleshooting

### The app works at `/docs` but not in the browser UI

That usually means the Jac API is up, but the Vite client is not the page you are opening.

- open `http://127.0.0.1:8000` for the UI
- open `http://127.0.0.1:8001/docs` for the API docs

### Fresh pull on a different machine fails to start

Check these first:

- Bun is installed and available on `PATH`
- `jac install` completed successfully
- `jac check main.jac` passes
- you are opening `http://127.0.0.1:8000`, not `:8001`

### Browser shows generated-module/import errors

Stop the dev server, then rerun:

```bash
jac install
jac check main.jac
jac start --dev main.jac
```

If a stale generated client still causes trouble, remove the local `.jac/` folder and start again.

## Team testing guide

Another team member should test RepoGhost as if they are a fresh collaborator joining the project for the first time.

### Recommended test flow

#### 1. Start from a clean checkout

- Pull the latest committed version of the repo.
- Open the project at the repo root.
- Read the `README.md` first and follow only those instructions.

This is the best way to verify the project is understandable and runnable without hand-holding.

#### 2. Set up the environment

- Install dependencies exactly as documented.
- Use the Jac/Jaseci versions noted in the README, if specified.
- Start the app in development mode using the documented command.

They should confirm:

- the app starts without compile/runtime errors
- the compact widget renders
- the expanded workspace opens correctly
- the styling/layout looks intact

#### 3. Run one realistic end-to-end scenario

Have them test with:

- a real local repo path
- sample meeting notes or transcript text
- a realistic prompt, for example:
  - `Turn this meeting into tickets`
  - `What files are probably involved?`
  - `Prepare a handoff`

They should verify that RepoGhost visibly runs through its staged workflow and shows the multi-agent trace.

#### 4. Validate the main output areas

They should inspect whether these sections populate sensibly:

- repo summary
- relevant files
- blockers
- action plan
- tickets
- standup
- handoff
- review prep
- graph/trace views

The key question is whether the outputs feel grounded in both the repo and the meeting input, not generic.

#### 5. Test failure and edge cases

Ask them to intentionally try:

- an invalid repo path
- empty meeting notes
- a vague or underspecified prompt

They should confirm:

- errors are understandable
- the UI remains usable
- one failure does not break the whole app experience

#### 6. Use the README checklist as the QA baseline

Since the project already includes a short test checklist in the README, that should be the shared standard for team testing.

That gives everyone a consistent way to verify:

- setup
- startup
- workflow behavior
- output quality
- desktop-readiness cues

#### 7. Capture feedback in a useful format

Ask them to report:

- exact steps they took
- expected vs actual behavior
- screenshots for UI issues
- any console/runtime errors
- the repo path and prompt they used

That makes bugs reproducible and much easier to fix.

### Best practical advice

The strongest test is: **can another teammate, on a clean environment, follow the README and complete one full repo + meeting workflow without help?**

If yes, RepoGhost is in a strong state for demo and handoff.

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
