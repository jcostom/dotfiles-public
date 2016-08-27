#!/usr/bin/env bash
# Better history
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTIGNORE="ls:pwd:exit"

if [ -f ${HOME}/.bash-local-vars.sh ]; then
    # shellcheck source=$HOME/.bash-local-vars.sh
    source "${HOME}/.bash-local-vars.sh"
fi

# variables
export IS_LINUX
IS_LINUX=$(uname -s) || true

if [ "$(uname)" == "Darwin" ]; then
    # running on macOS - setup brew & completion
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH
    # Disable homrew analytics (https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md)
    export HOMEBREW_NO_ANALYTICS=1
    export BYOBU_PREFIX
    BYOBU_PREFIX=$(brew --prefix) || true
    export BREW_PREFIX
    BREW_PREFIX=$(brew --prefix) || true

    if [ -f $BREW_PREFIX/etc/bash_completion ]; then
        # shellcheck source=/usr/local
        . $BREW_PREFIX/etc/bash_completion
    fi
elif [ "$(expr substr $IS_LINUX 1 5)" == "Linux" ]; then
    # running on Linux - setup completion
    if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
        . /etc/bash_completion
    fi
fi

# Common variables
if [ -f /usr/local/bin/vim ]; then
    export EDITOR=/usr/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi

# Bash Options
shopt -s histappend
shopt -s cdspell

# General Aliases
alias dir='ls -lGF'
alias txl='tmux ls'
alias txn='tmux new -s'
alias txa='tmux a -t'
alias myip='curl ipv4.icanhazip.com ; curl ipv6.icanhazip.com'
alias myip4='curl ipv4.icanhazip.com'
alias myip6='curl ipv6.icanhazip.com'
alias ipify='curl -s https://api.ipify.org'
alias header='curl -I'
alias df='df -H'
alias du='du -ch'

# macOS-specific Aliases & functions
if [ "$(uname)" == "Darwin" ]; then
    # Mute & unmute from CLI
    alias mute="osascript -e 'set volume output muted true'"
    alias unmute="osascript -e 'set volume output muted false'"

    # Long running CLI command?  Tack ";lmk" onto the end
    alias lmk="say 'Process complete.'"

    # Brew
    alias bupd="brew -v update"
    alias bupg="brew -v upgrade"
    alias bclean="brew -v cleanup"

    # MTR
    alias mtr='sudo mtr -e -o LSR NABWV'

    # vim
    alias gvim='open -a MacVim'

    # Mac IP Info
    alias localip='ipconfig getifaddr en0'
    alias ipinfo='ipconfig getpacket en0'

    # functions
    # ii:
    # display useful host related informaton
    ii() {
        echo -e "\nYou are logged on ${RED}$HOST"
        echo -e "\nAdditionnal information:$NC " ; uname -a
        echo -e "\n${RED}Users logged on:$NC " ; w -h
        echo -e "\n${RED}Current date :$NC " ; date
        echo -e "\n${RED}Machine stats :$NC " ; uptime
        echo -e "\n${RED}Current network location :$NC " ; scselect
        echo -e "\n${RED}Public facing IP Address :$NC " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }
fi

# Useful functions
# extract: Extract most know archives with one command
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# zipf: To create a ZIP archive of a folder
zipf () { zip -r "$1".zip "$1" ; }

# fs: Determine size of a file or total size of a directory
fs() {
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh
    else
        local arg=-sh
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@"
    else
        du $arg .[^.]* *
    fi
}

# Prompt
bold=$(tput bold)
white=$(tput setaf 7)
red=$(tput setaf 1)
blue=$(tput setaf 4)
green=$(tput setaf 2)
#magenta=$(tput setaf 5)
reset=$(tput sgr0)

export PS1='\[$bold\]\n\[$white\][\[$red\]\u@\h\[$white\]]\[$blue\](\A)\n\[$green\]$PWD\[$blue\]\$ \[$reset\]'
