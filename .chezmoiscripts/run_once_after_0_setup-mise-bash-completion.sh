#!/bin/bash --login

set -eu

echo ""
echo "--- Setting up mise bash completion ---"

if [ -x "$HOME/.local/bin/mise" ]; then
  mkdir -p "$HOME"/.local/share/bash-completion/completions
  "$HOME/.local/bin/mise" completion bash --include-bash-completion-lib >|"$HOME/.local/share/bash-completion/completions/mise"
fi

echo "--- Finished setting up mise bash completion ---"
