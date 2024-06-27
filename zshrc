# zmodload zsh/zprof
# Path to your oh-my-zsh configuration.
OH_MY_ZSH=$HOME/.local/share/oh-my-zsh
NVM_HOMEBREW=$(brew --prefix nvm)

# Which plugins would you like to load?
# See https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
plugins=(gh vi-mode fzf starship zoxide nvm)


# Lazy Load NVM
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:update' frequency 7 
zstyle ':completion:*' use-cache on
zstyle ':completion:*' menu select


source $OH_MY_ZSH/oh-my-zsh.sh


# History file settings
HISTFILE=~/.local/share/zsh/zsh_history
setopt NO_HIST_VERIFY
setopt APPEND_HISTORY                   # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS             # don't record dupes in history
setopt HIST_REDUCE_BLANKS

source $HOME/.dotfiles/shellrc


export BAT_THEME="Solarized (dark)"
export PNPM_HOME="/Users/MHuggins/Library/pnpm"
GOPATH=$(go env GOPATH)/bin
path=( 
$path
$GOPATH
$PNPM_HOME
# "~/.nvm/versions/node/v18.13.0/bin"
"$(brew --prefix)/opt/curl/bin"
)

# Source completion files
source <(glgroup bashcomplete)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# zprof
