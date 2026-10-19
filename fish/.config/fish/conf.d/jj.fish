set -x JJ_CONFIG "$HOME/.dotfiles/jj/config"
COMPLETE=fish jj | source

function fzf_jj_bookmarks
    set -l bookmark (jj bookmark list --template 'name ++ "\n"' 2>/dev/null | fzf \
        --height=40% \
        --border \
        --header="Select jj Bookmark" \
        --preview 'jj show {}')

    if test -n "$bookmark"
        commandline -it -- "$bookmark"
    end
    commandline -f repaint
end
# alt-j-b
bind -M insert ∆∫ fzf_jj_bookmarks
