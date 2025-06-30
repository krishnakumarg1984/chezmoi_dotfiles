# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:

# ((( Notes/comments (README) about this file (~/.bashrc)

# NOTE: bash scripts will NOT run this file i.e. will NOT have access to aliases/functions and settings defined herein
# Non-login shells will also NOT source this file
# In our setup, scripts can be made to source this file indirectly by using the `--login` flag
# Since ~/.bashrc is for non-login shells, avoid any commands which echo to the screen.

# Nothing other than exported variables and exported functions from ~/.bash_profile or ~/.profile will be automatically provided to independent subprocess shells.
# Functions can be exported with export -f (with Bash)

# Also, if the `bash` interpreter is invoked as `sh`, it won’t read the ~/.bashrc initialization file in an interactive shell.

# This customised ~/.bashrc file is specifically set up to be sourced in EACH & EVERY `bash` shell session.
# By default, ~/.bashrc is sourced only for a) X11 and b) INTERACTIVE non-login shells
# But, we have forcibly sourced it (inside ~/.bash_profile) for login shells as well so that login shells can benefit from aliases
# and function definitions as well.

# http://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

# For Bash, read down the appropriate column.
# Sources A, then B, then C, etc. The B1, B2, B3 means it sources only the first of those files found.

# +----------------+-----------+-----------+------+
# |                |Interactive|Interactive|Script|
# |                |login      |non-login  |      |
# +----------------+-----------+-----------+------+
# |/etc/profile    |   A       |           |      |  # Typically does the following: a) sets up $PS1 for root and normal users, b) sources scripts in /etc/profile.d/, c) in a system with bash as the default interpreter, sources /etc/bash.bashrc (Debian only) or /etc/bashrc
# +----------------+-----------+-----------+------+
# |/etc/bash.bashrc|           |    A      |      |  # Debian-specific
# +----------------+-----------+-----------+------+
# |~/.bashrc       |           |    B      |      |
# +----------------+-----------+-----------+------+
# |~/.bash_profile |   B1      |           |      |
# +----------------+-----------+-----------+------+
# |~/.bash_login   |   B2      |           |      |
# +----------------+-----------+-----------+------+
# |~/.profile      |   B3      |           |      |
# +----------------+-----------+-----------+------+
# |BASH_ENV        |           |           |  A   |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |~/.bash_logout  |    C      |           |      |
# +----------------+-----------+-----------+------+

# ))) Notes/comments (README) about this file (~/.bashrc)

# ((( UNUSED set and shopt bash options. SO IGNORE!!! Disables 'histexpand' setting with explanation
# https://stackoverflow.com/questions/11816122/echo-fails-event-not-found
# The ! character is used for csh-style history expansion. If you do not use this feature, set +o histexpand (aka set +H) turns
# off this behavior. It is turned off for scripts, but often enabled for interactive use. In such cases, my personal
# recommendation is to turn it off permanently

# https://stackoverflow.com/questions/25003162/how-to-address-error-bash-d-event-not-found-in-bash-command-substitution/25021905#25021905
# Bash history expansion is a very odd corner in the bash command line parser, and you are clearly running into an unexpected
# history expansion, which is explained below. However, any sort of history expansion in a script is unexpected, because normally
# history expansion is not enabled in scripts; not even scripts run with the source (or .) builtin.
# There are two shell options which control history expansion:
#     set -o history: Required for the history to be recorded.
#     set -H (or set -o histexpand): Additionally required for history expansion to be enabled.
# https://stackoverflow.com/questions/11025114/how-do-i-escape-an-exclamation-mark-in-bash
# https://superuser.com/questions/133780/in-bash-how-do-i-escape-an-exclamation-mark/133782#133782

# set +o histexpand
# ))) Disables 'histexpand' setting with explanation

# {{ if (ne .chezmoi.osRelease.prettyName "CentOS Linux 7 (Core)") }}
# shopt | grep -q '^nullglob\b' && shopt -q -s nullglob                # If a pattern fails to match. https://riptutorial.com/bash/example/13125/behaviour-when-a-glob-does-not-match-anything
# # shopt | grep -q '^failglob\b' && shopt -q -s failglob                # If a pattern fails to match, bash reports an expansion error. This can be useful at the commandline: https://riptutorial.com/bash/example/13125/behaviour-when-a-glob-does-not-match-anything.  failglob supersedes nullglob
# {{ end }}

