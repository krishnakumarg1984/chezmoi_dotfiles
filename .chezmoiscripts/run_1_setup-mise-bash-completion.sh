#!/usr/bin/env bash

set -eu

echo ""
echo "--- Installing all mise global tools ---"

if [ -x "$HOME/.local/bin/mise" ]; then
  "$HOME/.local/bin/mise" completion bash --include-bash-completion-lib > "$HOME/.local/share/bash-completion/completions/mise"
fi

echo "--- Finished installing all mise global tools ---"
