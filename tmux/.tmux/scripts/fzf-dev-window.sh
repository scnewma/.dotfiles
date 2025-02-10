#!/bin/bash

# select any project from ~/dev and adds the ~/.dotfiles directory
dir="$(
    (fd . -d1 -td "${HOME}/dev"; echo "${HOME}/.dotfiles") \
        | fzf-tmux -p '90%' --header='Select project.')"

[ -z "${dir}" ] && exit 0

window_name="$(basename "${dir}" | sed 's/\./_/g')"
tmux new-window -c "${dir}" -n "${window_name}"
