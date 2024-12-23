#
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light softmoth/zsh-vim-mode


# Load completions
autoload -Uz compinit 
autoload -U +X bashcompinit 
if [ "$(find ~/.zcompdump -mtime +1)" ]; then
    compinit
    bashcompinit
else
  compinit -C
  bashcompinit -C
fi

zinit cdreplay -q

# History file settings
HISTFILE=~/.local/share/zsh/zsh_history
# History
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


GOPATH=$(go env GOPATH)/bin
path=( 
$path
$GOPATH
$PNPM_HOME
"$(brew --prefix)/opt/curl/bin"
$HOME/.local/bin
$HOME/.local/share
)
# Source completion files
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH"


function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
session=$(sesh list -z | fzf \
  --height 60% \
  --reverse \
  --tmux \
  --border-label 'sesh' \
  --border \
  --prompt '⚡' \
  --header ' ^a all ^t tmux ^x zoxide ^f find' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(⚡)+reload(sesh list)' \
  --bind 'ctrl-t:change-prompt(🪟)+reload(sesh list -t)' \
  --bind 'ctrl-x:change-prompt(📁)+reload(sesh list -z)' \
  --bind 'ctrl-f:change-prompt(🔎)+reload(fd -H -d 3 -t d -E .Trash . ~/github/)'
)
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env --shell zsh)"

source $HOME/.dotfiles/shellrc
source <(glgroup bashcomplete)
# zprof

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
