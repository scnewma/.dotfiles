##################################################
#                    EXPORTS                     #
##################################################
if command -v go > /dev/null; then
    export GOBIN=$HOME/go/bin
    export GOPATH=$(go env GOPATH)

    export PATH="$PATH:$(go env GOPATH)/bin"
fi

export VISUAL=vim
export EDITOR="$VISUAL"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# enable color output for ls, grep, etc
export CLICOLOR=1

export DOCKER_HIDE_LEGACY_COMMANDS=true

##################################################
#                       PS1                      #
##################################################
function git_branch {
    if git rev-parse --git-dir >/dev/null 2>&1
        then echo -e " [$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')]"
    else
        echo ""
    fi
}

NO_COLOR="\033[0m"
RED="\033[0;31m"
CYAN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PINK="\033[0;35m"

function git_color {
    local STATUS=`git status 2>&1`
    if [[ "$STATUS" == *'Not a git repository'* ]]
        then echo ""
    else
    if [[ "$STATUS" != *'working directory clean'* ]]
        then
        # red if need to commit
        echo -e "$RED"
    else
    if [[ "$STATUS" == *'Your branch is ahead'* ]]
        then
        # yellow if need to push
        echo -e "$YELLOW"
    else
        # else cyan
        echo -e "$CYAN"
    fi
    fi
    fi
}

export PS1="$USER \[$BLUE\]\W/\[\$(git_color)\]\$(git_branch) \[$PINK\]\n--|\[$NO_COLOR\] "

##################################################
#                      ALIASES                   #
##################################################
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias ll='ls -alF'
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

if [ -f ~/.bash_profile.local ]; then
    source ~/.bash_profile.local
fi

export PATH="$HOME/.cargo/bin:$PATH"
