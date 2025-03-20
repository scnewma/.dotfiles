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

type -q terraform && abbr -ag tf terraform

if type -q eza
    alias ls "eza --icons"
    alias exa "eza --icons"
    abbr -ag exag eza --icons --long --git --git-ignore
    abbr -ag tree eza --icons --tree
end

# kubectl
if type -q kubectl
    abbr -ag k kubectl
    abbr -ag kn kubectl -n
    abbr -ag kctx kubectx
    abbr -ag kns kubens
end

abbr -ag g git
abbr -ag gs git status -s
abbr -ag gst git status

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
abbr -ag gclean git clean -di

type -q gh && abbr -ag gpr gh pr create --fill --draft

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
