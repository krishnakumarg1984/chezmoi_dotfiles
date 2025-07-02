#!/bin/bash --login

set -eu

echo ""
if command -v nvim &>/dev/null; then
  echo "--- Running nvim headless for the first time with astronvim config  ---"

  nvim --headless -c 'quitall' && clear

  echo "--- Finished running nvim headless for the first time with astronvim config  --"
fi
