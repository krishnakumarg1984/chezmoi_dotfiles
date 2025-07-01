#!/bin/bash --login

# need a login shell for sourcing the shell's startup scripts so that environment variables for tools are set correctly
set -eu

echo ""
echo "--- Installing all mise global tools ---"

if [ -x "$HOME/.local/bin/mise" ]; then
  if [ -x "$(command -v nproc)" ]; then
    NCORES=$(nproc)
  else
    NCORES=$(grep "^processor" /proc/cpuinfo | wc -l)
  fi
  MISE_JOBS=$((NCORES < 8 ? NCORES : 8)) # At most 8 cores. https://stackoverflow.com/a/10415158

  MISE_QUIET=1 "$HOME/.local/bin/mise" --jobs "$MISE_JOBS" --yes --quiet install
fi

echo "--- Finished installing all mise global tools ---"
