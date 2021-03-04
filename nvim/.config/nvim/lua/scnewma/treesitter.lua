require('nvim-treesitter.configs').setup {
    ensure_installed = {'go', 'json'},

    highlight = {
        enable = true,
    },

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
