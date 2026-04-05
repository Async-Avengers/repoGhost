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

## Tauri (native packaging)

The Tauri setup in `src-tauri/` is used for native app packaging. It is not needed for local development or testing.

### Prerequisites

- Rust + `cargo tauri` CLI
- **Linux/AppImage only**: `linuxdeploy` — install from AUR:
  ```bash
  yay -S linuxdeploy-appimage
  ```

### Build

The Tauri bundle embeds the Jac source files (`main.jac`, `app/`, `jac.toml`) and the
compiled frontend (`dist/`) so the installed binary is self-contained — no repository
checkout is needed on the target machine.

```bash
# 1. Build the frontend (required — dist/ is bundled as a resource):
cd .jac/client
node_modules/.bin/vite build --config configs/vite.config.js
cd ../..

# 2. Build the Tauri bundle:
NO_STRIP=1 cargo tauri build
```

Output lands in `target/release/bundle/` (`.deb`, `.rpm`, `.AppImage`).

> **Note:** `jac` must still be installed on the target machine
> (`uv tool install jaclang`). The app will write its working files to
> `~/.local/share/dev.repoghost.repoghost/` on Linux on first launch.

### Known issues

**`NO_STRIP=1` is required on Arch Linux** for AppImage builds. Tauri downloads its own `linuxdeploy` AppImage to `~/.cache/tauri/`, which bundles an old `strip` binary that cannot handle modern ELF binaries using `.relr.dyn` sections (used by current Arch packages). Setting `NO_STRIP=1` skips stripping and lets the build complete.

**tauri-cli / crate version mismatch warning**: if you see `__TAURI_BUNDLE_TYPE variable not found in binary`, the CLI and crate versions are out of sync. Sync them with:
```bash
cargo install tauri-cli --version $(grep -A1 'name = "tauri"' Cargo.lock | grep version | head -1 | grep -oP '[\d.]+')
```
