# Public dotfiles

I clone this and a corresponding repo with "private" stuff to a couple of directories in my home directory, like say ".dotfiles-public" and ".dotfiles-private", then I'll symlink the various files into my home directory.

For the bash config, I'll add something like this to my ~/.bash_profile:

```bash
if [ -f ${HOME}/.dotfiles-public/bash-customizations.sh ]; then
    # shellcheck source=$HOME/.dotfiles-public/bash-customizations.sh
    source ${HOME}/.dotfiles-public/bash-customizations.sh
fi
```
