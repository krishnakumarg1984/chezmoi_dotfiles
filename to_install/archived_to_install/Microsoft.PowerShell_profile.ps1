# https://hamidmosalla.com/2022/12/26/how-to-customize-windows-terminal-and-powershell-using-fzf-neovim-and-beautify-it-with-oh-my-posh/

# Imports the terminal Icons into curernt Instance of PowerShell
Import-Module -Name Terminal-Icons

Import-Module -Name PSReadLine

# Set some useful Alias to shorten typing and save some key stroke
Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias .. 'cd..'

# Set Some Option for PSReadLine to show the history of our typed commands
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs

#Fzf (Import the fuzzy finder and set a shortcut key to begin searching)
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
