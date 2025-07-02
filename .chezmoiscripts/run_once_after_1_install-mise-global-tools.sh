#!/bin/bash --login

# need a login shell for sourcing the shell's startup scripts so that environment variables for tools are set correctly
set -eu

echo ""

# if [ -x "$HOME/.local/bin/mise" ]; then
# export PATH="$HOME/.local/bin:$PATH"
if [ -x "$(command -v mise)" ]; then
  echo "--- Installing all mise global tools ---"
  if [ -x "$(command -v nproc)" ]; then
    NCORES=$(nproc)
  else
    NCORES=$(grep "^processor" /proc/cpuinfo | wc -l)
  fi
  MISE_JOBS=$((NCORES < 8 ? NCORES : 8)) # At most 8 cores. https://stackoverflow.com/a/10415158

  # MISE_QUIET=1 MISE_VERBOSE=1
  "$HOME/.local/bin/mise" --jobs "$MISE_JOBS" install
  echo "--- Finished installing all mise global tools ---"
fi
