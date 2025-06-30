# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:

# Notes/comments (README) about this file (~/.bash_profile) (((

# ~/.bash_profile (this file) is sourced only for LOGIN SHELLS (both physical & ssh logins).
# Non-login shells and scripts will NOT source this file at all
# In my setup, scripts can be made to source this file indirectly by using the `--login` flag

# Nothing from ~/.bash_profile other than exported variables and exported functions will be automatically provided to independent
# subprocess shells. Functions can be exported with export -f (with Bash)

# http://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

# For Bash, read down the appropriate column.
# Sources A, then B, then C, etc. The B1, B2, B3 means it sources only the first of those files found.

# +----------------+-----------+-----------+------+
# |                |Interactive|Interactive|Script|
# |                |login      |non-login  |      |
# +----------------+-----------+-----------+------+
# |/etc/profile    |   A       |           |      |  # Typically does the following: a) sets up $PS1 for root and normal users. b) sources scripts in /etc/profile.d/, c) in a system with bash as the default interpreter, sources /etc/bash.bashrc (Debian only) or /etc/bashrc
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

# )))

# # auto-start the ssh agent if not already running and add keys to it (((
# # https://stackoverflow.com/a/18915067
# SSH_ENV="$HOME/.ssh/agent-environment"
#
# function start_agent {
#   echo "Initialising new SSH agent..."
#   /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
#   echo succeeded
#   chmod 600 "$SSH_ENV"
#   . "$SSH_ENV" >/dev/null
#   # /usr/bin/ssh-add
#   # for possiblekey in ${HOME}/.ssh/id_*; do
#   #   if grep -q PRIVATE "$possiblekey"; then
#   #     ssh-add "$possiblekey"
#   #   fi
#   # done
# }
#
# # Source SSH settings, if applicable
#
# if [ -f "$SSH_ENV" ]; then
#   . "$SSH_ENV" >/dev/null
#   #ps $SSH_AGENT_PID doesn't work under Cygwin
#   ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ >/dev/null || {
#     start_agent
#   }
# else
#   start_agent
# fi
# # )))

# Table of contents (((

# 1. Source ~/.profile if it exists (settings that are common across shells e.g. env variables $PATH, $MANPATH etc.)
# 2. Set and export history-related environment variables specific to bash
# 3. Set up pipx completions
# 4. Source ~/.bashrc (if it exists) to have aliases/functions etc defined for login shell sessions as well

# )))

# ~/.profile had the following general settings (TOC) (((
#  1. Define idempotent _path_prepend() & _path_append() functions (with example usage)
#  2. Source the `brew` command if it is installed in the relevant directory & not already in $PATH
#  3. Prepend various Texlive env vars
#  4. Disable capslock key
#  5. Prepend the `cargo` command to $PATH
#  6. Prepend "$HOME/bin" and "$HOME/.local/bin" to $PATH
#  7. Append "$HOME/.rbenv/bin" to $PATH
#  8. Prepend "$HOME/man" to $MANPATH
#  9. Configure/Export FIGNORE for `sh` to ignore certain filetypes for autocompletion
# 10. Setting LOCALE for the new UTF-8 terminal support
# 11. Comments: Nice/detailed explanations of shell startup concepts and configuration files
# 12. Set LESS_TERMCAP_xx environment variables for colorising the output of the `less` pager
# 13. Obtain colored GCC warnings & errors by setting the environment variable GCC_COLORS
# 14. Set up and export the GREP_COLORS environment variable
# 15. Set up and export the PAGER environment variable
# 16. Set up the BROWSER environment variable
# 17. Set up the EDITOR, SUDO_EDITOR and MANPAGER environment variables
# 18. Set up umask for default files to have -rw-rw-r-- permissions
# )))

# {{ if (ne .chezmoi.username "uccagop") }}
# # https://serverfault.com/questions/146745/how-can-i-check-in-bash-if-a-shell-is-running-in-interactive-mode_
# if [ "${-#*i}" == "$-" ]; then
#     # https://unix.stackexchange.com/questions/141228/control-l-not-clearing-screen
#     bind -x '"\C-l": clear'
# fi
# {{ end }}

# Other commented out code from ~/.bash_profile (((
# ((( Set up pipx completions
# `pipx` command has been made available either from homebrew (which was set up earlier in ~/.profile), or from conda (which was added to path above in this file)
# if [ -x "$(command -v pipx)" ]; then
#     eval "$(register-python-argcomplete pipx)" # check if pipx completions work in sub-shells. Otherwise move to ~/.bashrc
# fi
# ))) Set up

# if [ -x "$(command -v rbenv)" ]; then
#     eval "$(rbenv init - bash)"
# fi

# if [ -e ~/perl5/perlbrew/etc/bashrc ]; then
#     source ~/perl5/perlbrew/etc/bashrc
# fi

# test -r $HOME/.opam/opam-init/init.sh && . $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# )))

# OS specific customisations (((

# {{ if (eq .chezmoi.os "linux") }} # ((( Linux-specific customisations
# ))) end Linux-specific customisations
# {{ else if (eq .chezmoi.os "darwin") }} # ((( begin macOS-specific customisations
# {{ end }} # )))

# )))

# Extract and compress functions() (((
# extract() {
#     if [ -f "$1" ]; then
#         case $1 in
#         *.tar.bz2) tar xjf "$1" ;;
#         *.tar.gz) tar xzf "$1" ;;
#         *.bz2) bunzip2 "$1" ;;
#         *.rar) rar x "$1" ;;
#         *.gz) gunzip "$1" ;;
#         *.tar) tar xf "$1" ;;
#         *.tbz2) tar xjf "$1" ;;
#         *.tgz) tar xzf "$1" ;;
#         *.zip) unzip "$1" ;;
#         *.Z) uncompress "$1" ;;
#         *.7z) 7z x "$1" ;;
#         *) echo "'$1' cannot be extracted via extract()" ;;
#         esac
#     else
#         echo "'$1' is not a valid file"
#     fi
# }

# compress() {
#     FILE=$1
#     shift
#     case $FILE in
#         *.tar.bz2) tar cjf "$FILE" "$*" ;;
#         *.tar.gz) tar czf "$FILE" "$*" ;;
#         *.tgz) tar czf "$FILE" "$*" ;;
#         *.zip) zip "$FILE" "$*" ;;
#         *.rar) rar "$FILE" "$*" ;;
#         *) echo "Filetype not recognized" ;;
#     esac
# }
# )))

