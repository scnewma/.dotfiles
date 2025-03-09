set -x FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND --no-ignore"
set -x FZF_DEFAULT_OPTS '--bind ctrl-y:preview-up,ctrl-e:preview-down,left:toggle+up,right:toggle+down --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
fzf --fish | source
