function fish_jj_prompt --description 'Write out the jj prompt'
    if not command -sq jj
        return 1
    end

    if not jj root --quiet &>/dev/null
        return 1
    end

    set -l base (jj log --revisions 'coalesce(latest(heads((bookmarks() | remote_bookmarks()) & ::parents(@))), root())' --no-graph --ignore-working-copy --template 'commit_id ++ "\n" ++ coalesce(bookmarks.map(|b| b.name()).join("\n"), remote_bookmarks.map(|b| b.name()).join("\n"), "root") ++ "\n"')
    or return 1
    set base $base[1] (printf '%s\n' $base[2..] | sort -u | string join /)
    set -l trunk (jj log --revisions 'trunk()' --no-graph --ignore-working-copy --template 'coalesce(bookmarks.map(|b| b.name()).join("\n"), remote_bookmarks.map(|b| b.name()).join("\n"))' 2>/dev/null)
    set trunk (printf '%s\n' $trunk | sort -u | string join /)
    set -l path $base[2]
    if test -n "$trunk"
        set path "$trunk"
        if test "$base[2]" != root; and test "$base[2]" != "$trunk"
            set path "$path → $base[2]"
        end
    end

    set -l changes (jj log --revisions "$base[1]..@" --no-graph --ignore-working-copy --limit 2 --template 'change_id.shortest() ++ "\n"')
    or return 1
    if test (count $changes) -gt 1
        set path "$path … $changes[1]"
    else if test (count $changes) -eq 1
        set path "$path · $changes[1]"
    end

    printf '  %s ' "$path"
    jj log --revisions @ --no-graph --ignore-working-copy --color never --limit 1 --template '
      separate(" ",
        surround("[", "]", bookmarks),
        concat(
          if(conflict, "💥"),
          if(divergent, "🚧"),
          if(hidden, "👻"),
          if(immutable, "🔒"),
        ),
        raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
        raw_escape_sequence("\x1b[1;32m") ++ if(description.first_line().len() == 0,
          "(no description)",
          ""
        ) ++ raw_escape_sequence("\x1b[0m"),
      )
    '
end
