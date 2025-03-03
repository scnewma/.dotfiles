function fish_jj_prompt --description 'Write out the jj prompt'
    # Is jj installed?
    if not command -sq jj
        return 1
    end

    # Are we in a jj repo?
    if not jj root --quiet &>/dev/null
        return 1
    end

    # Generate prompt
    jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
      separate(" ",
        "  ",
        change_id.shortest(4),
        commit_id.shortest(4),
        bookmarks,
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
