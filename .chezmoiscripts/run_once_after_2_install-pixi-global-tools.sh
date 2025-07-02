#!/bin/bash --login

# need a login shell for sourcing the shell's startup scripts so that environment variables for tools are set correctly
set -eu

echo ""

if [ -x "$(command -v pixi)" ]; then
  echo "--- Installing all pixi global tools ---"
  pixi global sync
  echo "--- Finished installing all pixi global tools ---"
fi
