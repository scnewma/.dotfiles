function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cn forward-char
    end

    for mode in insert default
        bind -M $mode alt-b,alt-b fzf_but_branches
    end
end

