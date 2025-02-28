-- Add command for reloading main module. This is setup
-- manually at the beginning so that we can ensure that
-- it's always available even if some files fail to load.
vim.api.nvim_create_user_command('Reload', function() require('scnewma.utils').Reload() end, {})

vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

require('scnewma.first-load')

-- Setup globals that I expect to be always available.
require('scnewma.globals')

require('lazy').setup('scnewma.plugins')

-- Load neovim options
require('scnewma.options')
require('scnewma.mappings')
require('scnewma.commands')
