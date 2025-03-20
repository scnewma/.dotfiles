#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy GitHub Token
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon https://github.com/raycast/script-commands/blob/master/commands/developer-utils/github/images/github-logo.png?raw=true
# @raycast.packageName .dotfiles

export PATH="$HOME/.nix-profile/bin:$PATH"

gh auth token | pbcopy

echo "GitHub token copied to clipboard"
