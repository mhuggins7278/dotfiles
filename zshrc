# zmodload zsh/zprof
# Path to your oh-my-zsh configuration.
NVM_HOMEBREW=$(brew --prefix nvm)
export NVM_LAZY=1
source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm


# History file settings
HISTFILE=~/.local/share/zsh/zsh_history
setopt NO_HIST_VERIFY
setopt APPEND_HISTORY                   # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS             # don't record dupes in history
setopt HIST_REDUCE_BLANKS

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
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $HOME/.dotfiles/shellrc

# The following lines were added by compinstall

zstyle ':completion:*' use-cache on
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _expand _complete _ignored
zstyle :compinstall filename '/Users/MHuggins/.zshrc'
# autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;
# End of lines added by compinstall
# source <(glgroup bashcomplete)
# zprof
