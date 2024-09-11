# dotfiles

## Usage

Setup with Nix. The below commands are ordered so that all of the `.config` directories are symlinked before installing tools so there are no conflicts.

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
nix run nixpkgs#git -- clone https://github.com/scnewma/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/nix-profile/
nix run .#profile.switch
cd ~/.dotfiles
nix run nixpkgs#stow -- stow bat gh git karabiner kitty nix nvim starship tmux zsh
exec zsh
```

If you are doing any Rust development:

```
rustup component add rust-analyzer
```

If you are doing any Go development:

```
go install golang.org/x/tools/gopls@latest
```

If you want the casks in `Brewfile`:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd ~/.dotfiles
brew bundle
```

Base MacOS settings:

```
~/.dotfiles/.macos
```

After generating a keypair:

```
git remote set-url origin git@github.com:scnewma/.dotfiles.git
```
