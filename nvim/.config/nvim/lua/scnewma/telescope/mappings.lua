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
map('<leader>sp', 'live_grep')
map('<leader>sP', 'grep_string_prompt')
map('<leader>sw', 'grep_string')
map('<leader>ss', 'current_buffer_fuzzy_find')
map('<leader>sc', 'command_history')
map('<leader>:', 'commands')
map('<leader>sh', 'help_tags')
map('<leader>tc', 'colorscheme')
map('<leader>lst', 'treesitter')
map('<leader>lsd', 'lsp_document_symbols')
