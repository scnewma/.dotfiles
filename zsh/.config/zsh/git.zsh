source ~/.local/share/fzf-git/fzf-git.sh

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

git-commit-generate-message() {
    INSTRUCTION_FILE=$(mktemp)
    COMMIT_MSG_FILE=$(mktemp)

    # Write markdown instructions to temp file
    cat > "$INSTRUCTION_FILE" << 'EOF'
# Task

Generate a commit message for the following git diff. Do not use conventional commits format (e.g., feat:, fix:, docs:, etc.). Keep it concise and focus on WHAT changed and WHY.

DO NOT output any other information about the generation, only the commit message itself. Surround the commit message in Markdown code blocks (```) to make it easily parsable.

# Git Diff

```diff
EOF

    # Append the git diff for staged changes
    git diff --cached >> "$INSTRUCTION_FILE"

    # Close the diff code block
    echo '```' >> "$INSTRUCTION_FILE"

    # First strip all ANSI codes, then find content between code blocks
    goose run -i "$INSTRUCTION_FILE" | sed 's/\x1b\[[0-9;]*[mGK]//g' | awk '/^```$/{p=!p;next} p{print}' > "$COMMIT_MSG_FILE"

    git commit --template="$COMMIT_MSG_FILE"

    # Clean up
    rm "$INSTRUCTION_FILE"
    rm "$COMMIT_MSG_FILE"
}

# --- Aliases
alias g='git'

alias gb='git branch -vv'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gcom='git checkout $(git-main-branch)'
alias gcb='git checkout -b'
alias grs='git restore'
alias grss='git restore --staged'

alias gc='git commit -v'
alias gca='git commit -v --amend'
alias gcan='gca --no-edit'
alias gcm='git commit -m'

alias gd='git diff'
alias gdca='git diff --cached'

alias glg='git log --stat --max-count=10'
alias glo='git log --oneline --decorate --color'

alias gl='git pull'
alias gp='git push'
alias ggp='git push origin "$(git-branch-current 2> /dev/null)"'
alias gpu='ggp --set-upstream'
alias gpuf='gpu --force'

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

alias gpr='gh pr create --fill --draft'
