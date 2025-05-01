set -x JJ_CONFIG "$HOME/.dotfiles/jj/config"
COMPLETE=fish jj | source

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
abbr -ag jbs jj bookmark set
abbr -ag jbm "jj bookmark set -r @ (jj-main-bookmark)"
abbr -ag jbmp "jj bookmark set -r @ (jj-main-bookmark); and jj git push -b (jj-main-bookmark)"
abbr -ag jn jj new
abbr -ag jnm "jj new (jj-main-bookmark)"
