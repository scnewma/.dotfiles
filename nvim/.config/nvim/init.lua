if require('scnewma.first_load')() then
  return
end

-- Add command for reloading main module. This is setup
-- manually at the beginning so that we can ensure that
-- it's always available even if some files fail to load.
vim.cmd [[command! Reload lua require('scnewma.utils').Reload()]]

vim.g.mapleader = ' '

-- Setup globals that I expect to be always available.
require('scnewma.globals')

-- Load vim-plug plugins
require('scnewma.plugins')

-- Load neovim options
require('scnewma.options')

-- Neovim builtin LSP configuration
require('scnewma.lsp')
require('rust-tools').setup({})

-- Telescope
-- require('scnewma.telescope')
-- require('scnewma.telescope.mappings')

-- Treesitter
require('scnewma.treesitter')

require('scnewma.lightspeed')

require('nvim-autopairs').setup{}
require('nvim-autopairs.completion.compe').setup({
    map_cr = true,
    map_complete = true,
    auto_select = false,
})

local saga = require 'lspsaga'
saga.init_lsp_saga()
vim.cmd [[
nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <silent><leader>ca :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>
nnoremap <silent> K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
nnoremap <silent> gs <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
nnoremap <Leader>cr <cmd>lua require('lspsaga.rename').rename()<CR>
nnoremap <silent> <Leader>gd <cmd>lua require'lspsaga.provider'.preview_definition()<CR>

nnoremap <silent><leader>cd <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
nnoremap <silent><leader>cc <cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>
nnoremap <silent> [d <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
nnoremap <silent> ]d <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>
]]

-- tab completion for compe + vsnip

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function ()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function ()
    if vim.fn['vsnip#jumpable'](1) == 1 then
        return t "<Plug>(vsnip-expand-or-jump)"
    elseif vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return vim.fn['compe#complete']()
    end
end

_G.s_tab_complete = function ()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    elseif vim.fn['vsnip#jumpable'](-1) == 1 then
        return t "<Plug>(vnsip-jump-prev)"
    else
        return t "<S-Tab>"
    end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

vim.opt.mouse = "a"
