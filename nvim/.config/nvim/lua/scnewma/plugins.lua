-- bootstrapping
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup({ function (use)
    use 'wbthomason/packer.nvim'
    use 'sainnhe/gruvbox-material'

    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'nvim-telescope/telescope-ui-select.nvim'

    use 'tpope/vim-commentary'
    use 'tpope/vim-repeat'
    -- substitution for abbreviations, case-respecting replacement
    use 'tpope/vim-abolish'
    use 'tpope/vim-vinegar'
    use 'tpope/vim-eunuch'

    -- best surround plugin since sliced bread
    use 'machakann/vim-sandwich'

    -- allows forward searching for text objects among other things
    use 'wellle/targets.vim'

    -- gives :GBrowse functionality
    use "tpope/vim-fugitive"
    use "tpope/vim-rhubarb"

    use 'junegunn/vim-easy-align'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'windwp/nvim-autopairs'
    use 'j-hui/fidget.nvim'

    -- completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-vsnip'

    --   Lua LSP
    use 'euclidianAce/BetterLua.vim' -- better syntax highlighting
    use 'onsails/lspkind-nvim'
    use({
        "glepnir/lspsaga.nvim",
        -- branch = "main",
        commit = "e70a3b7af013215feb1213a8eb11986b88677759",
        config = function()
            local saga = require("lspsaga")
            saga.init_lsp_saga({})
        end,
    })

    -- Snippets
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'

    -- Languages
    use 'hashivim/vim-terraform'
    use 'jvirtanen/vim-hcl'
    use 'google/vim-jsonnet'
    use 'jjo/vim-cue'
    use 'stephpy/vim-yaml'
    use 'elixir-editors/vim-elixir'
    use 'mhinz/vim-mix-format'
    use 'simrat39/rust-tools.nvim'
    use 'pangloss/vim-javascript'
    use 'maxmellon/vim-jsx-pretty'
    use 'ray-x/go.nvim'
    -- install from pre build since I don't always have nodejs and yarn
    use 'LnL7/vim-nix'

    -- Treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'nvim-treesitter/nvim-treesitter-textobjects'

    if packer_bootstrap then
        require('packer').sync()
    end
end, config = { compile_path = vim.fn.stdpath('data') .. '/plugin/packer_compiled.lua' }
})
