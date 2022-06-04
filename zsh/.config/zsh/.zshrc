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

source "$ZDOTDIR/external/powerlevel10k/powerlevel10k.zsh-theme"
source "$ZDOTDIR/.p10k.zsh"

# add some commonly used named directories
hash -d zdot="$HOME/.dotfiles/zsh/.config/zsh"
hash -d nvdot="$HOME/.dotfiles/nvim/.config/nvim"

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

autoload -Uz bashcompinit
bashcompinit

if [[ -s "$HOME/.fzf/bin/fzf" ]]; then
    path=("$HOME/.fzf/bin" $path)
fi

export FZF_DEFAULT_OPTS='--bind ctrl-y:preview-up,ctrl-e:preview-down,left:toggle+up,right:toggle+down'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --no-ignore"
source "$ZDOTDIR/external/fzf/shell/key-bindings.zsh"
source "$ZDOTDIR/external/fzf/shell/completion.zsh"

source "$ZDOTDIR/external/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^n' autosuggest-accept

if [[ -f "$ZDOTDIR/external/kubectl-aliases/.kubectl_aliases" ]]; then
    source "$ZDOTDIR/external/kubectl-aliases/.kubectl_aliases"
fi

# allow ctrl-z to toggle between suspend and resume
function suspend-resume() {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
}
zle -N suspend-resume
bindkey "^z" suspend-resume

alias zrc="vim ~zdot/.zshrc"

alias c=' clear'
alias clear=' clear'

alias d='docker'

alias dc='docker container'
alias dcl='docker container ls'
alias dclo='docker container logs'
alias dcr='docker container run'

alias di='docker image'
alias dil='docker image ls'
alias dib='docker image build'
alias dit='docker image tag'
alias dip='docker image push'

alias dcom='docker-compose'
alias dcomu='docker-compose up'
alias dcomud='docker-compose up -d'
alias dcomudb='docker-compose up -d --build'
alias dcomd='docker-compose down'
alias dcomlo='docker-compose logs -f'

alias t='~/.tmux/scripts/dir-session.sh'
alias td='~/.tmux/scripts/fzf-dev-session.sh'
alias tdot='t $HOME/.dotfiles'

alias tf='terraform'

alias ls='exa --icons'
alias exa='exa --icons'
alias exag='exa --icons --long --git --git-ignore'
alias tree='exa --icons --tree'

if (( $+commands[go] )); then
    export GOPATH=~/go/
    path=("/usr/local/go/bin" $path ${GOPATH}bin)
fi

if (( $+commands[nvim] )); then
    alias vim=nvim
fi

if (( $+commands[kubectl] )); then
    source <(kubectl completion zsh)
fi

if (( $+commands[terraform] )); then
    complete -o nospace -C /usr/local/bin/terraform terraform
fi

[ -d "$HOME/dev/bin" ] && path=("$HOME/dev/bin" $path)
[ -d "/usr/local/kubebuilder/bin" ] && path=($path "/usr/local/kubebuilder/bin")

export PATH

source "$ZDOTDIR/git.zsh"
source "$ZDOTDIR/kubernetes.zsh"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

source "$ZDOTDIR/external/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
