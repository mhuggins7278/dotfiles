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

# Add in zsh plugins - defer all for faster startup
zinit ice wait"0a" lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait"0b" lucid
zinit light zsh-users/zsh-completions

zinit ice wait"0c" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"0d" lucid
zinit light Aloxaf/fzf-tab

# Load vim-mode with minimal delay, then rebind Ctrl-R to fzf
zinit ice wait"0" lucid atload"bindkey '^R' fzf-history-widget"
zinit light softmoth/zsh-vim-mode


# Load completions - check cache age (rebuild daily)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i
else
  compinit -i -C
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
# Cache brew prefix
_brew_prefix_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/brew_prefix"
if [[ ! -f "$_brew_prefix_cache" ]]; then
  brew --prefix > "$_brew_prefix_cache"
fi
_brew_prefix=$(cat "$_brew_prefix_cache")

# Deduplicate PATH entries
typeset -U path
path=( 
$path
$GOPATH
$PNPM_HOME
"$_brew_prefix/opt/curl/bin"
$HOME/.local/bin
$HOME/.local/share
)
# Source completion files
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH"


function launch_sesh() {
  sesh connect "$(
    sesh list -ti | fzf-tmux -p 55%,60% \
      --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
      --reverse \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~/github)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list -t)'
  )"
}

# Cache expensive eval commands for faster startup
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_cache_dir"

_fzf_cache="$_cache_dir/fzf.zsh"
if [[ ! -f "$_fzf_cache" ]] || [[ /opt/homebrew/bin/fzf -nt "$_fzf_cache" ]]; then
  fzf --zsh > "$_fzf_cache"
fi
source "$_fzf_cache"

# Override fzf-history-widget to use centered popup
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_R_OPTS-}" \
    fzf-tmux -p 55%,60% --border-label ' History ' --prompt '🔍  ' --query "$LBUFFER") )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history-widget

_zoxide_cache="$_cache_dir/zoxide.zsh"
if [[ ! -f "$_zoxide_cache" ]] || [[ /opt/homebrew/bin/zoxide -nt "$_zoxide_cache" ]]; then
  zoxide init zsh > "$_zoxide_cache"
fi
source "$_zoxide_cache"

# fnm setup - cache disabled to prevent version leaking
# Problem: fnm creates a multishell directory per shell that symlinks to ~/.local/share/fnm/aliases/default
# When caching, old multishell paths in the cache would still point to the shared default alias,
# causing Node versions to leak between shells
# Solution: Evaluate fnm directly each time (small performance cost but prevents version leaking)
eval "$(fnm env --shell zsh --resolve-engines)"

source $HOME/.dotfiles/shellrc

# Ensure Ctrl+R uses fzf for history search (after all plugins loaded)
bindkey '^R' fzf-history-widget

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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/MHuggins/.lmstudio/bin"
# End of LM Studio CLI section

