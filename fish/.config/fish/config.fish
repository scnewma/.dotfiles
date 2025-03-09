set -x VISUAL nvim
set -x EDITOR $VISUAL
set -x HOMEBREW_AUTO_UPDATE_SECS 86400

source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"

if status --is-interactive
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
    
    # tmux
    if type -q tmux
        abbr -ag t ~/.tmux/scripts/dir-session.sh
        abbr -ag td ~/.tmux/scripts/fzf-dev-session.sh
    end
    
    # terraform
    if type -q terraform
        abbr -ag tf terraform
    end
    
    # ls/exa/eza
    if type -q eza
        alias ls "eza --icons"
        alias exa "eza --icons"
        abbr -ag exag eza --icons --long --git --git-ignore
        abbr -ag tree eza --icons --tree
    end
    
    # nix
    if type -q home-manager
        abbr -ag home-manager nix run home-manager/master --
    end

    # kubectl
    if type -q kubectl
        abbr -ag k kubectl
        abbr -ag kn kubectl -n 
        abbr -ag kctx kubectx
        abbr -ag kns kubens
    end

    # git
    abbr -ag g git
    abbr -ag gs git status -s
    
    abbr -ag gb git branch -vv
    abbr -ag gbd git branch -d
    abbr -ag gbD git branch -D
    
    abbr -ag gcom "git checkout (git-main-branch)"
    abbr -ag gcb git checkout -b
    abbr -ag grs git restore
    abbr -ag grss git restore --staged
    
    abbr -ag gc git commit -v
    abbr -ag gca git commit -v --amend
    abbr -ag gcan git commit -v --amend --no-edit
    abbr -ag gcm git commit -m
    
    abbr -ag gd git diff
    abbr -ag gdca git diff --cached
    
    abbr -ag glg git log --stat --max-count=10
    abbr -ag glo git log --oneline --decorate --color
    
    abbr -ag gl git pull
    abbr -ag gp git push
    abbr -ag ggp "git push origin (git-branch-current 2>/dev/null)"
    abbr -ag gpu "git push -u origin (git-branch-current 2>/dev/null)"
    abbr -ag gpuf "git push --force-with-lease origin (git-branch-current 2>/dev/null)"
    
    abbr -ag gsta git stash
    abbr -ag gstd git stash drop
    abbr -ag gstp git stash pop
    
    abbr -ag ga git add
    abbr -ag gaa git add --all
    abbr -ag grm git rm
    abbr -ag grmca git rm --cached
    
    abbr -ag gcl git clone
    abbr -ag gf git fetch
    abbr -ag gm git merge
    abbr -ag grh git reset HEAD
    abbr -ag grhh git reset HEAD --hard
    abbr -ag gst git status
    abbr -ag gclean git clean -di
    
    # gh cli
    if type -q gh
        abbr -ag gpr gh pr create --fill --draft
    end

    # docker
    abbr -ag d docker

    abbr -ag dc docker container 
    abbr -ag dcl docker container ls
    abbr -ag dcla docker container ls -a
    abbr -ag dclo docker container logs
    abbr -ag dclg docker container logs
    abbr -ag dcr docker container run
    abbr -ag dcs docker container start
    abbr -ag dcst docker container stop
    abbr -ag dcsta "docker container stop (docker container ls -a -q)"
    abbr -ag dcrm docker container rm
    abbr -ag dcrma "docker container rm (docker container ls -a -q)"
    
    abbr -ag di docker image
    abbr -ag dil docker image ls
    abbr -ag dib docker image build
    abbr -ag dit docker image tag
    abbr -ag dip docker image push

    abbr -ag dr docker run
    abbr -ag drd docker run -d

    abbr -ag dl docker pull
    abbr -ag dp docker push

    abbr -ag dcom docker-compose
    abbr -ag dcomu docker-compose up
    abbr -ag dcomud docker-compose up -d
    abbr -ag dcomudb docker-compose up -d --build
    abbr -ag dcomd docker-compose down
    abbr -ag dcomlo docker-compose logs -f
    abbr -ag dcomlg docker-compose logs
    abbr -ag dcomlgf docker-compose logs -f

    abbr -ag jl jj git fetch
    abbr -ag jp jj git push
    abbr -ag jp@ jj git push -c @
    abbr -ag jc jj commit
    abbr -ag jf jj diff
    abbr -ag jd jj describe
    abbr -ag jdm jj describe -m
    abbr -ag je jj edit
    abbr -ag jlg jj log
    abbr -ag jrs jj restore
    abbr -ag jsh jj show
    abbr -ag jsp jj split
    abbr -ag jsq jj squash
    abbr -ag jst jj status
    abbr -ag jb jj bookmark
    abbr -ag jbm "jj bookmark set (jj-main-bookmark)"
    abbr -ag jbmp "jj bookmark set (jj-main-bookmark); and jj git push -b (jj-main-bookmark)"
