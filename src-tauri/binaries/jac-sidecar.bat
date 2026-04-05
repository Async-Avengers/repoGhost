@echo off
REM RepoGhost sidecar — starts the Jac server (API + frontend on port 8001).
REM First argument: project directory (where main.jac lives).

where jac >nul 2>&1
if errorlevel 1 (
    echo [sidecar] Error: jac not found on PATH >&2
    echo [sidecar]   Install with: uv tool install jaclang >&2
    exit /b 1
)

if not "%~1"=="" if exist "%~1\" (
    cd /d "%~1"
)

echo [sidecar] Starting jac server in %CD% >&2
jac start main.jac
