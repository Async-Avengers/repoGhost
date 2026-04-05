# Running RepoGhost Locally

RepoGhost runs as a local web app served by the Jac backend. No desktop wrapper or Rust build is required.

## Quick start

```bash
./run.sh
```

This builds the frontend if needed, starts the Jac server, and opens the app in your browser at:

```
http://localhost:8001/static/index.html
```

---

## Manual steps

### 1. Install Python dependencies (once)

```bash
# Requires uv: https://docs.astral.sh/uv/
uv tool install jaclang
# Then install websockets into the jaclang env:
~/.local/share/uv/tools/jaclang/bin/python -m ensurepip
~/.local/share/uv/tools/jaclang/bin/python -m pip install websockets
```

### 2. Install Node dependencies (once)

```bash
cd .jac/client && bun install
```

### 3. Build the frontend

```bash
cd .jac/client
node_modules/.bin/vite build --config configs/vite.config.js
cd ../..
```

Output lands in `.jac/client/dist/`. The `vite.generate-html.mjs` plugin auto-generates `dist/index.html` pointing to the hashed bundle.

### 4. Start the server

```bash
~/.local/share/uv/tools/jaclang/bin/jac start main.jac
```

Then open **http://localhost:8001/static/index.html**.

---

## Dev mode (live reload)

```bash
jac start --dev main.jac
```

Frontend with HMR at **http://localhost:8000**, API at **http://localhost:8001**.

---

## How it works

`jac start main.jac` (no flags) runs the Jac API server **and** serves the compiled frontend from `.jac/client/dist/` as static files — all at port 8001. Since the frontend is served from the same origin as the API, all fetch calls use relative paths and there are no CORS issues.

| URL | What it serves |
|-----|---------------|
| `http://localhost:8001/static/index.html` | App entry point |
| `http://localhost:8001/styles.css` | Compiled CSS |
| `http://localhost:8001/client.[hash].js` | React bundle |
| `http://localhost:8001/function/*` | Jac API endpoints |
| `http://localhost:8001/docs` | Swagger UI |

---

## Tauri (future native packaging)

The Tauri setup in `src-tauri/` is preserved for future native app packaging. It is not needed for local development or testing.

To build a native app:
1. Install Rust + `cargo tauri` CLI
2. Build frontend: see step 3 above
3. `cargo tauri build` — output in `src-tauri/target/release/bundle/`
