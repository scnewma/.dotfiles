function fish_vcs_prompt --description "Print all vcs prompts"
    fish_jj_prompt $argv
    or fish_git_prompt $argv
end
