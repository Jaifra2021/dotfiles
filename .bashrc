# Don't do anything if this is not an interactive session
case $- in
    *i*) ;;
      *) return;;
esac

# Enable tab-completion
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Append to history file instead of overwriting
shopt -s histappend

# Don't add duplicate lines, or lines starting with a space to the history file
HISTCONTROL=ignoreboth

# Set number of commands stored in memory and in the history file
HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=$HOME/.history_bash

# Update values of LINES and COLUMNS after window resize
shopt -s checkwinsize

# Use '**' in pathname expansions like in ZSH
shopt -s globstar

# Set prompt
PS1='\[\e[1;32m\]\W \$\[\e[0m\] '
