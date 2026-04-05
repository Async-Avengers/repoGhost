# RepoGhost local launcher (Windows)
# Builds the frontend if needed, starts the jac server, and opens the app in a browser.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Resolve-JacExecutable {
    $command = Get-Command jac -ErrorAction SilentlyContinue
    if ($command -and $command.Source) {
        return $command.Source
    }

    $candidatePatterns = @(
        "$env:APPDATA\uv\tools\jaclang\Scripts\jac.exe",
        "$env:LOCALAPPDATA\uv\tools\jaclang\Scripts\jac.exe",
        "$env:APPDATA\Python\Python*\Scripts\jac.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python*\Scripts\jac.exe"
    )

    foreach ($pattern in $candidatePatterns) {
        $match = Get-ChildItem $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match -and $match.FullName) {
            return $match.FullName
        }
    }

    throw "Could not find jac.exe. Install Jac and make sure `jac` is available on PATH."
}

$JAC = Resolve-JacExecutable
$APP_URL = "http://localhost:8001/static/index.html"

# Build the frontend if dist/index.html is missing
if (-not (Test-Path ".jac\client\dist\index.html")) {
    Write-Host "[run.ps1] Building frontend..."
    Push-Location ".jac\client"
    & "node_modules\.bin\vite.cmd" build --config configs/vite.config.js
    Pop-Location
}

Write-Host "[run.ps1] Starting RepoGhost..."
Write-Host "[run.ps1] App will be available at: $APP_URL"
Write-Host "[run.ps1] Using jac at: $JAC"

# Start jac server in background
$server = Start-Process -FilePath $JAC -ArgumentList "start", "main.jac" -PassThru -NoNewWindow

# Give it a moment then open the browser
Start-Sleep -Seconds 2
Start-Process $APP_URL

# Wait for server (Ctrl+C to stop)
try {
    $server.WaitForExit()
} finally {
    if (-not $server.HasExited) {
        $server.Kill()
    }
}
