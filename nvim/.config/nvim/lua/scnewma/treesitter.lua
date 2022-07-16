require('nvim-treesitter.configs').setup {
    ensure_installed = {
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
    },

    highlight = {
        enable = true,
    },

    -- having many issues with treesitter indent since this commit:
    -- 6863f79118d3cb331fd4e726cdb2384bbd8bf8f2
    -- try again later
    -- indent = {
    --     enable = true,
    -- },
    indent = {
        enable = true,
    },

    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
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
        }
    }

}
