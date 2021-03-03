vim.fn['plug#begin']('~/.config/nvim/plugged')

vim.cmd [[Plug 'sainnhe/gruvbox-material']]

-- always be improving
vim.cmd [[Plug 'tjdevries/train.nvim']]

-- nvim-telescope
vim.cmd [[Plug 'nvim-lua/popup.nvim']]
vim.cmd [[Plug 'nvim-lua/plenary.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope-project.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope-fzy-native.nvim']]

vim.cmd [[Plug 'tpope/vim-fugitive']]
vim.cmd [[Plug 'tpope/vim-commentary']]
vim.cmd [[Plug 'tpope/vim-repeat']]
vim.cmd [[Plug 'tpope/vim-surround']]
-- substitution for abbreviations, case-respecting replacement
vim.cmd [[Plug 'tpope/vim-abolish']]

-- argument text objects
vim.cmd [[Plug 'b4winckler/vim-angry']]

-- allows forward searching for text objects among other things
vim.cmd [[Plug 'wellle/targets.vim']]

-- LSP
vim.cmd [[Plug 'neovim/nvim-lspconfig']]
vim.cmd [[Plug 'nvim-lua/completion-nvim']]

--   Lua LSP
vim.cmd [[Plug 'tjdevries/nlua.nvim']]
vim.cmd [[Plug 'euclidianAce/BetterLua.vim']] -- better syntax highlighting

-- Languages
vim.cmd [[Plug 'hashivim/vim-terraform']]
vim.cmd [[Plug 'google/vim-jsonnet']]
vim.cmd [[Plug 'jjo/vim-cue']]
vim.cmd [[Plug 'stephpy/vim-yaml']]

vim.fn['plug#end']()
