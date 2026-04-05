#!/bin/bash
# RepoGhost sidecar — starts the Jac server (API + frontend on port 8001).
# First argument: project directory (where main.jac lives).

JAC="$HOME/.local/share/uv/tools/jaclang/bin/jac"

if [ ! -x "$JAC" ]; then
    echo "[sidecar] Error: jac not found at $JAC" >&2
    echo "[sidecar]   Install with: uv tool install jaclang" >&2
    exit 1
fi

if [ -n "$1" ] && [ -d "$1" ]; then
    cd "$1" || exit 1
fi

echo "[sidecar] Starting jac server in $(pwd)" >&2
exec "$JAC" start main.jac
