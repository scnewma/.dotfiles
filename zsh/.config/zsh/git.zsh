source ~/.nix-profile/share/fzf-git/fzf-git.sh

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