# make `less` more friendly for non-text input files, see lesspipe(1)
# if [ -x "$(command -v lesspipe)" ]; then
#     eval "$(SHELL=/bin/sh lesspipe)"
# fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# [ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh ssh-copy-id

# [[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# https://unix.stackexchange.com/questions/230742/bash-zsh-tab-autocomplete-given-initial-command-ignore-certain-files-in-direct
# where -f will complete filenames, -X filters out matching patterns from the possible choices with a glob string, and -o plusdirs will afterward add subdirectories to the list.
# complete -f -X '*.@(4ct|4tc|acn|acr|alg|auxlock|aux|a|backup|bak|bbl|bcf|blg|brf|cb2|cb|cpt|cut|dll|dpth|DS_Store|dvi|dx64fsl|el|end|ent|eps|fasl|fdb_latexmk|fff|fls|fmt|fot|gaux|gem|gif|glg|glo|glsdefs|glstex|gls|gtex|hst|idea|idv|idx|ilg|ind|ist|jpeg|jpg|la|lb|lg|listing|loa|lock|lod|loe|lof|lol|lot|lox|ltjruby|luac|lx64fsl|maf|mf|mlf|mlt|mod|mo|mp|mw|nav|nc|nlg|nlo|nls|obj|out|o|pax|pdfpc|pdfsync|pdf|png|pre|ps|pyc|pyg|pytxcode|rbc|rbo|runxml|save|snm|soc|sout|so|spl|sta|svg|swp|sympy|synctexgz|synctex|tdo|texpadtmp|tfm|thm|toc|trc|ttt|upa|upb|ver|vrb|wrt|xcp|xdv|xdy|xmpi|xref|xyc|)' -o plusdirs vi
# complete -f -X '*.@(4ct|4tc|acn|acr|alg|auxlock|aux|a|backup|bak|bbl|bcf|blg|brf|cb2|cb|cpt|cut|dll|dpth|DS_Store|dvi|dx64fsl|el|end|ent|eps|fasl|fdb_latexmk|fff|fls|fmt|fot|gaux|gem|gif|glg|glo|glsdefs|glstex|gls|gtex|hst|idea|idv|idx|ilg|ind|ist|jpeg|jpg|la|lb|lg|listing|loa|lock|lod|loe|lof|lol|lot|lox|ltjruby|luac|lx64fsl|maf|mf|mlf|mlt|mod|mo|mp|mw|nav|nc|nlg|nlo|nls|obj|out|o|pax|pdfpc|pdfsync|pdf|png|pre|ps|pyc|pyg|pytxcode|rbc|rbo|runxml|save|snm|soc|sout|so|spl|sta|svg|swp|sympy|synctexgz|synctex|tdo|texpadtmp|tfm|thm|toc|trc|ttt|upa|upb|ver|vrb|wrt|xcp|xdv|xdy|xmpi|xref|xyc|)' -o plusdirs vim
# complete -f -X '*.@(4ct|4tc|acn|acr|alg|auxlock|aux|a|backup|bak|bbl|bcf|blg|brf|cb2|cb|cpt|cut|dll|dpth|DS_Store|dvi|dx64fsl|el|end|ent|eps|fasl|fdb_latexmk|fff|fls|fmt|fot|gaux|gem|gif|glg|glo|glsdefs|glstex|gls|gtex|hst|idea|idv|idx|ilg|ind|ist|jpeg|jpg|la|lb|lg|listing|loa|lock|lod|loe|lof|lol|lot|lox|ltjruby|luac|lx64fsl|maf|mf|mlf|mlt|mod|mo|mp|mw|nav|nc|nlg|nlo|nls|obj|out|o|pax|pdfpc|pdfsync|pdf|png|pre|ps|pyc|pyg|pytxcode|rbc|rbo|runxml|save|snm|soc|sout|so|spl|sta|svg|swp|sympy|synctexgz|synctex|tdo|texpadtmp|tfm|thm|toc|trc|ttt|upa|upb|ver|vrb|wrt|xcp|xdv|xdy|xmpi|xref|xyc|)' -o plusdirs nvim

