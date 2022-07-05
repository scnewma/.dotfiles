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

if [[ -n $KITTY_INSTALLATION_DIR ]]; then
    export KITTY_SHELL_INTEGRATION="no-rc no-cursor"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

eval "$(starship init zsh)"

# add some commonly used named directories
hash -d dot="$HOME/.dotfiles"
hash -d zdot="$HOME/.dotfiles/zsh/.config/zsh"
hash -d nvdot="$HOME/.dotfiles/nvim/.config/nvim"

autoload -Uz +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

PROFILE_DIR="$HOME/.nix-profile"
export FZF_DEFAULT_OPTS='--bind ctrl-y:preview-up,ctrl-e:preview-down,left:toggle+up,right:toggle+down'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --no-ignore"
source "$PROFILE_DIR/share/fzf/key-bindings.zsh"
source "$PROFILE_DIR/share/fzf/completion.zsh"

source "$PROFILE_DIR/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^n' autosuggest-accept

source "$PROFILE_DIR/share/kubectl-aliases/.kubectl_aliases"

# allow ctrl-z to toggle between suspend and resume
function suspend-resume() {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
}
zle -N suspend-resume
bindkey "^z" suspend-resume

function cd-project() {
    dir="$(fd --max-depth 1 --type d . $HOME/dev \
        | fzf --preview="${FZF_PREVIEW_CMD}" \
        --preview-window="right:hidden:wrap")"

    zle push-line # clear buffer. restored on next prompt
    BUFFER="builtin cd -- ${(q)dir}"
    if [ ! -z "$TMUX" ]; then
        win_name=$(basename ${(q)dir}) # only keep dir name
        win_name="${win_name#cloud-}"  # trim "cloud-" prefix if any
        BUFFER="$BUFFER && tmux rename-window ${win_name}"
    fi
    BUFFER="$BUFFER && clear"
    zle accept-line
    local ret=$?
    unset dir win_name # ensure this doesn't end up appearing in prompt expansion
    zle reset-prompt
    return $ret
}
zle -N cd-project
bindkey "\ep" cd-project

alias zrc="vim ~zdot/.zshrc"
alias zrclocal="vim ~/.zshrc.local"

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

path=($path /usr/local/go/bin)
if (( $+commands[go] )); then
    export GOPATH=~/go/
    path=($path "/usr/local/go/bin" ${GOPATH}bin)
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
[ -d "$HOME/.cargo/bin" ] && path=($path "$HOME/.cargo/bin")

export PATH

source "$ZDOTDIR/git.zsh"
source "$ZDOTDIR/kubernetes.zsh"

[ -f /usr/local/opt/asdf/libexec/asdf.sh ] && source /usr/local/opt/asdf/libexec/asdf.sh

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

source "$PROFILE_DIR/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

source "$PROFILE_DIR/etc/profile.d/hm-session-vars.sh"
eval "$(direnv hook zsh)"
