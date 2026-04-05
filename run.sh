#!/bin/bash
# RepoGhost local launcher
# Builds the frontend if needed, starts the jac server, and opens the app in a browser.
set -e
cd "$(dirname "$0")"

JAC="${HOME}/.local/share/uv/tools/jaclang/bin/jac"
if [ ! -x "$JAC" ]; then
  JAC="$(command -v jac)"
fi
APP_URL="http://localhost:8001/static/index.html"

# Build the frontend if dist/index.html is missing
if [ ! -f ".jac/client/dist/index.html" ]; then
  echo "[run.sh] Building frontend..."
  cd .jac/client
  node_modules/.bin/vite build --config configs/vite.config.js
  cd ../..
fi

echo "[run.sh] Starting RepoGhost..."
echo "[run.sh] App will be available at: $APP_URL"

# Start jac server in background
"$JAC" start main.jac &
SERVER_PID=$!

# Give it a moment then open the browser
sleep 2
if command -v xdg-open &>/dev/null; then
  xdg-open "$APP_URL"
elif command -v open &>/dev/null; then
  open "$APP_URL"
else
  echo "[run.sh] Open your browser to: $APP_URL"
fi

# Wait for server (Ctrl+C to stop)
wait $SERVER_PID
