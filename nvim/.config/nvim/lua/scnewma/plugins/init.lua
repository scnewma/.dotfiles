return {
    'sainnhe/gruvbox-material',
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup {
                flavour = "mocha",
                no_italic = true,
                integrations = {
                    cmp = true,
                    -- breaks the colorscheme a bit, but unsetting this doesn't fully fix it
                    treesitter = false,
                }
            }
            vim.cmd.colorscheme "catppuccin"
        end
    },

    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'junegunn/fzf',
    {
        'junegunn/fzf.vim',
        config = function ()
            local function set_quickfix(files)
                local qf = {}
                for _, filename in pairs(files) do
                    table.insert(qf, { filename = filename })
                end
                vim.fn.setqflist(qf)
                vim.cmd [[ copen ]]
            end

            vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. " --bind ctrl-a:select-all --bind ctrl-d:deselect-all"
            vim.g.fzf_action = {
                -- defaults
                ['ctrl-t'] = 'tab split',
                ['ctrl-x'] = 'split',
                ['ctrl-v'] = 'vsplit',

                ['alt-q'] = set_quickfix,
            }
        end,
    },
    'gfanto/fzf-lsp.nvim',

    'tpope/vim-commentary',
    'tpope/vim-repeat',
    -- substitution for abbreviations, case-respecting replacement
    'tpope/vim-abolish',
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
    'windwp/nvim-autopairs',

    {
        'stevearc/oil.nvim',
        opts = {
            view_options = { show_hidden = true },
        },
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
    },

    -- Snippets
    {
        'L3MON4D3/LuaSnip',
        config = function()
            local path = vim.fn.stdpath('config') .. '/lua/scnewma/snippets'
            require('luasnip.loaders.from_lua').lazy_load({ paths = path })
        end,
        opts = {
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
        },
        keys = {
            {
                '<C-k>', function()
                    if require('luasnip').expand_or_jumpable() then
                        require('luasnip').expand_or_jump()
                    end
                end,
                silent = true, mode = { 'i', 's' }
            },
            {
                '<C-j>', function()
                    if require('luasnip').jumpable(-1) then
                        require('luasnip').jump(-1)
                    end
                end,
                silent = true, mode = { 'i', 's' }
            },
            {
                '<C-l>', function()
                    if require('luasnip').choice_active() then
                        require('luasnip').change_choice(1)
                    end
                end,
                silent = true, mode = { 'i', 's' }
            }
        }
    },

    -- completion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-vsnip',
            'onsails/lspkind-nvim',
            'saadparwaiz1/cmp_luasnip',
        },
        opts = function()
            local cmp = require('cmp')
            local lspkind = require('lspkind')

            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },

                mapping = {
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-c>"] = cmp.mapping.close(),
                    ["<C-n>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-e>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
                    ["<C-y>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
                },

                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },

                sources = {
                    { name = "nvim_lua" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "buffer", keyword_length = 5, max_item_count = 10 },
                },

                formatting = {
                    format = lspkind.cmp_format({
                        with_text = true,
                        menu = {
                            buffer = "[buf]",
                            nvim_lsp = "[LSP]",
                            nvim_lua = "[api]",
                            path = "[path]",
                        },
                    }),
                },

                experimental = {
                    ghost_text = true,
                }
            }
        end
    },

    --   Lua LSP
    'euclidianAce/BetterLua.vim', -- better syntax highlighting
    'onsails/lspkind-nvim',

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
    {
        'ray-x/go.nvim',
        ft = {'go', 'gomod'},
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
    -- install from pre build since I don't always have nodejs and yarn
    'LnL7/vim-nix',
    'cappyzawa/starlark.vim',
    'ziglang/zig.vim',
    'alaviss/nim.nvim',
}
