#!/usr/bin/env bash

# Setup fzf
# ---------
if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/home/linuxbrew/.linuxbrew/opt/fzf/bin"
fi

if [ -r "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash" ]; then
    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash" 2>/dev/null
    # Key bindings
    # ------------
    source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"
fi
