vim.fn['plug#begin']('~/.config/nvim/plugged')

vim.cmd [[Plug 'sainnhe/gruvbox-material']]

-- always be improving
vim.cmd [[Plug 'tjdevries/train.nvim']]
vim.cmd [[Plug 'takac/vim-hardtime']]
vim.cmd [[Plug 'ThePrimeagen/vim-be-good']]

-- nvim-telescope
vim.cmd [[Plug 'nvim-lua/popup.nvim']]
vim.cmd [[Plug 'nvim-lua/plenary.nvim']]
-- vim.cmd [[Plug 'nvim-telescope/telescope.nvim']]
-- vim.cmd [[Plug 'nvim-telescope/telescope-project.nvim']]
-- vim.cmd [[Plug 'nvim-telescope/telescope-fzy-native.nvim']]

vim.cmd [[Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }]]
vim.cmd [[Plug 'junegunn/fzf.vim']]

vim.cmd [[Plug 'tpope/vim-fugitive']]
vim.cmd [[Plug 'tpope/vim-commentary']]
vim.cmd [[Plug 'tpope/vim-repeat']]
vim.cmd [[Plug 'ggandor/lightspeed.nvim']]
-- substitution for abbreviations, case-respecting replacement
vim.cmd [[Plug 'tpope/vim-abolish']]
vim.cmd [[Plug 'tpope/vim-vinegar']]
vim.cmd [[Plug 'tpope/vim-eunuch']]

-- best surround plugin since sliced bread
vim.cmd [[Plug 'machakann/vim-sandwich']]

-- allows forward searching for text objects among other things
vim.cmd [[Plug 'wellle/targets.vim']]

vim.cmd [[Plug 'junegunn/vim-easy-align']]

-- LSP
vim.cmd [[Plug 'neovim/nvim-lspconfig']]
vim.cmd [[Plug 'hrsh7th/nvim-compe']]
vim.cmd [[Plug 'kabouzeid/nvim-lspinstall']]
vim.cmd [[Plug 'glepnir/lspsaga.nvim']]
vim.cmd [[Plug 'windwp/nvim-autopairs']]

--   Lua LSP
vim.cmd [[Plug 'euclidianAce/BetterLua.vim']] -- better syntax highlighting

-- Snippets
vim.cmd [[Plug 'hrsh7th/vim-vsnip']]
vim.cmd [[Plug 'hrsh7th/vim-vsnip-integ']]
vim.cmd [[Plug 'rafamadriz/friendly-snippets']]

-- Languages
vim.cmd [[Plug 'hashivim/vim-terraform']]
vim.cmd [[Plug 'google/vim-jsonnet']]
vim.cmd [[Plug 'jjo/vim-cue']]
vim.cmd [[Plug 'stephpy/vim-yaml']]
vim.cmd [[Plug 'elixir-editors/vim-elixir']]
vim.cmd [[Plug 'mhinz/vim-mix-format']]
-- install from pre build since I don't always have nodejs and yarn
vim.cmd [[Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}]]

-- Treesitter
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}]] -- update parsers on update
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter-textobjects']]

vim.fn['plug#end']()
