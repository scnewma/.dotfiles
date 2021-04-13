export ZDOTDIR="$HOME/.config/zsh"
export AWS_PAGER="" # disable AWS cli paging
if type nvim >/dev/null 2>&1; then
    export EDITOR="nvim"

    # use nvim as the man pager
    export MANPAGER="nvim -c 'set ft=man' -"
fi
