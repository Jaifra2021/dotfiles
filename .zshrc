# Set tab completion and matching options
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
autoload -Uz compinit
compinit

# Allow bulk file renaming with zmv command
autoload -U zmv

# Set number of commands stored in memory and in the history file
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.history_zsh

# Enable bash-style comments at command line and extended zsh globbing
setopt interactivecomments extendedglob 

# Use vi keybindings to navigate command line
bindkey -v

# Append to history file and save command's beginning timestamp/duration
setopt appendhistory extendedhistory

# Don't add duplicate lines, or lines starting with a space to the history file
setopt histignoredups histignorespace

# Search through command history with ^r like bash (in vi insert mode)
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^S' history-incremental-search-forward

# Search through command history with vi search keys (in vi command mode)
bindkey -M vicmd '?' history-incremental-pattern-search-backward
bindkey -M vicmd '/' history-incremental-pattern-search-forward

# Set prompt
autoload -U colors && colors
PROMPT="%{$fg[green]%}%c %# %{$reset_color%}"
