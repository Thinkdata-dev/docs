#!/usr/bin/env bash
# Lightweight serve script: create venv if missing, install deps if needed, then run mkdocs serve
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$ROOT_DIR/.venv"
REQUIREMENTS_FILE="$ROOT_DIR/requirements.txt"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment at $VENV_DIR"
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/python" -m pip install --upgrade pip
fi

if [ -f "$REQUIREMENTS_FILE" ]; then
  echo "Installing dependencies from $REQUIREMENTS_FILE"
  "$VENV_DIR/bin/pip" install -r "$REQUIREMENTS_FILE"
fi

echo "Starting mkdocs serve (press Ctrl+C to stop)"
exec "$VENV_DIR/bin/mkdocs" serve
