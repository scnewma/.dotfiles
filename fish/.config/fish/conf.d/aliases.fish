alias c clear

abbr -ag rc nvim $HOME/.config/fish/config.fish
abbr -ag rclocal nvim $HOME/.config/fish/config.fish.local
abbr -ag tmuxrc nvim $HOME/.tmux.conf

abbr -ag v vim
alias vim nvim

# directory navigation
abbr -ag cd.. cd ..
abbr -ag .. cd ..
abbr -ag ... cd ../..
abbr -ag dot $HOME/.dotfiles
abbr -ag dev $HOME/dev
abbr -ag tdot tmux new-session -c $HOME/.dotfiles

if type -q eza
    alias ls "eza --icons"
    alias exa "eza --icons"
    abbr -ag exag eza --icons --long --git --git-ignore
    abbr -ag tree eza --icons --tree
end

# kubectl
if type -q kubectl
    source "$HOME/.local/share/kubectl-aliases/.kubectl_aliases.fish"
    abbr -ag kctx kubectx
    abbr -ag kns kubens
end

type -q gh && abbr -ag gpr gh pr create --fill --draft --template (git root)/.github/pull_request_template.md

type -q claude && abbr -ag cld "claude --allowedTools 'Bash(git:*),Bash(find:*),Bash(rg:*),Edit,Write'"
