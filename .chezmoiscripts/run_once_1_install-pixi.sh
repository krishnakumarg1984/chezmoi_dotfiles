#!/usr/bin/env bash

set -eu

echo ""
echo "--- Installing Pixi ---"
if command -v pixi || [ -x "$HOME/.config/pixi/bin/pixi" ] || [ -x "$HOME/.pixi/bin/pixi" ] &>/dev/null; then
  echo "Pixi is already installed"
else
  curl -fsSL https://pixi.sh/install.sh | PIXI_HOME="$HOME/.config/pixi" PIXI_NO_PATH_UPDATE=1 bash
fi
echo "--- Finished installing Pixi ---"