end

# Environment variables from zsh
set -x AWS_PAGER "" # disable AWS cli paging
set -x MANPAGER "nvim +Man! -" # use nvim as the man pager
set -x CHROME_PROFILE_LOCATION "/Users/$USER/Library/Application Support/BraveSoftware/Brave-Browser/Default"
set -x GOKU_EDN_CONFIG_FILE "$HOME/.dotfiles/karabiner/karabiner.edn"

# FZF configuration
set -x FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND --no-ignore"
set -x FZF_DEFAULT_OPTS '--bind ctrl-y:preview-up,ctrl-e:preview-down,left:toggle+up,right:toggle+down --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'

# Home manager configuration
set -x HOME_MANAGER_CONFIG "$HOME/.dotfiles/home-manager/home.nix"

# JJ version control
set -x JJ_CONFIG "$HOME/.dotfiles/jj/config"
COMPLETE=fish jj | source

# Deno
if test -d "$HOME/.deno"
    set -x DENO_INSTALL "$HOME/.deno"
    fish_add_path "$DENO_INSTALL/bin"
end

# Homebrew setup (from zsh)
if test -d "/opt/homebrew/bin"
    eval (/opt/homebrew/bin/brew shellenv)
end

# Path additions
if type -q go
    set -x GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

if test -d $HOME/.emacs.d/bin
    fish_add_path $HOME/.emacs.d/bin
end

if type -q cargo
    fish_add_path $HOME/.cargo/bin
end

# Add user bin paths
test -d $HOME/dev/bin && fish_add_path $HOME/dev/bin
test -d $HOME/bin && fish_add_path $HOME/bin

# Add nix-profile to path if not already there
test -d $HOME/.nix-profile/bin && fish_add_path $HOME/.nix-profile/bin

# Allow ctrl-z to toggle between suspend and resume
function suspend-resume --description "Toggle between foreground and background"
    if status is-interactive
        if test -z (jobs)
            echo "No background jobs running"
            commandline -f repaint
        else
            fg
        end
    end
end

# GitHub repository selector function (from sgen.zsh)
function __select_github_repository
    sgen gh --template='{{.nameWithOwner}}' \
        | fzf --height 50% --min-height 20 --border --multi --prompt "repo> " --preview "gh repo view {-1}"
    
    # Return the exit status of the pipe
    return $status
end

function fzf-sgen-github-repos-widget
    set -l result (__select_github_repository)
    if test $status -eq 0
        commandline -i $result
    end
    commandline -f repaint
end

# Bind Ctrl+G Ctrl+G to the GitHub repo selector
if status is-interactive
    bind \cz suspend-resume
    bind \cg\cg fzf-sgen-github-repos-widget
end

fzf --fish | source

# Load local config if it exists
if test -f $HOME/.config/fish/config.fish.local
    source $HOME/.config/fish/config.fish.local
end

if type -q mise
    ~/.local/bin/mise activate fish | source
end

# Initialize direnv if available
if type -q direnv
    direnv hook fish | source
end

# starship init fish | source
