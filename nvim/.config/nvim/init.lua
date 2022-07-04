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

-- Load packer plugins
require('scnewma.plugins')

-- Load neovim options
require('scnewma.options')
require('scnewma.mappings')
require('scnewma.commands')

-- Neovim builtin LSP configuration
require('scnewma.lsp')
require('go').setup({
    build_tags = "integration",
})

-- Telescope
require('scnewma.telescope')
require('scnewma.telescope.mappings')

require('scnewma.completion')

-- Treesitter
require('scnewma.treesitter')

-- require('nvim-autopairs').setup{}

vim.cmd [[
    imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]]

vim.opt.mouse = "a"
