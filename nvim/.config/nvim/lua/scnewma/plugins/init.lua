local ai_helper = 'codecompanion'

local ai_helper_plugin = {}

if ai_helper == 'codecompanion' then
    ai_helper_plugin = {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft = { "codecompanion" }
            },
            "j-hui/fidget.nvim"
        },
        cmd = {"CodeCompanion", "CodeCompanionChat"},
        init = function()
            require("scnewma.codecompanion.fidget-spinner"):init()
        end,
        opts = {
            adapters = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        schema = {
                            model = {
                                default = "claude-sonnet-4",
                            },
                        },
                    })
                end,
            },
            strategies = {
                chat = {
                    adapter = "copilot",
                },
                inline = { adapter = "copilot" },
                cmd = { adapter = "copilot" },
            },
        },
        keys = {
            { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
            { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat", mode = { "n", "v" } },
            { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions", mode = { "n", "v" } },
            { "<leader>ai", ":CodeCompanion ", desc = "AI Inline", mode = { "n", "v" } },
            { "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", desc = "Paste into AI chat", mode = { "n", "v" } },
        },
    }
elseif ai_helper == 'copilotchat' then
    ai_helper_plugin = {
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
                model = "claude-sonnet-4",
                sticky = {
                    '#buffers',
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
                "<leader>av",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input, {
                            selection = function(source)
                                local select = require("CopilotChat.select")
                                return select.visual(source) or select.line(source)
                            end,
                            window = {
                                layout = "float",
                                relative = "cursor",
                                width = 1,
                                height = 0.4,
                                row = 1,
                            },
                        })
                    end
                end,
                desc = "Quick Chat (CopilotChat)",
                mode = { "x" },
            },
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
    }
end


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
            -- TODO: search for other dev directories
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

    -- completion
    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = {
            {
                "fang2hou/blink-copilot",
            },
        },
        opts = {
            keymap = { preset = 'super-tab' },
            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer", "copilot" },
                providers = {
                    copilot = {
                        name = "copilot",
                        module = "blink-copilot",
                        score_offset = 100,
                        async = true,
                    },
                },
            }
        },
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
        "echasnovski/mini.diff",
        config = function()
            local diff = require("mini.diff")
            diff.setup({
                -- Disabled by default
                source = diff.gen_source.none(),
            })
        end,
    },

    ai_helper_plugin
}
