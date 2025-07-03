#!/bin/bash --login

# need a login shell for sourcing the shell's startup scripts so that environment variables for tools are set correctly
set -eu

echo ""

if [ -x "$HOME/.local/share/mise/shims/stew" ]; then
  echo "--- Installing all stew global tools ---"
  echo "N\n" | "$HOME/.local/share/mise/shims/stew" i "$HOME/.config/stew/Stewfile" 2>/dev/null
  clear
  echo "--- Finished installing all stew global tools ---"
fi
