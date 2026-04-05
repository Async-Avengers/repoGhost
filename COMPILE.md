# Desktop Compilation

RepoGhost compiles to a native desktop app via [Tauri 2](https://tauri.app). The window is fixed at **400×844px** (phone size).

## Prerequisites

- Rust + Cargo (`rustup`)
- `webkit2gtk` (already installed on this system)
- `jac` CLI (`pip install jaclang jac-client`)
- `bun` (for the Vite frontend)

Install the Tauri CLI once:

```bash
cargo install tauri-cli --version "^2"
```

---

## Dev mode

Run both processes in separate terminals:

```bash
# Terminal 1 — Jac dev server + Vite HMR (port 8001 API, port 8000 frontend)
jac start --dev main.jac

# Terminal 2 — Tauri window (connects to localhost:8000)
cargo tauri dev
```

The Tauri window opens at 400×844 and proxies all API calls to the running Jac server.

---

## Production build

```bash
# 1. Build the Vite frontend into .jac/client/dist
bun run tauri:build-frontend

# 2. Compile and bundle the Tauri app
cargo tauri build
```

Output is in `src-tauri/target/release/bundle/`.

### Bundling the Jac server as a sidecar

For a fully self-contained binary, the Jac API server needs to be bundled alongside the app:

1. Build or obtain a standalone `jac-server` binary for the target platform.
2. Place it at:
   ```
   src-tauri/binaries/jac-server-x86_64-unknown-linux-gnu
   ```
   (Adjust the target triple for your platform — run `rustc -vV | grep host` to get it.)
3. In `src-tauri/tauri.conf.json`, set:
   ```json
   "bundle": {
     "externalBin": ["binaries/jac-server"]
   }
   ```
4. In `src-tauri/src/lib.rs`, uncomment the sidecar launch block inside `setup`.

Until the sidecar is wired, users must run `jac start main.jac` separately before launching the app.

---

## Icons

The icons in `src-tauri/icons/` are placeholders. Replace them with real assets before publishing:

| File | Size |
|---|---|
| `32x32.png` | 32×32 RGBA PNG |
| `128x128.png` | 128×128 RGBA PNG |
| `128x128@2x.png` | 256×256 RGBA PNG |
| `icon.icns` | macOS icon bundle |
| `icon.ico` | Windows icon |

A quick way to generate all sizes from a single source image:

```bash
cargo tauri icon path/to/source.png
```
