#!/usr/bin/env zsh

# Local Vars && Aliases
if [ -f "${HOME}/.dotfiles-private/zsh-local-vars.zsh" ]; then
    source "${HOME}/.dotfiles-private/zsh-local-vars.zsh"
fi

if [ -f "${HOME}/.dotfiles-private/zsh-private-aliases.zsh" ]; then
    source "${HOME}/.dotfiles-private/zsh-private-aliases.zsh"
fi

# Better history
export HISTSIZE=1000
export HISTFILE=~/.zhistory
setopt HIST_IGNORE_ALL_DUPS
setopt inc_append_history
setopt share_history

# Don't change terminal names
DISABLE_AUTO_TITLE="true"

_myos=$(uname)

# Setup OS-Specific variables and bash_completion
if [ $_myos = "Darwin" ]; then
    # running on macOS - setup brew & completion
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH
    # Disable homrew analytics (https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md)
    export HOMEBREW_NO_ANALYTICS=1
    export BYOBU_PREFIX
    BYOBU_PREFIX=$(brew --prefix) || true
    export BREW_PREFIX
    BREW_PREFIX=$(brew --prefix) || true
fi

# Initialize Antigen
if [ -f "${HOME}/.dotfiles-public/antigen.zsh" ]; then
    source "${HOME}/.dotfiles-public/antigen.zsh"
    antigen use oh-my-zsh
    antigen bundle git
    antigen bundle command-not-found
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle gmatheu/zsh-plugins explain-shell
    antigen bundle docker
    if [ $_myos = "Darwin" ]; then
        antigen bundle osx
    fi
    antigen apply
fi

