__select_github_repository() {
    sgen gh --template='{{.nameWithOwner}}' \
        | fzf --height 50% --min-height 20 --border --multi --prompt "repo> " --preview "gh repo view {-1}"
    local ret=$?
    echo
    return $ret
}
fzf-sgen-github-repos-widget() {
    LBUFFER="${LBUFFER}$(__select_github_repository)"
    local ret=$?
    zle reset-prompt
    return $ret
}
zle -N fzf-sgen-github-repos-widget
bindkey '^g^g' fzf-sgen-github-repos-widget
