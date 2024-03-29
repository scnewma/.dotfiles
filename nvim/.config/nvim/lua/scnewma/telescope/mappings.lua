local nnoremap = require('scnewma.keymap').nnoremap

local map = function(lhs, tele_fn, options)
    -- use a closure here so that telescope is lazily loaded
    local rhs = function()
        require('scnewma.telescope')[tele_fn](options)
    end

    nnoremap { lhs, rhs, { silent = true } }
end

map('<leader>-', 'resume')

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
map('<leader>sf', 'live_grep_type')
map('<leader>sP', 'grep_string_prompt')
map('<leader>sw', 'grep_string')
map('<leader>ss', 'current_buffer_fuzzy_find')
map('<leader>s/', 'grep_last_search')
map('<leader>sk', 'keymaps')
map('<leader>sm', 'man_pages')
map('<leader>sc', 'command_history')
map('<leader>:', 'commands')
map('<leader>sh', 'help_tags')
map('<leader>tc', 'colorscheme')
map('<leader>lst', 'treesitter')
map('<leader>lsd', 'lsp_document_symbols')
map('<leader>lsw', 'lsp_workspace_symbols')
map('<leader>cR', 'lsp_references')
map('<leader>cd', 'diagnostics')
map('<leader>ci', 'lsp_implementations')
map('gd', 'lsp_definitions')
map('g<C-d>', 'lsp_type_definitions')
map('<leader>gs', 'git_status')
