function uv --description 'Wrapper for uv that auto-generates .envrc on init'
    if test "$argv[1]" = "init"
        command uv $argv
        and begin
            if command -q direnv
                echo "layout uv" > .envrc
                direnv allow
                echo "Created .envrc and allowed direnv"
            end
        end
    else
        command uv $argv
    end
end
