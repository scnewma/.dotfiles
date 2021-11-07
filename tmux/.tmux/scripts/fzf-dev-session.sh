#!/bin/bash

# create a tmux session from a $HOME/dev directory
#   provide $1 to go straight there (without $HOME/dev prefix)
#   execute alone to have fzf fuzzy find a project in $HOME/dev

if [ ! -z "$1" ]; then
    # if a directory is provided, verify it's existence in $HOME/dev
    dir="$HOME/dev/$1"
    if [ ! -d "$dir" ]; then
        echo "directory not found: $dir"
        return 1
    fi
else
    # no directory provided, prompt user to fuzzy find one
    dir="$(
        find "$HOME/dev" -type d -maxdepth 1 -mindepth 1 -print 2>/dev/null \
            | fzf-tmux -p +m --header='Select project to open.' \
                --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
    )" || return
fi

# new/attach tmux session
~/.tmux/scripts/dir-session.sh "$dir" || return
