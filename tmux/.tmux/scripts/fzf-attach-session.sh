#!/bin/bash

# displays list of all tmux sessions in a fzf-tmux popup window
# current session is added to end of list (instead of beginning) since you
# most likely don't want to switch to it

current_session=$(tmux display-message -p "#S")
sessions=$(tmux list-sessions -F "#S" | grep -v "^$current_session")
session=$(printf "%s\n$current_session (attached)" "$sessions" \
    | fzf-tmux -p)
if [ -z $session ]; then
    exit
fi

tmux switch-client -t "$session"
