if require('scnewma.first_load')() then
  return
end

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
