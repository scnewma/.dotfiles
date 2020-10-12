set -x VISUAL vim
set -x EDITOR $VISUAL
set -x HOMEBREW_AUTO_UPDATE_SECS 86400

if status --is-interactive
    abbr -ag c clear

    abbr -ag v vim

    # directory navigation
    abbr -ag cd.. cd ..
    abbr -ag .. cd ..
    abbr -ag ... cd ../..
    abbr -ag dot $HOME/.dotfiles
    abbr -ag dev $HOME/dev

    # kubectl
    abbr -ag k kubectl
    abbr -ag kn kubectl -n 
    abbr -ag kctx kubectx
    abbr -ag kns kubens

    # git
    abbr -ag gs git status -s

    # docker
    abbr -ag d docker

    abbr -ag dc docker container 
    abbr -ag dcl docker container ls
    abbr -ag dcla docker container ls
    abbr -ag dclg docker container logs
    abbr -ag dcr docker container run
    abbr -ag dcs docker container start
    abbr -ag dcst docker container stop
    abbr -ag dcsta docker container stop \(docker container ls -a -q\)
    abbr -ag dcrm docker container rm
    abbr -ag dcrma docker container rm \(docker container ls -a -q\)
    
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
    abbr -ag dcomlg docker-compose logs
    abbr -ag dcomlgf docker-compose logs -f
end

set -x PATH $PATH /usr/local/go/bin
if type -q go
    set -x GOBIN $HOME/go/bin
    set -x GOPATH (go env GOPATH)
    set -x PATH $PATH (go env GOPATH)/bin
end

if test -f /usr/local/opt/ruby/bin/ruby
    set -x PATH /usr/local/opt/ruby/bin $PATH
end

if test -f $HOME/.config/fish/config.fish.local
    source $HOME/.config/fish/config.fish.local
end

if test -d $HOME/.emacs.d/bin
    set -x PATH $PATH $HOME/.emacs.d/bin
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shaun/google-cloud-sdk/path.fish.inc' ]; . '/Users/shaun/google-cloud-sdk/path.fish.inc'; end

# create new base session and connect if one
# is not available.
# do not do this if in IntelliJ
# if not set -q TMUX; and not set -q IDEA 
#     set -g TMUX tmux new-session -d -s base
#     eval $TMUX
#     tmux attach-session -d -t base
# end

set -x PATH $PATH $HOME/.cargo/bin
