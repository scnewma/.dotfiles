function git-branch-current
    # Displays the current Git branch.
    # Fish adaptation of https://github.com/scnewma/prezto/blob/master/modules/git/functions/git-branch-current
    
    if not command git rev-parse 2>/dev/null
        echo "$_ not a repository: $PWD" >&2
        return 1
    end
    
    set -l ref (command git symbolic-ref HEAD 2>/dev/null)
    
    if test -n "$ref"
        echo (string replace 'refs/heads/' '' $ref)
        return 0
    else
        return 1
    end
end