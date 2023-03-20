require('lazy').setup({
    'wbthomason/packer.nvim',
    'sainnhe/gruvbox-material',
    'catppuccin/vim',

    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope-ui-select.nvim',
    {
        'nvim-telescope/telescope-file-browser.nvim',
        keys = {
            {
                '-',
                ':Telescope file_browser path=%:p:h=$:p:h<CR>',
            },
        },
        config = function ()
            require('telescope').load_extension('file_browser')
        end,
    },

    'tpope/vim-commentary',
    'tpope/vim-repeat',
    -- substitution for abbreviations, case-respecting replacement
    'tpope/vim-abolish',
    -- Trying out telescope-file-browser
    -- 'tpope/vim-vinegar',
    'tpope/vim-eunuch',

    -- best surround plugin since sliced bread
    'machakann/vim-sandwich',

    -- allows forward searching for text objects among other things
    'wellle/targets.vim',

    -- gives :GBrowse functionality
    "tpope/vim-fugitive",
    "tpope/vim-rhubarb",

    'junegunn/vim-easy-align',

    -- LSP
    'neovim/nvim-lspconfig',
    'windwp/nvim-autopairs',
    'j-hui/fidget.nvim',

    -- completion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-vsnip',

    --   Lua LSP
    'euclidianAce/BetterLua.vim', -- better syntax highlighting
    'onsails/lspkind-nvim',

    {
        'glepnir/lspsaga.nvim',
        event = 'BufRead',
        config = function()
            require('lspsaga').setup({})
        end,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'nvim-treesitter/nvim-treesitter',
        }
    },

    -- Snippets
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',

    -- Languages
    'hashivim/vim-terraform',
    'jvirtanen/vim-hcl',
    'google/vim-jsonnet',
    'jjo/vim-cue',
    'stephpy/vim-yaml',
    'elixir-editors/vim-elixir',
    'mhinz/vim-mix-format',
    'simrat39/rust-tools.nvim',
    'pangloss/vim-javascript',
    'maxmellon/vim-jsx-pretty',
    'ray-x/go.nvim',
    -- install from pre build since I don't always have nodejs and yarn
    'LnL7/vim-nix',
    'cappyzawa/starlark.vim',
    'ziglang/zig.vim',

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            require('nvim-treesitter.install').update({ with_sync = true })
        end,
    },
    'nvim-treesitter/nvim-treesitter-textobjects',
})
