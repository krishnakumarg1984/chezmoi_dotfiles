#!/bin/bash --login

# need a login shell for sourcing the shell's startup scripts so that environment variables for tools are set correctly
set -eu

echo ""

if [ -x "$(command -v mise)" ]; then
  echo "--- Prune/uninstall unused mise global tools ---"
  "$HOME/.local/bin/mise" prune --yes
  echo "--- Finished pruning/uninstalling unused mise global tools ---"
fi
