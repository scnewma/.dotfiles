#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search nixpkgs
# @raycast.mode silent
# @raycast.argument1 { "type": "text", "placeholder": "package" }
#
# Optional parameters:
# @raycast.icon https://camo.githubusercontent.com/f6f812a57fc746f0ddf22c708e18280d5334fd20a57823c285784faea4c632f5/68747470733a2f2f6e69786f732e6f72672f6c6f676f2f6e69786f732d6c6f676f2d6f6e6c792d68697265732e706e67
# @raycast.packageName .dotfiles

open "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=$1"
