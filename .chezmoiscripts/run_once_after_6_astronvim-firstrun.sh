#!/bin/bash --login

set -eu

echo ""
if [ -x "$HOME/.local/share/mise/shims/nvim" ] &>/dev/null; then
  echo "--- Running nvim headless for the first time with astronvim config  ---"

  "$HOME/.local/share/mise/shims/nvim" --headless -c 'quitall' && clear

  echo "--- Finished running nvim headless for the first time with astronvim config  --"
fi
