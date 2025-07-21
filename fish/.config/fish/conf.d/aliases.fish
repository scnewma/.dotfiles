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

function gh-pull-request-abbr
    # note: `test -f` is case insensitive on mac to match os behavior
    if test -f (git root)"/.github/pull_request_template.md"
        echo "Using pull request template: $f"
        break
    end

    echo "cd (git root); and gh pr create --draft --editor $template"
end
type -q gh && abbr -ag gpr --function gh-pull-request-abbr

type -q claude && abbr -ag cld "claude --allowedTools 'Bash(git:*),Bash(find:*),Bash(rg:*),Edit,Write'"