# Auto-Suggestions
if [ -f  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Common variables
if [ -f /usr/local/bin/vim ]; then
    export EDITOR=/usr/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi

# General Aliases
alias ls='ls -F --color'
alias dir='ls -lF --color'
alias txl='tmux ls'
alias txn='tmux new -s'
alias txa='tmux a -t'
alias myip='curl ipv4.icanhazip.com'
alias myip4='curl ipv4.icanhazip.com'
alias myip6='curl ipv6.icanhazip.com'
alias ipify='curl -s https://api.ipify.org'
alias header='curl -I'
alias df='df -H'
alias du='du -ch'
alias fix_tty='stty sane'
alias cmount='mount | column -t'
alias sha256='openssl dgst -sha256'

# Docker/Container TOP
alias ctop='docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock jinnlynn/ctop'

# macOS-specific Aliases & functions
if [ $_myos = "Darwin" ]; then
    # What's keeping the Mac from sleeping?
    alias nosleep="pmset -g assertions"

    # Mute & unmute from CLI
    alias mute="osascript -e 'set volume output muted true'"
    alias unmute="osascript -e 'set volume output muted false'"

    # colorize ls output on macOS
    alias ls='ls -GF'
    alias dir='ls -lGF'

    # Long running CLI command?  Tack ";lmk" onto the end
    alias lmk="say 'Process complete.'"

    # cleanupDS: recursively delete .DS_Store files
    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

    # Brew
    alias bupd="brew -v update"
    alias bupg="brew -v upgrade"
    alias bclean="brew cleanup"

    # MTR
    alias mtr='sudo mtr -e -o LSR NABWV'

    # vim
    alias gvim='open -a MacVim'

    # Mac IP Info
    alias localip='ipconfig getifaddr en0'
    alias ipinfo='ipconfig getpacket en0'

    # PowerCLI Core
    alias powercli='docker run --rm -it -v ~/.local/powerclicore:/tmp/scripts vmware/powerclicore'

    # functions
    # ii:
    # display useful host related informaton
    ii() {
        echo -e "\\nYou are logged on ${RED}$HOST"
        echo -e "\\nAdditionnal information:$NC " ; uname -a
        echo -e "\\n${RED}Users logged on:$NC " ; w -h
        echo -e "\\n${RED}Current date :$NC " ; date
        echo -e "\\n${RED}Machine stats :$NC " ; uptime
        echo -e "\\n${RED}Current network location :$NC " ; scselect
        echo -e "\\n${RED}Public facing IP Address :$NC " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }

    # trash
    trash () {
        command mv "$@" ~/.Trash
    }

    # Mac showing generic icons for stuff? Clear the icon cache
    # and start over.
    clearIconCache () {
        sudo rm -rfv /Library/Caches/com.apple.iconservices.store
        sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -or -name com.apple.iconservices \) -exec rm -rfv {} \;
        sleep 3
        sudo touch /Applications/*
        killall Dock
        killall Finder
    }
fi

# Linux-specific aliases and OS functions
if [ $_myos = "Linux" ]; then
    # Docker nvidia info
    alias nvinfo='docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi'
    alias pitemp='head -n 1 /sys/class/thermal/thermal_zone0/temp | xargs -I{} awk "BEGIN {printf \"%.2f\n\", {}/1000}"'
fi


# Useful functions
# extract: Extract most know archives with one command
extract () {
    if [ -f "$1" ] ; then
      case $1 in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.xz)    xzcat "$1" | tar xvf - ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar e "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# zipf: To create a ZIP archive of a folder
zipf () { zip -r "$1".zip "$1" ; }

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

    local tmp
	tmp=$(echo -e "GET / HTTP/1.0\\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText
		certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

lazygit () {
    local message=$*
    git add .
    git commit -a -m "$message"
    git push
}

# shortcut to find a process
psa () {
    ps auxww | grep "$1"
}

# Show HTTP headers
httpHeaders () {
    /usr/bin/curl -I -L "$@"
}

# Prompt

# export PROMPT="
# %F{white}[ %F{green}%n%F{blue} @ %F{green}%m%F{white} ]%F{blue}(%T)
# %F{yellow}%/%F{blue}%#%f "

# export PROMPT="
# $FG[255][ $FG[002]%n $FG[012]@ $FG[002]%m $FG[255]] $FG[021]%S%s$BG[021] $FG[255]%B(%T) %b$FG[021]
# $FG[226]%/$FG[012]%#%{$reset_color%} "

# OS-specific header
if [ $_myos = "Darwin" ]; then
    PRE=' '
elif [ $_myos = "Linux" ]; then
    PRE=' '
else
    PRE=' '
fi


PROMPT="
$BG[255]$FG[001] $PRE$BG[021]$FG[255]$FG[255]  %n @ %m  $FG[021]%k
$BG[021]$FG[255]%B%D{%H:%M} %b$FG[021]$BG[093]$FG[255] %~ %# $FG[093]%k %f"


# Git RPROMPT
if [ -f ${HOME}/.dotfiles-public/zsh-gitprompt.zsh ]; then
    export GIT_PROMPT_EXECUTABLE=python
    source ${HOME}/.dotfiles-public/zsh-gitprompt.zsh

    ZSH_THEME_GIT_PROMPT_PREFIX="$FG[021] $BG[021] "
    ZSH_THEME_GIT_PROMPT_SUFFIX=" $BG[093]%k%f"
    ZSH_THEME_GIT_PROMPT_SEPARATOR="$BG[021]|$BG[093] "
    ZSH_THEME_GIT_PROMPT_BRANCH="$FG[255]"
    ZSH_THEME_GIT_PROMPT_STAGED="$FG[001]%{●%G%}"
    ZSH_THEME_GIT_PROMPT_CONFLICTS="$FG[001]%{ %G%}"
    ZSH_THEME_GIT_PROMPT_CHANGED="$FG[255]$BG[093]%{ %G%}"
    ZSH_THEME_GIT_PROMPT_BEHIND="$BG[021] %{ %G%}"
    ZSH_THEME_GIT_PROMPT_AHEAD="$BG[021] %{ %G%}"
    ZSH_THEME_GIT_PROMPT_UNTRACKED="$BG[093]%{ %G%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="$FG[082]$BG[093]%{ %G%} "

    RPROMPT='$(git_super_status)'
fi
