function auto-source --on-event fish_preexec -d 'auto source fish files if when modified!'
    set -q FISH_CONFIG_TIME
    if test $status -ne 0
        set -g FISH_CONFIG_TIME (date -u "+%s")
    else
        if fd --changed-after @$FISH_CONFIG_TIME --has-results . ~/.config/fish/**/
            for file in (fd --changed-after @$FISH_CONFIG_TIME . ~/.config/fish/**/)
                source $file
            end
            echo "[auto-source] Re-sourced fish config files." >&2
            set -g FISH_CONFIG_TIME (date -u "+%s")
        end
    end
end