# {{ if (eq .chezmoi.os "darwin") }} # macOS-specific customisations for 'complete' (((
#
# # Add tab completion for `defaults read|write NSGlobalDomain`
# # You could just use `-g` instead, but I like being explicit
# complete -W "NSGlobalDomain" defaults
#
# # Add `killall` tab completion for common apps
# complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
#
# {{ end }}
# )))

# ((( Set up homebrew completions
# https://docs.brew.sh/Shell-Completion
{{ if (ne .chezmoi.username "uccagop") }}
# if type brew &>/dev/null; then
#     HOMEBREW_PREFIX="$(brew --prefix)"
#     # if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
#     #     source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
#     # else
#         for COMPLETION in "${HOMEBREW_PREFIX}"/etc/bash_completion.d/*; do
#             [[ -r "$COMPLETION" ]] && source "$COMPLETION"
#         done
#     # fi
#     brew completions link && clear
# fi
{{ end }}
# ))) Set up homebrew completions

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/krishnakumar/mambaforge-pypy3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/krishnakumar/mambaforge-pypy3/etc/profile.d/conda.sh" ]; then
#         . "/home/krishnakumar/mambaforge-pypy3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/krishnakumar/mambaforge-pypy3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
#
# if [ -f "/home/krishnakumar/mambaforge-pypy3/etc/profile.d/mamba.sh" ]; then
#     . "/home/krishnakumar/mambaforge-pypy3/etc/profile.d/mamba.sh"
# fi
# # <<< conda initialize <<<

# {{- if ne .chezmoi.username "dc-gopa1" }}
# if [ -x "$HOME/miniforge3/bin/conda" ]; then
#     __conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#     if [ $? -eq 0 ]; then
#         eval "$__conda_setup"
#     else
#         if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
#             . "$HOME/miniforge3/etc/profile.d/conda.sh"
#         else
#             # export PATH="/home/krishnakumar/miniforge/bin:$PATH"
#             _path_prepend PATH "$HOME/miniforge3/bin:$PATH"
#             # export $PATH
#         fi
#     fi
#     unset __conda_setup
#     conda activate
# fi
# {{- else }}
#     module load miniconda/3
#     # >>> conda initialize >>>
#     # !! Contents within this block are managed by 'conda init' !!
#     __conda_setup="$('/usr/local/software/archive/linux-scientific7-x86_64/gcc-9/miniconda3-4.7.12.1-rmuek6r3f6p3v6fdj7o2klyzta3qhslh/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#     if [ $? -eq 0 ]; then
#         eval "$__conda_setup"
#     else
#         if [ -f "/usr/local/software/archive/linux-scientific7-x86_64/gcc-9/miniconda3-4.7.12.1-rmuek6r3f6p3v6fdj7o2klyzta3qhslh/etc/profile.d/conda.sh" ]; then
#             . "/usr/local/software/archive/linux-scientific7-x86_64/gcc-9/miniconda3-4.7.12.1-rmuek6r3f6p3v6fdj7o2klyzta3qhslh/etc/profile.d/conda.sh"
#         else
#             export PATH="/usr/local/software/archive/linux-scientific7-x86_64/gcc-9/miniconda3-4.7.12.1-rmuek6r3f6p3v6fdj7o2klyzta3qhslh/bin:$PATH"
#         fi
#     fi
#     unset __conda_setup
#     # <<< conda initialize <<<
#     conda deactivate
#     conda activate condaenv_base
#     module unload miniconda/3
# {{- end }}

