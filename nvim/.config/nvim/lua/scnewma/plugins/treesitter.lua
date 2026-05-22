return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                branch = 'main',
                config = function()
                    require('nvim-treesitter-textobjects').setup {
                        select = {
                            lookahead = true,
                        },
                        move = {
                            set_jumps = true,
                        },
                    }

                    local select = require('nvim-treesitter-textobjects.select')
                    local move = require('nvim-treesitter-textobjects.move')
                    local swap = require('nvim-treesitter-textobjects.swap')

                    local select_keymaps = {
                        af = '@function.outer',
                        ['if'] = '@function.inner',
                        ac = '@conditional.outer',
                        ic = '@conditional.inner',
                        al = '@loop.outer',
                        il = '@loop.inner',
                        ['as'] = '@statement.outer',
                        ['is'] = '@statement.inner',
                        am = '@call.outer',
                        im = '@call.inner',
                        ap = '@parameter.outer',
                        ip = '@parameter.inner',
                    }

                    for lhs, query in pairs(select_keymaps) do
                        vim.keymap.set({ 'x', 'o' }, lhs, function()
                            select.select_textobject(query, 'textobjects')
                        end)
                    end

                    vim.keymap.set('n', '<leader>csa', function()
                        swap.swap_next('@parameter.inner', 'textobjects')
                    end)
                    vim.keymap.set('n', '<leader>csA', function()
                        swap.swap_previous('@parameter.inner', 'textobjects')
                    end)

                    vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
                        move.goto_next_start('@function.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
                        move.goto_next_start('@class.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
                        move.goto_next_end('@function.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
                        move.goto_next_end('@class.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
                        move.goto_previous_start('@function.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
                        move.goto_previous_start('@class.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
                        move.goto_previous_end('@function.outer', 'textobjects')
                    end)
                    vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
                        move.goto_previous_end('@class.outer', 'textobjects')
                    end)
                end,
            },
        },
        config = function()
            vim.filetype.add({
                extension = {
                    gotmpl = 'gotmpl',
                },
                pattern = {
                    [".*/templates/.*%.tpl"] = 'helm',
                    [".*/templates/.*%.ya?ml"] = 'helm',
                    ["helmfile.*%.ya?ml"] = 'helm',
                },
            })

            local languages = {
                'bash',
                'c',
                'dockerfile',
                'go',
                'gomod',
                'gotmpl',
                'hcl',
                'helm',
                'java',
                'json',
                'lua',
                'markdown',
                'markdown_inline',
                'python',
                'query',
                'ruby',
                'rust',
                'swift',
                'vim',
                'vimdoc',
                'yaml',
                'zig',
            }

            require('nvim-treesitter').install(languages)

            local group = vim.api.nvim_create_augroup('ScnewmaTreesitter', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                pattern = {
                    'bash',
                    'c',
                    'dockerfile',
                    'go',
                    'gomod',
                    'gotmpl',
                    'hcl',
                    'helm',
                    'java',
                    'json',
                    'lua',
                    'markdown',
                    'python',
                    'query',
                    'ruby',
                    'rust',
                    'swift',
                    'vim',
                    'vimdoc',
                    'yaml',
                    'zig',
                },
                callback = function(args)
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end

                    if vim.bo[args.buf].filetype ~= 'go' then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
