#!/usr/bin/env bash

shopt -s nullglob  # Avoid literal *.pdf if no matches

for file in *.pdf; do
    # Skip if somehow not a regular file (extra safety)
    [[ -f "$file" ]] || continue

    echo "Processing: $file"

    "$HOME/bin/pdfsizeopt_podman.sh" $file

done
