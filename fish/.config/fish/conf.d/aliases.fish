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
    alias ls "eza --icons=auto"
    alias exa "eza --icons=auto"
    abbr -ag exag eza --icons=auto --long --git --git-ignore
    abbr -ag tree eza --icons=auto --tree
end

# kubectl
if type -q kubectl
    if test -f "$HOME/.local/share/kubectl-aliases/.kubectl_aliases.fish"
        source "$HOME/.local/share/kubectl-aliases/.kubectl_aliases.fish"
    end
    abbr -ag kctx kubectx
    abbr -ag kns kubens
end

function gh-pull-request-abbr
    # gh always looks for templates in ./.github so we need to make sure we are
    # in the root of the git repo
    if test "$(git root)" != "$PWD"
        set -f cd "cd $(git root); and "
    end
    # note: `test -f` is case insensitive on mac to match os behavior
    if test -f (git root)"/.github/pull_request_template.md"
        set -f template --template pull_request_template.md
    end

    echo $cd "gh pr create --draft --editor $template"
end
type -q gh && abbr -ag gpr --function gh-pull-request-abbr

type -q claude && abbr -ag cld "claude --allowedTools 'Bash(git:*),Bash(find:*),Bash(rg:*),Edit,Write'"

abbr -ag sonnet pi --model 'claude-sonnet-5' --thinking medium
abbr -ag opus pi --model 'claude-opus-5' --thinking medium
abbr -ag fable pi --model 'claude-fable-5' --thinking high
abbr -ag sol pi --model 'gpt-5.6-sol' --thinking high
abbr -ag terra pi --model 'gpt-5.6-terra' --thinking high
abbr -ag luna pi --model 'gpt-5.6-luna' --thinking high
