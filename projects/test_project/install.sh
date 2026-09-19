#!/usr/bin/env bash
# Setup script for this project's Goose recipes.
# Run from anywhere: bash install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECIPES_DIR="$SCRIPT_DIR/recipes"
MODEL="gpt-oss:20b"   # this project's expected model -- adjust as needed

echo "== Goose project setup: $(basename "$SCRIPT_DIR") =="
echo ""

# 1. Check goose is installed
if ! command -v goose >/dev/null 2>&1; then
  echo "ERROR: 'goose' CLI not found on PATH."
  echo "Install it: https://block.github.io/goose/docs/getting-started/installation"
  exit 1
fi
echo "OK    goose found ($(command -v goose))"

# 2. Check Ollama is reachable (this project uses a local model)
if command -v curl >/dev/null 2>&1; then
  if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "OK    Ollama is running on localhost:11434"
  else
    echo "WARN  Ollama doesn't seem to be running -- start it with: ollama serve"
  fi
fi

# 3. Make sure the model this project expects is pulled
if command -v ollama >/dev/null 2>&1; then
  if ollama list 2>/dev/null | grep -q "$MODEL"; then
    echo "OK    Model '$MODEL' is already pulled"
  else
    echo "..    Pulling model '$MODEL' (this project's default)"
    ollama pull "$MODEL"
  fi
fi

# 4. List the recipes ("agents") this project ships
echo ""
echo "Recipes available in this project:"
shopt -s nullglob
for f in "$RECIPES_DIR"/*.yaml; do
  title=$(grep -m1 '^title:' "$f" | sed -E 's/^title:[[:space:]]*//; s/^"(.*)"$/\1/')
  echo "  - $(basename "$f")  ->  ${title:-<no title>}"
done
shopt -u nullglob

echo ""
echo "Setup checks done. Before running recipes in THIS shell, set:"
echo ""
echo "  export GOOSE_RECIPE_PATH=\"$RECIPES_DIR\""
echo ""
echo "Then run a recipe, e.g.:"
echo "  goose run --recipe code-reviewer.yaml --params target_path=./src"
