#!/bin/bash --login

set -eu

echo ""
if [ -x "$HOME/.config/pixi/bin/topgrade" ] &>/dev/null; then
  echo "--- Updating all installed tools with topgrade ---"

  "$HOME/.config/pixi/bin/topgrade" || true

  echo "--- Finished updating all installed tools with topgrade  --"
fi
