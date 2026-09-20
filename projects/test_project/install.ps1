# Setup script for this project's Goose recipes.
# Run from anywhere: powershell -File install.ps1
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RecipesDir = Join-Path $ScriptDir "recipes"
$Model = "gpt-oss:20b"   # this project's expected model -- adjust as needed

Write-Host "== Goose project setup: $(Split-Path -Leaf $ScriptDir) =="
Write-Host ""

# 1. Check goose is installed
if (-not (Get-Command goose -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'goose' CLI not found on PATH." -ForegroundColor Red
    Write-Host "Install it: https://block.github.io/goose/docs/getting-started/installation"
    exit 1
}
Write-Host "OK    goose found"

# 2. Check Ollama is reachable
try {
    Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 3 | Out-Null
    Write-Host "OK    Ollama is running on localhost:11434"
} catch {
    Write-Host "WARN  Ollama doesn't seem to be running -- start it with: ollama serve" -ForegroundColor Yellow
}

# 3. Make sure the model this project expects is pulled
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    $installed = ollama list 2>$null
    if ($installed -match [regex]::Escape($Model)) {
        Write-Host "OK    Model '$Model' is already pulled"
    } else {
        Write-Host "..    Pulling model '$Model' (this project's default)"
        ollama pull $Model
    }
}

# 4. List the recipes ("agents") this project ships
Write-Host ""
Write-Host "Recipes available in this project:"
Get-ChildItem -Path $RecipesDir -Filter *.yaml -ErrorAction SilentlyContinue | ForEach-Object {
    $titleLine = Select-String -Path $_.FullName -Pattern '^title:' | Select-Object -First 1
    $title = if ($titleLine) { ($titleLine.Line -replace '^title:\s*', '') -replace '"', '' } else { "<no title>" }
    Write-Host "  - $($_.Name)  ->  $title"
}

Write-Host ""
Write-Host "Setup checks done. Before running recipes in THIS shell, set:"
Write-Host ""
Write-Host "  `$env:GOOSE_RECIPE_PATH = `"$RecipesDir`""
Write-Host ""
Write-Host "Then run a recipe, if one time headless session:"
Write-Host "  goose run --recipe code-reviewer.yaml --params target_path=./src"
Write-Host "For interactive sessions:"
Write-Host "  goose run --recipe code-reviewer.yaml --params target_path=./src -s"
