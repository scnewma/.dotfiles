#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/kmonad"

sudo mkdir -p /var/kmonad

sudo cp $DIR/apple.kmonad.plist /Library/LaunchDaemons/apple.kmonad.plist
sudo cp $DIR/apple.kbd /var/kmonad/apple.kbd
sudo cp $DIR/apple-kmonad-startup.sh /var/kmonad/apple-kmonad-startup.sh
# sed -e "s@%DIR%@$DIR@g" <$DIR/kmonad/apple.kmonad.plist >/Library/LaunchDaemons/apple.kmonad.plist
