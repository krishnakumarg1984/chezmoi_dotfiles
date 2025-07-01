#!/usr/bin/env bash

set -eu

echo ""
echo "--- Setting up mise bash completion ---"

if [ -x "$HOME/.local/bin/mise" ]; then
  "$HOME/.local/bin/mise" completion bash --include-bash-completion-lib >"$HOME/.local/share/bash-completion/completions/mise"
fi

echo "--- Finished setting up mise bash completion ---"
