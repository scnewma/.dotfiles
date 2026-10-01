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


function fzf_but_changes
    set -l ids (but status --json 2>/dev/null | jq -r '
        .. | objects | select(has("cliId") and has("filePath")) | ({added: "32", deleted: "31", modified: "33"}[.changeType] // "35") as $c
        | ["\\u001b[34m\(.cliId)\\u001b[0m", "\\u001b[\($c)m\(.changeType)\\u001b[0m", .filePath] | @tsv
    ' | fzf --multi --ansi \
        --height=60% \
        --border \
        --delimiter='\t' \
        --header="Select changes (tab to multi-select)" \
        --preview 'CLICOLOR_FORCE=1 but diff {1}' \
        --preview-window=right,60% | cut -f1)

    if test -n "$ids"
        commandline -it -- (string join " " $ids)
    end
    commandline -f repaint
end

function bship -d "Commit straight to the target branch via a throwaway branch"
    set -l branch sn-ship-(date +%s)
    but commit -b $branch $argv && but land $branch --yes
end
