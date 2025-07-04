#!/bin/bash --login

set -eu

echo ""
if [ -x "$HOME/.config/pixi/bin/topgrade" ] &>/dev/null; then
  echo "--- Updating all installed tools with topgrade ---"

  "$HOME/.config/pixi/bin/topgrade" --yes --cleanup --disable waydroid --disable system --disable flatpak --disable firmware --disable conda --disable chezmoi

  echo "--- Finished updating all installed tools with topgrade  --"
fi
