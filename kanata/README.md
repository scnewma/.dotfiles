# kanata

## Installation

1. Install binary

```
cargo install kanata
```

2. Setup LaunchDaemons

```
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl enable system/com.example.kanata.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl enable system/com.example.karabiner-vhiddaemon.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist
sudo launchctl enable system/com.example.karabiner-vhidmanager.plist
```

3. Start LaunchDaemons

```
sudo launchctl start com.example.kanata
sudo launchctl start com.example.karabiner-vhiddaemon
sudo launchctl start com.example.karabiner-vhidmanager
```

4. Enable input monitoring for `~/.cargo/bin/kanata`

Navigate to your System Settings > Privacy & Security > Input Monitoring

## Links

- https://github.com/jtroo/kanata
- https://github.com/jtroo/kanata/discussions/1537
- https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
