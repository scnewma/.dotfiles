# Allow ctrl-z to toggle between suspend and resume
function suspend-resume --description "Toggle between foreground and background"
    if status is-interactive
        if test -z (jobs)
            echo "No background jobs running"
            commandline -f repaint
        else
            fg
        end
    end
end

bind \cz suspend-resume
