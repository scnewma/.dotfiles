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
require('scnewma.telescope')
require('scnewma.telescope.mappings')

require('scnewma.completion')

-- Treesitter
require('scnewma.treesitter')

require('scnewma.lightspeed')

require('nvim-autopairs').setup{}
require('nvim-autopairs.completion.cmp').setup({
    map_cr = true,
    map_complete = true,
    auto_select = false,
})

vim.cmd[[
command! -nargs=? -range GoAddTags lua require('go-tools').add_tags({<line1>, <line2>, <f-args>})
command! -nargs=? -range GoRemoveTags lua require('go-tools').remove_tags({<line1>, <line2>, <f-args>})
]]

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

-- use tab to jump to next/previous vsnip point
vim.cmd [[
    imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]]

vim.opt.mouse = "a"
