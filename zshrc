# zmodload zsh/zprof
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.local/share/oh-my-zsh
NVM_HOMEBREW=$(brew --prefix nvm)

# Which plugins would you like to load?
# See https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
plugins=(gh vi-mode fzf grc starship zoxide nvm)


# Lazy Load NVM
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:update' frequency 14


source $ZSH/oh-my-zsh.sh

# if [ "$(find ~/.zcompdump -mtime +1)" ] ; then
#     compinit
# fi
# compinit -C

# History file settings
HISTFILE=~/.local/share/zsh/zsh_history
setopt NO_HIST_VERIFY
setopt APPEND_HISTORY                   # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS             # don't record dupes in history
setopt HIST_REDUCE_BLANKS

source $HOME/.dotfiles/shellrc


# pnpm
export PNPM_HOME="/Users/MHuggins/Library/pnpm"
GOPATH=$(go env GOPATH)/bin
export PATH="$PNPM_HOME:$PATH:$GOPATH"
# pnpm end

source <(glgroup bashcomplete)

export BAT_THEME="Solarized (dark)"
# Add default node to path
export PATH=~/.nvm/versions/node/v18.13.0/bin:$PATH

# zprof
