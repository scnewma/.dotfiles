function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cn forward-char
    end
    fzf_key_bindings
end

