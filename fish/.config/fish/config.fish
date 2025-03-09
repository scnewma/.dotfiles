if not status --is-interactive
    return
end

source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"

set -x VISUAL nvim
set -x EDITOR $VISUAL
set -x HOMEBREW_AUTO_UPDATE_SECS 86400

set -x AWS_PAGER "" # disable AWS cli paging
set -x MANPAGER "nvim +Man! -" # use nvim as the man pager

# PATH languages
type -q go fish_add_path $GOPATH/bin
type -q cargo && fish_add_path $HOME/.cargo/bin
test -d "$HOME/.deno" && fish_add_path "$DENO_INSTALL/bin"

# PATH package managers
test -d "/opt/homebrew/bin" && eval (/opt/homebrew/bin/brew shellenv)
test -d $HOME/.nix-profile/bin && fish_add_path $HOME/.nix-profile/bin

# PATH personal scripts
test -d $HOME/dev/bin && fish_add_path $HOME/dev/bin
test -d $HOME/bin && fish_add_path $HOME/bin

# Load local config if it exists
if test -f $HOME/.config/fish/config.fish.local
    source $HOME/.config/fish/config.fish.local
end

if type -q mise
    ~/.local/bin/mise activate fish | source
end

if type -q direnv
    direnv hook fish | source
end
