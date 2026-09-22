if status --is-interactive && type -q kubectl
    kubectl completion fish | source
end
