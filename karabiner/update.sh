#!/bin/bash

set -e

cue export --all-errors karabiner.cue > .config/karabiner/karabiner.json
