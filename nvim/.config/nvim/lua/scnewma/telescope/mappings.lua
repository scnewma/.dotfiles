local map = function(key, tele_fn, options, buffer)
    local mode = "n"
    local rhs = string.format(
        "<cmd>lua require('scnewma.telescope')['%s'](%s)<CR>",
        tele_fn,
        options
    )

    local opts = {
        noremap = true,
        silent = true,
    }

    vim.api.nvim_set_keymap(mode, key, rhs, opts)
end

-- dotfiles
map('<leader>fe', 'edit_dotfiles')

-- files
map('<leader>ff', 'find_files')
map('<leader>fg', 'git_files')
map('<leader><space>', 'find_files_prefer_git')
map('<leader>fb', 'file_browser')

-- buffers
map('<leader>bb', 'buffers')

-- search
-- live_grep has too many performance problems on larger projects because
-- it's attempting to execute rg for every keypress. until some debounce or
-- min character support is added i will just do non-live grepping
-- (:roosad:)
-- map('<leader>sp', 'live_grep')
map('<leader>sp', 'grep_string_prompt')
map('<leader>ss', 'current_buffer_fuzzy_find')
map('<leader>sc', 'command_history')
map('<leader>:', 'commands')
map('<leader>sh', 'help_tags')
map('<leader>tc', 'colorscheme')
map('<leader>lst', 'treesitter')
map('<leader>lsd', 'lsp_document_symbols')
