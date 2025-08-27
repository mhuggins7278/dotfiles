#
zmodload zsh/zprof
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

# Add in zsh plugins - defer heavy ones for faster startup
zinit ice wait"1" lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait"1" lucid
zinit light zsh-users/zsh-completions

zinit ice wait"1" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# Load vim-mode without wait to avoid key binding issues
zinit ice wait"1" lucid light softmoth/zsh-vim-mode


# Load completions
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-1) ]]; then
  compinit -i -C
else
  compinit -i
fi
autoload -U +X bashcompinit && bashcompinit

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


# Cache GOPATH to avoid expensive go env call
_go_path_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gopath"
if [[ ! -f "$_go_path_cache" ]] || [[ $(which go) -nt "$_go_path_cache" ]]; then
  go env GOPATH > "$_go_path_cache"
fi
GOPATH=$(cat "$_go_path_cache")/bin
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
# Cache expensive eval commands for faster startup
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_cache_dir"

_fzf_cache="$_cache_dir/fzf.zsh"
if [[ ! -f "$_fzf_cache" ]] || [[ /opt/homebrew/bin/fzf -nt "$_fzf_cache" ]]; then
  fzf --zsh > "$_fzf_cache"
fi
source "$_fzf_cache"

_zoxide_cache="$_cache_dir/zoxide.zsh"
if [[ ! -f "$_zoxide_cache" ]] || [[ /opt/homebrew/bin/zoxide -nt "$_zoxide_cache" ]]; then
  zoxide init zsh > "$_zoxide_cache"
fi
source "$_zoxide_cache"

_fnm_cache="$_cache_dir/fnm.zsh"
if [[ ! -f "$_fnm_cache" ]] || [[ /opt/homebrew/bin/fnm -nt "$_fnm_cache" ]]; then
  fnm env --shell zsh > "$_fnm_cache"
fi
source "$_fnm_cache"

source $HOME/.dotfiles/shellrc
# Cache glgroup bashcomplete
_glgroup_cache="$_cache_dir/glgroup.bash"
if [[ ! -f "$_glgroup_cache" ]] || [[ $(which glgroup) -nt "$_glgroup_cache" ]]; then
  glgroup bashcomplete > "$_glgroup_cache" 2>/dev/null || touch "$_glgroup_cache"
fi
[[ -s "$_glgroup_cache" ]] && source "$_glgroup_cache"
# zprof

# Docker CLI completions (remove duplicate compinit)
fpath=(/Users/MHuggins/.docker/completions $fpath)
# Terraform completion
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Added by Windsurf
export PATH="/Users/MHuggins/.codeium/windsurf/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
