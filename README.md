# dotfiles

## Usage

The below commands are ordered so that all of the `.config` directories are symlinked before installing tools so there are no conflicts.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/scnewma/.dotfiles.git ~/.dotfiles
/opt/homebrew/bin/brew bundle install --file=~/.dotfiles/homebrew/.homebrew/Brewfile
cd ~/.dotfiles
/opt/homebrew/bin/stow bat gh git kitty nvim pi starship tmux zsh
exec fish
```

Make `fish` the default shell:

```
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

> You will need to re-log for this to take effect.

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
