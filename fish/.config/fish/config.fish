if not status --is-interactive
    return
end

fish_vi_key_bindings

set -x VISUAL nvim
set -x EDITOR $VISUAL
set -x HOMEBREW_AUTO_UPDATE_SECS 86400

set -x AWS_PAGER "" # disable AWS cli paging
set -x MANPAGER "nvim +Man! -" # use nvim as the man pager

set -x FZF_DEFAULT_OPTS "--bind 'ctrl-y:preview-down,ctrl-e:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up'"

# PATH languages
type -q go fish_add_path $GOPATH/bin
type -q cargo && fish_add_path $HOME/.cargo/bin
test -d "$HOME/.deno" && fish_add_path "$DENO_INSTALL/bin"

# PATH package managers
test -d "$HOME/.local/bin" && fish_add_path $HOME/.local/bin

# PATH personal scripts
test -d $HOME/dev/bin && fish_add_path $HOME/dev/bin
test -d $HOME/bin && fish_add_path $HOME/bin

# Load local config if it exists
if test -f $HOME/.config/fish/config.fish.local
    source $HOME/.config/fish/config.fish.local
end

if type -q mise
    mis=(which mise) mise activate fish | source
end

if type -q direnv
    direnv hook fish | source
end
