#!/usr/bin/env bash

set -eu

echo ""
echo "--- Installing mise ---"
if command -v mise &>/dev/null; then
  echo "Mise is installed"
else
  curl https://mise.run | sh
fi
