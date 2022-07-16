export ZDOTDIR="$HOME/.config/zsh"
export AWS_PAGER="" # disable AWS cli paging
if (( $+commands[ls] )); then
    export EDITOR="nvim"

    # use nvim as the man pager
    export MANPAGER="nvim +Man! -"
fi
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

[ -d "/opt/homebrew/bin" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# used by `bh` and `bb` functions
export CHROME_PROFILE_LOCATION="/Users/$(whoami)/Library/Application Support/BraveSoftware/Brave-Browser/Default"

export GOKU_EDN_CONFIG_FILE="$HOME/.dotfiles/karabiner/karabiner.edn"
