but completions fish | source

function __but_branch_list
    but branch list --json 2>/dev/null | jq -r '
        [.appliedStacks[].heads[].name] as $applied
        | ($applied[] | [., "applied"]),
          (.branches[] | select([.name] | inside($applied) | not) | [.name, ""])
        | @tsv
    '
end

function fzf_but_branches
    set -l branch (__but_branch_list | fzf \
        --height=40% \
        --border \
        --delimiter='\t' \
        --with-nth=1,2 \
        --header="Select but branch" \
        --preview 'but branch show {1}' | cut -f1)

    if test -n "$branch"
        commandline -it -- "$branch"
    end
    commandline -f repaint
end

