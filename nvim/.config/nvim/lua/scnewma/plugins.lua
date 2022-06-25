vim.fn['plug#begin']('~/.config/nvim/plugged')

vim.cmd [[Plug 'sainnhe/gruvbox-material']]

-- nvim-telescope
vim.cmd [[Plug 'nvim-lua/popup.nvim']]
vim.cmd [[Plug 'nvim-lua/plenary.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope.nvim']]
vim.cmd [[Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }]]
vim.cmd [[Plug 'nvim-telescope/telescope-ui-select.nvim']]

vim.cmd [[Plug 'tpope/vim-commentary']]
vim.cmd [[Plug 'tpope/vim-repeat']]
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
vim.cmd [[Plug 'windwp/nvim-autopairs']]
vim.cmd [[Plug 'j-hui/fidget.nvim']]

-- completion
vim.cmd [[Plug 'hrsh7th/nvim-cmp']]
vim.cmd [[Plug 'hrsh7th/cmp-buffer']]
vim.cmd [[Plug 'hrsh7th/cmp-path']]
vim.cmd [[Plug 'hrsh7th/cmp-nvim-lua']]
vim.cmd [[Plug 'hrsh7th/cmp-nvim-lsp']]
vim.cmd [[Plug 'hrsh7th/cmp-vsnip']]

--   Lua LSP
vim.cmd [[Plug 'euclidianAce/BetterLua.vim']] -- better syntax highlighting
vim.cmd [[Plug 'onsails/lspkind-nvim']]

-- Snippets
vim.cmd [[Plug 'hrsh7th/vim-vsnip']]
vim.cmd [[Plug 'hrsh7th/vim-vsnip-integ']]
vim.cmd [[Plug 'rafamadriz/friendly-snippets']]

-- Languages
vim.cmd [[Plug 'hashivim/vim-terraform']]
vim.cmd [[Plug 'jvirtanen/vim-hcl']]
vim.cmd [[Plug 'google/vim-jsonnet']]
vim.cmd [[Plug 'jjo/vim-cue']]
vim.cmd [[Plug 'stephpy/vim-yaml']]
vim.cmd [[Plug 'elixir-editors/vim-elixir']]
vim.cmd [[Plug 'mhinz/vim-mix-format']]
vim.cmd [[Plug 'simrat39/rust-tools.nvim']]
vim.cmd [[Plug 'pangloss/vim-javascript']]
vim.cmd [[Plug 'maxmellon/vim-jsx-pretty']]
vim.cmd [[Plug 'ray-x/go.nvim']]
-- install from pre build since I don't always have nodejs and yarn
vim.cmd [[Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}]]
vim.cmd [[Plug 'LnL7/vim-nix']]

vim.cmd [[Plug 'jpalardy/vim-slime']]

-- Treesitter
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}]] -- update parsers on update
vim.cmd [[Plug 'nvim-treesitter/nvim-treesitter-textobjects']]

vim.fn['plug#end']()
