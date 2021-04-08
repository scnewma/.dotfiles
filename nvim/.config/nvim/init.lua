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

-- Telescope
require('scnewma.telescope')
require('scnewma.telescope.mappings')

-- Treesitter
require('scnewma.treesitter')
