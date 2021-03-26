vim.fn['plug#begin']('~/.config/nvim/plugged')

vim.cmd [[Plug 'sainnhe/gruvbox-material']]

-- always be improving
vim.cmd [[Plug 'tjdevries/train.nvim']]
vim.cmd [[Plug 'takac/vim-hardtime']]

-- nvim-telescope
vim.cmd [[Plug 'nvim-lua/popup.nvim']]
vim.cmd [[Plug 'nvim-lua/plenary.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope-project.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope-fzy-native.nvim']]

vim.cmd [[Plug 'tpope/vim-fugitive']]
vim.cmd [[Plug 'tpope/vim-commentary']]
vim.cmd [[Plug 'tpope/vim-repeat']]
-- substitution for abbreviations, case-respecting replacement
vim.cmd [[Plug 'tpope/vim-abolish']]
vim.cmd [[Plug 'tpope/vim-vinegar']]

-- best surround plugin since sliced bread
vim.cmd [[Plug 'machakann/vim-sandwich']]

-- allows forward searching for text objects among other things
vim.cmd [[Plug 'wellle/targets.vim']]

vim.cmd [[Plug 'junegunn/vim-easy-align']]

-- LSP
vim.cmd [[Plug 'neovim/nvim-lspconfig']]
-- vim.cmd [[Plug 'nvim-lua/completion-nvim']]
vim.cmd [[Plug 'hrsh7th/nvim-compe']]

--   Lua LSP
vim.cmd [[Plug 'tjdevries/nlua.nvim']]
vim.cmd [[Plug 'euclidianAce/BetterLua.vim']] -- better syntax highlighting

-- Languages
vim.cmd [[Plug 'hashivim/vim-terraform']]
vim.cmd [[Plug 'google/vim-jsonnet']]
vim.cmd [[Plug 'jjo/vim-cue']]
vim.cmd [[Plug 'stephpy/vim-yaml']]
-- install from pre build since I don't always have nodejs and yarn
vim.cmd [[Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}]]

-- Treesitter
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}]] -- update parsers on update
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter-textobjects']]

vim.fn['plug#end']()
