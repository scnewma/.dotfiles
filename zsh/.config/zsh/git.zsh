# Modification of: 
#  * https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

is-in-git-repo() {
    git rev-parse HEAD >/dev/null 2>&1
}

fzf-down() {
    fzf --height 50% --min-height 20 --border "$@"
}

# git files
_gf() {
    is-in-git-repo || return
    git -c color.status=always status --short |
        fzf-down --multi --ansi --nth 2..,.. \
            --preview '(git diff --color=always -- {-1})' |
        cut -c4- | sed 's/.* -> //'
}

# git branches
_gb() {
  is-in-git-repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# git tags
_gt() {
  is-in-git-repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

# git history (log)
_gh() {
  is-in-git-repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

# git stashes
_gs() {
  is-in-git-repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# --- Keybindings
join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

bind-git-helper() {
  local c
  for c in $@; do
    eval "fzf-g$c-widget() { local result=\$(_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}
bind-git-helper f b t r h s
unset -f bind-git-helper

git-main-branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}

# --- Aliases
alias g='git'

alias gb='git branch -vv'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gcom='git checkout $(git-main-branch)'
alias gcb='git checkout -b'
alias grs='git restore'

alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcm='git commit -m'

alias gd='git diff'
alias gdca='git diff --cached'

alias glg='git log --stat --max-count=10'
alias glo='git log --oneline --decorate --color'

alias gl='git pull'
alias gp='git push'
alias ggp='git push origin "$(git-branch-current 2> /dev/null)"'
alias gpu='ggp --set-upstream'

alias gsta='git stash'
alias gstd='git stash drop'
alias gstp='git stash pop'

alias ga='git add'
alias gaa='git add --all'
alias grm='git rm'
alias grmca='git rm --cached'

alias gcl='git clone'
alias gf='git fetch'
alias gm='git merge'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gst='git status'
alias gclean='git clean -di'
