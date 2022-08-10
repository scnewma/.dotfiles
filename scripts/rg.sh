#!/bin/bash

set -e

if [ -f .ripgreprc ]; then
    RIPGREP_CONFIG_PATH=".ripgreprc"
else
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -f "${git_root}/.ripgreprc" ]; then
        RIPGREP_CONFIG_PATH="${git_root}/.ripgreprc"
    fi
fi

RIPGREP_CONFIG_PATH="$RIPGREP_CONFIG_PATH" rg "$@"
