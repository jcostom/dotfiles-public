#!/usr/bin/env zsh

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
zstyle :compinstall filename '/Users/jcostomiris/.zshrc'
autoload -Uz compinit
compinit

# Aliases
alias dir='ls -lGF'

# Prompt
autoload -Uz colors && colors
export PROMPT="
%{$fg_bold[white]%}[%{$fg_bold[red]%}%n@%m%{$fg_bold[white]%}](%{$fg_bold[blue]%}%T%)
%{$fg_bold[green]%}%/%{$fg_bold[blue]%}%#%{$reset_color%} "

# Right-justified current time.  I merged this in with the regular $PROMPT to make
# room for the git status $RPROMPT.
# export RPROMPT="(%{$fg_bold[blue]%}%T%)%{$reset_color%}"

# Right justified git status that magically activates when you're in a repository
# Uncomment this if you'd like that.
test -e "${HOME}/.git_prompt.zsh" && source "${HOME}/.git_prompt.zsh"
test -e "${HOME}/.dotfiles-private/zsh-local-vars.zsh" && source "${HOME}/.dotfiles-private/zsh-local-vars.zsh"

# Homebrew
export BYOBU_PREFIX=$(brew --prefix)
