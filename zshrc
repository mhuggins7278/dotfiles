zmodload zsh/zprof

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.local/share/oh-my-zsh

# Which plugins would you like to load?
# See https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
plugins=(git z asdf fzf)

source $ZSH/oh-my-zsh.sh

# History file settings
HISTFILE=~/.local/share/zsh/zsh_history
setopt NO_HIST_VERIFY
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

source $HOME/.dotfiles/shellrc

case "$(uname -s)" in
    Linux)
        # Load grc
        [[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
        ;;
    Darwin)
        # Load grc
        [[ -s "`brew --repository`/etc/grc.zsh" ]] && source "`brew --repository`/etc/grc.zsh"
        # Load Homebrew Command Not Found
        HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
        if [ -f "$HB_CNF_HANDLER" ]; then
            source "$HB_CNF_HANDLER";
        fi
        ;;
esac

# pnpm
export PNPM_HOME="/Users/MHuggins/Library/pnpm"
GOPATH=`go env GOPATH`/bin
export PATH="$PNPM_HOME:$PATH$GOPATH"
# pnpm end

source <(glgroup bashcomplete)

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add default node to path
export PATH=~/.nvm/versions/node/v18.13.0/bin:$PATH

# Load NVM
export NVM_DIR=~/.nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"

# export PATH="$PATH:~/usr/local/share/dotnet"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
zprof
