#!/usr/bin/env bash

if [ -f "${HOME}"/.dotfiles-private/bash-local-vars.sh ]; then
    # shellcheck source="${HOME}"/.dotfiles-private/bash-local-vars.sh
    source "${HOME}"/.dotfiles-private/bash-local-vars.sh
fi

if [ -f "${HOME}"/.dotfiles-private/bash-private-aliases.sh ]; then
    # shellcheck source="${HOME}"/.dotfiles-private/bash-private-aliases.sh
    source "${HOME}"/.dotfiles-private/bash-private-aliases.sh
fi

# Better history
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTIGNORE="ls:pwd:exit"

# variables
_myos=$(uname)
_myuid=$(id -u)
_mygid=$(id -g)

# Setup OS-Specific variables and bash_completion


if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    # shellcheck source=/etc/bash_completion
    source /etc/bash_completion
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
alias dir='ls -lF'
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
alias ctop='docker run --rm -ti --name=ctop-tmp -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest'

# Docker Youtube Downloader
alias yt-dl="docker run --rm -i -e PUID=$_myuid -e PGID=$_mygid -v $(pwd):/workdir:rw mikenye/youtube-dl"

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
bold=$(tput bold)
white=$(tput setaf 7)
red=$(tput setaf 1)
blue=$(tput setaf 4)
green=$(tput setaf 2)
#magenta=$(tput setaf 5)
reset=$(tput sgr0)

export PS1='\[$bold\]\n\[$white\][\[$red\]\u@\h\[$white\]]\[$blue\](\A)\n\[$green\]$PWD\[$blue\]\$ \[$reset\]'
