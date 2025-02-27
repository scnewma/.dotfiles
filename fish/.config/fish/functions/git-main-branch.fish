function git-main-branch
    # Determines the main branch of a git repository
    command git rev-parse --git-dir &>/dev/null; or return
    
    for ref in refs/heads/{main,trunk} refs/remotes/{origin,upstream}/{main,trunk}
        if command git show-ref -q --verify $ref
            echo (string replace -r '^.*/(.*)$' '$1' $ref)
            return
        end
    end
    
    echo master
end