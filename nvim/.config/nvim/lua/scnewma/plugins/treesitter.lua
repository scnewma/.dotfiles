return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
          require("nvim-treesitter.configs").setup {
            auto_install = true,
            ensure_installed = {
                'c',
                'bash',
                'go',
                'gomod',
                'json',
                'lua',
                'python',
                'dockerfile',
                'hcl',
                'java',
                'ruby',
                'rust',
                'yaml',
                'vim',
                'vimdoc',
                'zig',
                'query',
                -- needed for lspsaga
                'markdown',
                'markdown_inline',
            },

            highlight = {
                enable = true,
            },

            indent = {
                enable = true,
                disable = { 'go' }
            },

            textobjects = {
                select = {
                    enable = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@conditional.outer",
                        ["ic"] = "@conditional.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        ["as"] = "@statement.outer",
                        ["is"] = "@statement.inner",
                        ["am"] = "@call.outer",
                        ["im"] = "@call.inner",
                        ["ap"] = "@parameter.outer",
                        ["ip"] = "@parameter.inner",
                    }
                },

                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>csa"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>csA"] = "@parameter.inner",
                    }
                },

                move = {
                    enable = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                    }
                },

                lsp_interop = {
                    enable = true,
                    peek_definition_code = {
                        -- code-show-function
                        ["<leader>csf"] = "@function.outer",
                        -- code-show-class
                        ["<leader>csc"] = "@class.outer",
                    },
                },
            }
        }
        end,
    },
}
