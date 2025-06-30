# dotfiles

## Usage

The below commands are ordered so that all of the `.config` directories are symlinked before installing tools so there are no conflicts.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/scnewma/.dotfiles.git ~/.dotfiles
brew bundle install --file=~/.dotfiles/homebrew/.homebrew/Brewfile
cd ~/.dotfiles
stow bat gh git karabiner kitty nix nvim starship tmux zsh
exec fish
```

If you are doing any Rust development:

```
rustup component add rust-analyzer
```

If you are doing any Go development:

```
go install golang.org/x/tools/gopls@latest
```

Base MacOS settings:

```
~/.dotfiles/.macos
```

After generating a keypair:

```
git remote set-url origin git@github.com:scnewma/.dotfiles.git
```

## Enable TouchID for `sudo` on mac

In `/etc/pam.d/sudo_local`:

```
auth     optional       /opt/homebrew/lib/pam/pam_reattach.so
auth     sufficient     pam_tid.so
```
