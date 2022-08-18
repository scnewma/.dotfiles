#!/bin/bash

set -euo pipefail

# select any project from ~/dev and adds the ~/.dotfiles directory
dir="$(
    (fd . -d1 -td "${HOME}/dev"; echo "${HOME}/.dotfiles") \
        | fzf-tmux -p --header='Select project.')"

[ -z "${dir}" ] && return 0

window_name="$(basename "${dir}" | sed 's/\./_/g')"
tmux new-window -c "${dir}" -n "${window_name}"
