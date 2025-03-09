# GitHub repository selector function (from sgen.zsh)
function __select_github_repository
    sgen gh --template='{{.nameWithOwner}}' \
        | fzf --height 50% --min-height 20 --border --multi --prompt "repo> " --preview "gh repo view {-1}"
    
    # Return the exit status of the pipe
    return $status
end

function fzf-sgen-github-repos-widget
    set -l result (__select_github_repository)
    if test $status -eq 0
        commandline -i $result
    end
    commandline -f repaint
end

bind \cg\cg fzf-sgen-github-repos-widget