# {{ if (eq .chezmoi.username "uccagop") }}
# # User specific aliases and functions
# #module load gcc
# module purge
# # source /shared/ucl/apps/bin/defmods
# # module purge
# # module unload flex
# # module unload apr
# # module unload apr-util
# # module unload subversion
# # module unload screen
# # module unload nedit
# # module unload dos2unix
# # module unload emacs
# # module unload mrxvt
# # module unload rcps-core
# # module unload compilers
# # module unload mpi
# # module unload nano
# # module unload giflib
# # module unload default-modules
# # module purge
# module load gcc-libs
# module load cmake
# module load git
# module load gerun
# module load tmux
# module load userscripts
# module load nano
# LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/bin/aspell_compiled/lib"
# export LD_LIBRARY_PATH
# {{ end }}

# {{ if (or (eq .chezmoi.hostname "nextgenio-login2") (eq .chezmoi.hostname "nextgenio-amd01")) }}
# source /home/nx08/shared/fpga/fpga_modules.sh 1>/dev/null 2>/dev/null
# module purge
# module load common_fpga/1.0 1>/dev/null 2>/dev/null
# module load packages-nextgenio 1>/dev/null 2>/dev/null
# module load vitis/2021.1 1>/dev/null 2>/dev/null
# # source /home/nx08/shared/fpga/xilinx/2021.1/Vitis/2021.1/settings64.sh
# module load host_support 1>/dev/null 2>/dev/null
# module load vitis_libraries 1>/dev/null 2>/dev/null
# source /opt/xilinx/xrt/setup.sh 1>/dev/null 2>/dev/null
# XCL_EMULATION_MODE=sw_emu
# export XCL_EMULATION_MODE
# export PYTHONPATH=""
# # module swap gnu gnu8/8.3.0 2>&1 >/dev/null
# # module load anaconda3 2>&1 >/dev/null
# source /home/software/anaconda/python3-2019/bin/activate 2>&1 >/dev/null
# source ~/Documents/dace_iterative_solvers/source_xilinx_dace_dependencies.sh 2>&1 >/dev/null
# conda activate dace_git
# {{ end }}

# umask 0022

# Define a function `mans` to jump to a specific section in a man page (((
# https://serverfault.com/questions/206810/how-to-jump-to-a-specific-heading-in-a-man-page
# mans () {    # Bash
#     local pages string
#     if [[ -n $2 ]]
#     then
#         pages=(${@:2})
#         string="$1"
#     else
#         pages=$1
#     fi
#     # GNU man
#     man ${2:+--pager="less -p \"$string\" -G"} ${pages[@]}
#     # BSD man
#     # man ${2:+-P "less -p \"$string\" -G"} ${pages[@]}
# }
# )))

# Start `tmux` if  (1) tmux doesn't try to run within itself, (2) we're in an interactive shell and (3) tmux exists on the system (((
# https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux/113768#113768
# The following solution is built upon the given solutions. It is a improvement on them and addresses few issues.
#     If you are using a DE and try to use 'Right Click > Open In Terminal' then it will open in current location.
#     What happens if you have multiple clients?

# function tmux-as-default-terminal () {
#
#   # If we are not inside tmux session
#   if [[ ! "$TERM" =~ tmux ]] && command -v tmux &> /dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [[ ! "$TERM" =~ screen ]]; then
#       tmux a -t default || exec tmux new -s default && exit;
#   fi
#
# }
#
# tmux-as-default-terminal

# if [ "${-#*i}" == "$-" ]; then
    # https://serverfault.com/questions/146745/how-can-i-check-in-bash-if-a-shell-is-running-in-interactive-mode
    # bind -x '"\C-l": clear'
    # bind -x $'"\C-l":clear;'
# fi

# https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux/113768#113768
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#     # exec $(command -v tmux) new-session -w main # https://unix.stackexchange.com/questions/595665/set-default-shell-to-tmux-with-options
#     # https://askubuntu.com/questions/1119478/how-to-properly-launch-tmux-on-terminal-startup
#     # tmux attach -t default || tmux new -s default # https://ostechnix.com/autostart-tmux-session-on-remote-system-when-logging-in-via-ssh/
#
#     # Adapted from https://unix.stackexchange.com/a/176885/347104
#     # Create session 'main' or attach to 'main' if already exists.
#     # tmux new-session -A -s main
# fi

# )))
