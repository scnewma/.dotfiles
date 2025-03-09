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
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            defaults = {
                file_icons = false,
                color_icons = false,
            },
        },
        keys = {
            { '<leader>.', '<cmd>:FzfLua resume<CR>' },
            { '<leader>:', '<cmd>:FzfLua command_history<CR>' },
            { '<leader>/', '<cmd>:FzfLua live_grep<CR>' },
            { '<leader>*', '<cmd>:FzfLua grep_cword<CR>' },
            { '<leader><space>', '<cmd>:FzfLua files<CR>' },
            { '<leader>fg', '<cmd>:FzfLua git_files<CR>' },
            { '<leader>fe', '<cmd>:FzfLua files cwd=~/.dotfiles<CR>' },
            { '<leader>bb', '<cmd>:FzfLua buffers<CR>' },
            { '<leader>ss', '<cmd>:FzfLua blines<CR>' },
            { 'gd', '<cmd>:FzfLua lsp_definitions<CR>' },
            { 'gD', '<cmd>:FzfLua lsp_declarations<CR>' },
            { 'gA', '<cmd>:FzfLua lsp_references<CR>' },
            { 'gy', '<cmd>:FzfLua lsp_typedefs<CR>' },
            { 'gI', '<cmd>:FzfLua lsp_implementations<CR>' },
            { 'gs', '<cmd>:FzfLua lsp_document_symbols<CR>' },
            { 'gS', '<cmd>:FzfLua lsp_live_workspace_symbols<CR>' },
            { 'g.', '<cmd>:FzfLua lsp_code_actions<CR>' },
            -- search
            { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
            { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
            { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
            { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
            { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
            { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
            { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
            { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
            { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
            { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
            { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
            { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
            { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
            { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
        },
        init = function()
            require("fzf-lua").register_ui_select()
        end,
    },

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
    -- 'windwp/nvim-autopairs',
    {
        'echasnovski/mini.nvim',
        version = '*',
        config = function()
            require('mini.pairs').setup()
        end,
    },

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

                sorting = {
                    priority_weight = 2,
                    comparators = {
                        require("copilot_cmp.comparators").prioritize,

                        -- Below is the default comparitor list and order for nvim-cmp
                        cmp.config.compare.offset,
                        -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },

                mapping = {
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({select=true})
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
                    ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),

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
                    { name = "copilot" },
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
                    -- ghost_text = true,
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
    {
        'zbirenbaum/copilot.lua',
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        opts = {},
    },
    {
        'codethread/qmk.nvim',
        name = "qmk",
        opts = {
            name = "glove80",
            variant = "zmk",
            comment_preview = { position = "none" },
            layout = {
                'x x x x x _ _ _ _ _ _ _ _ _ x x x x x',
                'x x x x x x _ _ _ _ _ _ _ x x x x x x',
                'x x x x x x _ _ _ _ _ _ _ x x x x x x',
                'x x x x x x _ _ _ _ _ _ _ x x x x x x',
                'x x x x x x x x x _ x x x x x x x x x',
                'x x x x x _ x x x _ x x x _ x x x x x',
            }
        },
    },
    {
        'MagicDuck/grug-far.nvim',
        opts = {},
        cmd = "GrugFar",
        keys = {
            {
                "<leader>sr",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.open({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace",
            },
            {
                '<leader>sW',
                function ()
                    require('grug-far').open({ prefills = { search = vim.fn.expand("<cword>") } })
                end
            }
        },
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        cmd = "CopilotChat",
        opts = function()
            local user = vim.env.USER or "User"
            user = user:sub(1, 1):upper() .. user:sub(2)
            return {
                auto_insert_mode = true,
                question_header = "  " .. user .. " ",
                answer_header = "  Copilot ",
                window = {
                    width = 0.4,
                },
            }
        end,
        keys = {
            { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
            { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
            {
                "<leader>aa",
                function()
                    return require("CopilotChat").toggle()
                end,
                desc = "Toggle (CopilotChat)",
                mode = { "n", "v" },
            },
            {
                "<leader>ax",
                function()
                    return require("CopilotChat").reset()
                end,
                desc = "Clear (CopilotChat)",
                mode = { "n", "v" },
            },
            {
                "<leader>aq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input)
                    end
                end,
                desc = "Quick Chat (CopilotChat)",
                mode = { "n", "v" },
            },
            -- Show prompts actions with telescope
            -- { "<leader>ap", M.pick("prompt"), desc = "Prompt Actions (CopilotChat)", mode = { "n", "v" } },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")

            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-chat",
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                end,
            })

            chat.setup(opts)
        end,
    },
}
