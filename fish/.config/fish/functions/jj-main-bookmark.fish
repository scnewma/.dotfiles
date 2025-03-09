function jj-main-bookmark
    set -l main_bookmark "main"
    set -l fallback_bookmark "master"
    set -l bookmarks (jj bookmark list)
    if echo "$bookmarks" | string match -q "*$main_bookmark:*"
        echo "$main_bookmark"
    else if echo "$bookmarks" | string match -q "*$fallback_bookmark:*"
        echo "$fallback_bookmark"
    else
        echo "Neither 'main' nor 'master' bookmark found."
        return 1
    end
end
