alias c "printf '\e[H\e[22J'"

abbr -ag rc nvim $HOME/.config/fish/config.fish
abbr -ag rclocal nvim $HOME/.config/fish/config.fish.local
abbr -ag tmuxrc nvim $HOME/.tmux.conf

abbr -ag v vim
alias vim nvim
alias scratch "nvim +'setlocal buftype=nofile bufhidden=wipe noswapfile'"

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

abbr -ag sonnet pi --model 'claude-sonnet-5' --thinking low
abbr -ag opus pi --model 'claude-opus-5' --thinking low

function '?' --description 'Start a context-free Pi session'
    set -l temp_dir (mktemp -d)
    or return 1

    set -l original_dir $PWD
    cd $temp_dir
    or begin
        command rm -rf -- $temp_dir
        return 1
    end

    command pi --model claude-opus-5 --thinking low --no-context-files --no-session -- $argv
    set -l pi_status $status

    cd $original_dir
    command rm -rf -- $temp_dir
    return $pi_status
end

function pi-openai
    if not test -f "$PI_OPENAI_MCP_CONFIG"
        echo "OpenAI MCP config missing" >&2
        return 1
    end

    command pi --mcp-config "$PI_OPENAI_MCP_CONFIG" $argv
end

abbr -ag fable pi --model 'claude-fable-5' --thinking medium
abbr -ag astra pi-openai --model 'gpt-6-astra' --thinking medium
abbr -ag sol pi-openai --model 'gpt-6-sol' --thinking medium
abbr -ag terra pi-openai --model 'gpt-5.6-terra' --thinking medium
abbr -ag luna pi-openai --model 'gpt-6-luna' --thinking medium
abbr -ag pi-up "mise up pi@latest; and pi update --extensions"
