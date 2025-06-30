# Setup fzf
# ---------

# if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
#     PATH="${PATH:+${PATH}:}/home/linuxbrew/.linuxbrew/opt/fzf/bin"
# fi

if [ -r "$HOME/.local/opt/brew/opt/fzf/bin" ]; then
    _path_append PATH "$HOME/.local/opt/brew/opt/fzf/bin"
elif [ -r "/home/linuxbrew/.linuxbrew/opt/fzf/bin" ]; then
    _path_append PATH "/home/linuxbrew/.linuxbrew/opt/fzf/bin"
fi

if [ -x "$(command -v fzf)" ]; then
    # alias fzf="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

    # Auto-completion & keybindings
    # -----------------------------
    if [ -d "$HOME/.config/bash/fzf_shell" ]; then
        . "$HOME/.config/bash/fzf_shell/fzf_completion.bash"
        . "$HOME/.config/bash/fzf_shell/key-bindings.bash"
    elif [ -d "$HOME/.local/opt/brew/opt/fzf/shell" ]; then
        . "$HOME/.local/opt/brew/opt/fzf/shell/completion.bash"
        . "$HOME/.local/opt/brew/opt/fzf/shell/key-bindings.bash"
    elif [ -d "/home/linuxbrew/.linuxbrew/opt/fzf/shell" ]; then
        . "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash"
        . "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"
    fi
fi
