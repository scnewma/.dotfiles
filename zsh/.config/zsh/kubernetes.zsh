__select_kubernetes_resource() {
    kubectl get $1 -o name | cut -d'/' -f2 |
        __fzf_kubectl --prompt "$1> " --preview "kubectl get $1 {-1} -o yaml | bat --language=yaml --color=always --plain"
    local ret=$?
    echo
    return $ret
}

__fzf_kubectl() {
    fzf --height 50% --min-height 20 --border --multi "$@"
}

fzf-kubernetes-widget() {
    LBUFFER="${LBUFFER}$(__select_kubernetes_resource $1)"
    local ret=$?
    zle reset-prompt
    return $ret
}

# mapping of keybind characters to kubernetes resource
declare -A __kubernetes_fzf_widget_info
__kubernetes_fzf_widget_info[p]="pod"
__kubernetes_fzf_widget_info[d]="deployment"
__kubernetes_fzf_widget_info[s]="service"
__kubernetes_fzf_widget_info[i]="ingress"

# dynamically create zsh widgets for the above declared resources
for key resource in ${(kv)__kubernetes_fzf_widget_info}; do
    eval "fzf-kubernetes-$resource-widget() {fzf-kubernetes-widget $resource}"
    eval "zle -N fzf-kubernetes-$resource-widget"
    eval "bindkey '^k$key' fzf-kubernetes-$resource-widget"
done
