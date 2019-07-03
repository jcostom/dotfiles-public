#!/usr/bin/env zsh

# Better history
export HISTSIZE=1000
export HISTFILE=~/.zhistory
setopt HIST_IGNORE_ALL_DUPS
setopt inc_append_history
setopt share_history
setopt auto_cd

# Initialize Completion
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi

# Initialize Prompt
autoload -Uz promptinit
promptinit

# package specific variables, OS independent
# cheat - https://github.com/chrisallenlane/cheat
export CHEATCOLORS=true

if [ -f "${HOME}/.dotfiles-private/zsh-local-vars.zsh" ]; then
    source "${HOME}/.dotfiles-private/zsh-local-vars.zsh"
fi

if [ -f "${HOME}/.dotfiles-private/zsh-private-aliases.zsh" ]; then
    source "${HOME}/.dotfiles-private/zsh-private-aliases.zsh"
fi

# variables
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

# Common variables
if [ -f /usr/local/bin/vim ]; then
    export EDITOR=/usr/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi

# General Aliases
alias dir='ls -lF'
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
alias nvim='/usr/local/bin/nvim -u ~/.vimrc'
alias sha256='openssl dgst -sha256'

# Docker/Container TOP
alias ctop='docker run --rm -ti --name=ctop-tmp -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest'

# macOS-specific Aliases & functions
if [ $_myos = "Darwin" ]; then
    # What's keeping the Mac from sleeping?
    alias nosleep="pmset -g assertions"

    # Mute & unmute from CLI
    alias mute="osascript -e 'set volume output muted true'"
    alias unmute="osascript -e 'set volume output muted false'"

    # colorize ls output on macOS
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

# Convert join.me's webm export format to 24fps MP4 with h264 video/aac audio
joinme2mp4 () {
    local infile=$1
    local outfile
    outfile=$(echo "$infile" | sed 's/webm$/mp4/')
    ffmpeg -y -i "$infile" -r 23.97 "$outfile"
}

lazygit () {
    local message=$*
    git add .
    git commit -a -m "$message"
    git push
}

# Create & enter a new directory
mcd () {
    mkdir -p "$1"
    cd "$1" ||exit
}

# shortcut to find a process
psa () {
    ps auxww | grep "$1"
}

# Show HTTP headers
httpHeaders () {
    /usr/bin/curl -I -L "$@"
}

# Convert 4k mkv to mp4, add tag for apple tv
mkv2mp4 () {
    local infile=$1
    local outfile
    outfile=$(echo "$infile" | sed 's/mkv$/mp4/')
    ffmpeg -i "$infile" -codec copy -vtag hvc1 -map 0:0 -map 0:1 "$outfile"
}

# Prompt

# export PROMPT="
# %F{white}[ %F{green}%n%F{blue} @ %F{green}%m%F{white} ]%F{blue}(%T)
# %F{yellow}%/%F{blue}%#%f "

export PROMPT="
%K{default}%F{white}[ %F{green}%n %F{blue}@ %F{green}%m %F{white}] %K{default}%F{blue}%S%s%K{blue} %F{black}%B(%T)%b %F{blue}%K{default}
%F{yellow}%/%F{blue}%#%f "

# export RPROMPT='[%F{yellow}%?%f]'

# Auto-Suggestions
if [ -f  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi