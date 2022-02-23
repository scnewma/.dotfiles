#!/bin/bash

set -e

repo_root=$(git rev-parse --show-toplevel)

cd $repo_root
cue export --all-errors karabiner/karabiner.cue > karabiner/.config/karabiner/karabiner.json

# karabiner sometimes overwrites the file on the filesystem which destroys the
# symlink. restore it in case that happened
rm ~/.config/karabiner/karabiner.json
stow karabiner
