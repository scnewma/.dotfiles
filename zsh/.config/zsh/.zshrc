# Allow comments in interactive shells
setopt INTERACTIVE_COMMENTS

# Print all options (inc. on/off) when calling `setopt'
setopt KSH_OPTION_PRINT

# Options/traps set inside of functions are reverted upon completion
setopt LOCAL_OPTIONS LOCAL_TRAPS

# Allow parameter expansion within the prompt
setopt PROMPT_SUBST

# Share history between all sessions
setopt SHARE_HISTORY

# Adds command execution timestamp and runtime to history
setopt EXTENDED_HISTORY

# Expire duplicate commands before unique events
setopt HIST_EXPIRE_DUPS_FIRST

# Do not add command to history if it repeats the previous command
setopt HIST_IGNORE_DUPS

# Duplicate commands expire older commands
setopt HIST_IGNORE_ALL_DUPS

# Do not display duplicates when searching history
setopt HIST_FIND_NO_DUPS

# Do not put commands in history if they begin with a SPACE
setopt HIST_IGNORE_SPACE

# Omit old history commands when they duplicate new commands
setopt HIST_SAVE_NO_DUPS

# Rewrite output redirections so they are valid to repeat. Allows you to
# execute `echo "test" > file' and then repeat command because the history entry
# is written as `echo "test" >| file'
setopt HIST_ALLOW_CLOBBER

# Trim excessive whitespace from commands before adding to history
setopt HIST_REDUCE_BLANKS

# Disable beep when scrolling past history boundaries
setopt NO_HIST_BEEP

# No beeping when ZLE encounters an error
setopt NO_BEEP

# cd into directories without typing cd
setopt AUTO_CD

# allow cd into named directories directly (without ~)
setopt CDABLEVARS

# cd behaves like pushd; directory stack ftw!
setopt AUTO_PUSHD

# do not save duplicates to the directory stack
setopt PUSHD_IGNORE_DUPS

# Use vi key bindings
setopt VI
# remove all keybindings with ESC as a prefix so that ESC doesn't have a prefix
# delay.
# bindkey -rpM viins '\e'
# use standard delete backward to avoid vim functionaly where backspace doesn't
# remove characters before the insertion point. this mode should be equivalent
# to vim's `set backspace=indent,eol,start'
bindkey -v '^?' backward-delete-char
# more standard vi behavior for deleting to beginning of line instead of to
# last insertion point
bindkey -M viins '^U' backward-kill-line
# push line into buffer stack for later execution
bindkey -M viins '^Y' push-line-or-edit
bindkey -M vicmd '^Y' push-line-or-edit

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${ZDOTDIR}/.zsh_history"

# only keep unique entries in path
typeset -U path

# autoload all functions in $ZDOTDIR/functions
fpath=( "$ZDOTDIR/functions" "${fpath[@]}" )
autoload -Uz $fpath[1]/*(.:t)

eval "$(starship init zsh)"

PROFILE_DIR="$HOME/.nix-profile"

# add some commonly used named directories
hash -d dot="$HOME/.dotfiles"
hash -d zdot="$HOME/.dotfiles/zsh/.config/zsh"
hash -d nvdot="$HOME/.dotfiles/nvim/.config/nvim"
hash -d dev="$HOME/dev"

autoload -Uz +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --no-ignore"
export FZF_DEFAULT_OPTS='--bind ctrl-y:preview-up,ctrl-e:preview-down,left:toggle+up,right:toggle+down'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
eval "$(fzf --zsh)"

source "$PROFILE_DIR/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^n' autosuggest-accept

# change default home-manager config path since home-manager doesn't like it's
# directly being symlinked
export HOME_MANAGER_CONFIG="$HOME/.dotfiles/home-manager/home.nix"

export JJ_CONFIG="$HOME/.dotfiles/jj/config"

# allow ctrl-z to toggle between suspend and resume
function suspend-resume() {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
}
zle -N suspend-resume
bindkey "^z" suspend-resume

source "$ZDOTDIR/aliases.zsh"

export GOPATH=~/go/
path=($path ${GOPATH}bin)

if (( $+commands[nvim] )); then
    alias vim=nvim
fi

if command -v kubectl >/dev/null; then
    source "$PROFILE_DIR/share/kubectl-aliases/.kubectl_aliases"
    source <(kubectl completion zsh)
    source "$ZDOTDIR/kubernetes.zsh"
fi

if (( $+commands[terraform] )); then
    complete -o nospace -C $(which terraform) terraform
fi

[ -d "$HOME/dev/bin" ] && path=("$HOME/dev/bin" $path)
[ -d "$HOME/bin" ] && path=("$HOME/bin" $path)
[ -d "$HOME/.cargo/bin" ] && path=($path "$HOME/.cargo/bin")
[ -d "$HOME/.deno/bin" ] && path=($path "$HOME/.deno/bin")
path=("$HOME/.nix-profile/bin" $path)

if [ -d "$HOME/.deno" ]; then
  export DENO_INSTALL="$HOME/.deno"
  path=("$DENO_INSTALL/bin" $path)
fi

if [ -f ~/.config/op/plugins.sh ]; then
    source ~/.config/op/plugins.sh
fi

source "$ZDOTDIR/git.zsh"
source "$ZDOTDIR/sgen.zsh"

source "$PROFILE_DIR/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

eval "$(direnv hook zsh)"
[ -f "$HOME/.local/bin/mise" ] && eval "$($HOME/.local/bin/mise activate zsh)"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
export PATH
