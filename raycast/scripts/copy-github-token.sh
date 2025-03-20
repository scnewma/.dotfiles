#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy GitHub Token
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon data:image/png;base64,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
# @raycast.packageName .dotfiles

export PATH="$HOME/.nix-profile/bin:$PATH"

gh auth token | pbcopy

echo "GitHub token copied to clipboard"
