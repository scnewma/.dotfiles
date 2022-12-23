#!/bin/bash

set -euo pipefail

URL="$(gum input --placeholder 'clone url...')"
(cd "$HOME/dev"; git clone "$URL")

dir="$HOME/dev/$(basename -s .git "$URL")"
window_name="$(basename "${dir}" | sed 's/\./_/g')"
tmux new-window -c "${dir}" -n "${window_name}"
