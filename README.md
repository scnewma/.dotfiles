# dotfiles

## Usage

Setup with Nix. The below commands are ordered so that all of the `.config` directories are symlinked before installing tools so there are no conflicts.

```
sh <(curl -L https://nixos.org/nix/install)
nix-shell -p git --command 'git clone https://github.com/scnewma/.dotfiles.git ~/.dotfiles'
cd ~/.dotfiles
nix-shell -p stow --command 'stow bat gh git home-manager karabiner kitty nix nvim starship tmux zsh'
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
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
