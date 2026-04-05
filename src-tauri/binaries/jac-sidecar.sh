#!/bin/bash
# Jac Sidecar Wrapper - Runs Jac backend using system Python
# This requires Python and jaclang to be installed

JAC_PYTHON="$HOME/.local/share/uv/tools/jaclang/bin/python"
if [ ! -x "$JAC_PYTHON" ]; then
    echo "Error: jaclang uv tool not found at $JAC_PYTHON" >&2
    echo "  Install it with: uv tool install jaclang" >&2
    exit 1
fi
exec "$JAC_PYTHON" -m jac_client.plugin.src.targets.desktop.sidecar.main --port 8001 "$@"
