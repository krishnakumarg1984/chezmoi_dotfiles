#!/usr/bin/env bash

set -eu

echo ""
echo "--- Installing mise ---"
if command -v mise || [ -x "$HOME/.local/bin/mise" ] &>/dev/null; then
  echo "Mise is already installed"
else
  curl https://mise.run | sh
fi
