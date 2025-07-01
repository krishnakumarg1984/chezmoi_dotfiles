#!/usr/bin/env sh

set -eu

echo ""
echo "--- Running nvim headless for the first time with astronvim config  ---"
nvim --headless -c 'quitall' && clear
echo "--- Finished running nvim headless for the first time with astronvim config  --"
