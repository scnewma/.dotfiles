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
