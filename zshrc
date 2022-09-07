# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"
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
export PATH="$PNPM_HOME:$PATH"
# pnpm end

source <(glgroup bashcomplete)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# bun completions
[ -s "/Users/MHuggins/.bun/_bun" ] && source "/Users/MHuggins/.bun/_bun"

# bun
export BUN_INSTALL="/Users/MHuggins/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"
