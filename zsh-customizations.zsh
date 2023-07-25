#!/usr/bin/env zsh

# Local Vars && Aliases
if [ -f "${HOME}/.dotfiles-private/zsh-local-vars.zsh" ]; then
    source "${HOME}"/.dotfiles-private/zsh-local-vars.zsh
fi

if [ -f "${HOME}/.dotfiles-private/zsh-private-aliases.zsh" ]; then
    source "${HOME}"/.dotfiles-private/zsh-private-aliases.zsh
fi

# Better history
export HISTSIZE=1000
export HISTFILE=~/.zhistory
setopt HIST_IGNORE_ALL_DUPS
setopt inc_append_history
setopt share_history

# Don't change terminal names
DISABLE_AUTO_TITLE="true"

_myuid="$(id -u)"
_mygid="$(id -g)"
_hostname="$(hostname -s)"

# Am I running on a Synology NAS?
uname -a |grep synology > /dev/null
if [ $? -eq 0 ]; then
    _myos="synology"
else
    _myos="$(uname)"
fi

# Setup OS-Specific variables and bash_completion
if [ "$_myos" = "Darwin" ]; then
    # running on macOS - setup brew & completion
    # Intel macOS uses /usr/local for homebrew
    if [ -f "/usr/local/bin/brew" ]; then 
        export PATH=/usr/local/bin:/usr/local/sbin:$PATH
        export HAS_HOMEBREW=1
    fi
    # Apple Silicon macOS uses /opt/homebrew for homebrew
    if [ -f "/opt/homebrew/bin/brew" ]; then 
        export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
        export HAS_HOMEBREW=1
    fi
    if [ ${HAS_HOMEBREW} ]; then
        # export HOMEBREW_NO_ANALYTICS=1
        export BYOBU_PREFIX=$(brew --prefix) || true
        export BREW_PREFIX=$(brew --prefix) || true
    fi
fi

# Initialize Antigen
if [ -f "${HOME}"/.dotfiles-public/antigen.zsh ]; then
    source "${HOME}"/.dotfiles-public/antigen.zsh
    antigen use oh-my-zsh
    antigen theme romkatv/powerlevel10k
    antigen bundle command-not-found
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle genpass
    antigen bundle sudo
    if [ "$_myos" = "Darwin" ]; then
        antigen bundle macos
        antigen bundle brew
    fi
    if [ "$_myos" != "synology" ]; then
        antigen bundle fzf
        antigen bundle chucknorris
    fi
    antigen bundle aliases
    antigen apply
fi

# activate P10K variables
if [ -f "${HOME}"/.p10k.zsh ]; then
    source "${HOME}"/.p10k.zsh
fi

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
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
alias myip='curl https://ipv4.icanhazip.com'
alias myip4='curl https://ipv4.icanhazip.com'
alias myip6='curl https://ipv6.icanhazip.com'
alias ipify='curl -s https://api.ipify.org'
alias header='curl -I'
alias df='df -H'
alias du='du -ch'
alias fix_tty='stty sane'
alias cmount='mount | column -t'
alias sha256='openssl dgst -sha256'

# Docker/Container TOP
alias ctop='docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock jinnlynn/ctop'

# Docker Youtube Downloader
# alias yt-dl="docker run --rm -i -e PUID=""$_myuid"" -e PGID=""$_mygid"" -v $(pwd):/workdir:rw ghcr.io/mikenye/docker-youtube-dl:latest"

# Docker pull frequently updated containers unique to local system
docker-pull-locals() {
    containers=()
    while IFS= read -r line
    do
        containers+=("$line")
    done < "${HOME}"/.dotfiles-private/container-pulls/"$_hostname"
    
    for container in "${containers[@]}"
    do
        docker pull "${container}"
    done
}

# macOS-specific Aliases & functions
if [ "$_myos" = "Darwin" ]; then
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

    # Mac IP Info
    alias localip='ipconfig getifaddr en0'
    alias ipinfo='ipconfig getpacket en0'

    # PowerCLI Core
    alias powercli='docker run --rm -it -v ~/.local/powerclicore:/tmp/scripts vmware/powerclicore'

    # functions
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
if [ "$_myos" = "Linux" ]; then
    # Docker nvidia info
    alias nvinfo='docker run --rm --name=nvinfo --gpus all nvidia/cuda:11.7.0-base-ubuntu22.04 nvidia-smi'
    alias pitemp='head -n 1 /sys/class/thermal/thermal_zone0/temp | xargs -I{} awk "BEGIN {printf \"%.2f\n\", {}/1000}"'
fi

# functions using fzf, but only if fzf is installed
if [ -x "$(command -v fzf)" ]; then
    # fd - cd to selected directory
    fd() {
        local dir
        dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
        cd "$dir"
    }

    # fh - search in your command history and execute selected command
    fh() {
        eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
    }
fi

# Useful functions
# updatedots: Update my dotfiles from github
updatedots() {
    echo 'Public Dotfiles'; cd ~/.dotfiles-public ; git pull
    echo 'Private Dotfiles'; cd ~/.dotfiles-private ; git pull
    cd ~
    echo 'Update Antigen'; antigen selfupdate
    echo 'Update Antigen Modules'; antigen update
}

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
