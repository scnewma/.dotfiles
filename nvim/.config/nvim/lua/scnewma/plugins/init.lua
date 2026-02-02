local kitty_scrollback_plugin = {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
        require('kitty-scrollback').setup()
    end,
}
if vim.env.KITTY_SCROLLBACK_NVIM == 'true' then
    -- kitty-scrollback.nvim specific plugins
    return { kitty_scrollback_plugin }
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
            { '<leader>*', mode="v", '<cmd>:FzfLua grep_visual<CR>' },
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

    'junegunn/vim-easy-align',

    {
        "folke/snacks.nvim",
        lazy = false,
        opts = {
            gitbrowse = {}
        },
        keys = {
            { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
            { "<leader>gY", function() 
                Snacks.gitbrowse({ what = "permalink", open = function(url) vim.fn.setreg("+", url) end, notify = false })
            end, desc = "Git Browse (copy)", mode = { "n", "v" } },
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    Snacks.toggle.inlay_hints():map("<leader>th")
                end,
            })
        end
    },

    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {
            map_cr = true,
            fast_wrap = {
                map = '<C-p>'
            },
        },
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
        opts = {
            keymap = { preset = 'super-tab' },
            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
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
        "stevearc/conform.nvim",
        opts = {
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                markdown = { "prettier" },
                yaml = { "prettier" },
            },
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

    kitty_scrollback_plugin,
}
