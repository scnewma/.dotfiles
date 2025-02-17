#!/bin/bash

set -euo pipefail


sudo launchctl bootout system/com.example.kanata || true
sleep 1
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
