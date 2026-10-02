# dotfiles

## Usage

The below commands are ordered so that all of the `.config` directories are symlinked before installing tools so there are no conflicts.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/scnewma/.dotfiles.git ~/.dotfiles
/opt/homebrew/bin/brew bundle install --file=~/.dotfiles/homebrew/.homebrew/Brewfile
cd ~/.dotfiles
./scripts/stow.sh
exec fish
```

To link selected packages, run `./scripts/stow.sh pi fish`.

The wrapper creates real `~/.pi/agent/skills` parent directories, links dotfiles-owned
skills, and leaves links into `~/.agents/skills` to the skills installer. Install
those skills separately with your usual `npx skills` commands.

If `~/.pi`, `~/.pi/agent`, or `~/.pi/agent/skills` is already a symlink, migrate it
to a real directory first, preserving runtime data and recreating installer links
with targets relative to their new location. Then run the wrapper.

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
