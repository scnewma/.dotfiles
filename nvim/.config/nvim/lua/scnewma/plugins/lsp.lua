return {
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'j-hui/fidget.nvim',
            'saghen/blink.cmp',
        },
        opts = {
            servers = {
                bashls = {},
                dockerls = {},
                jsonls = {},
                pyright = {
                    settings = {
                        pyright = {
                            -- Using Ruff's import organizer
                            disableOrganizeImports = true,
                        },
                        python = {
                            analysis = {
                                -- Ignore all files for analysis to exclusively use Ruff for linting
                                ignore = { '*' },
                            },
                        },
                    }
                },
                ruff = {
                    cmd = { 'uvx', 'ruff', 'server' },
                },
                ty = {
                    cmd = { 'uvx', 'ty', 'server' },
                },
                vimls = {},
                yamlls = {},
                denols = {},
                ts_ls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            telemetry = { enable = false },
                            diagnostics = {
                                -- Get the language server to recognize the `vim` global
                                globals = {'vim'},
                            },
                            workspace = {
                                -- Make the server aware of Neovim runtime files
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                        },
                    },
                },
                gopls = {},
                gleam = {},
            },
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    -- disable any custom formatting nvim configures. this
                    -- breaks gq line wrapping which is annoying.
                    vim.api.nvim_set_option_value("formatexpr", "", {buf = args.buf})
                    vim.api.nvim_set_option_value("formatprg", "", {buf = args.buf})

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then
                        return
                    end

                    local kmopts = {
                        silent = true,
                        noremap = true,
                        buffer = args.buf,
                    }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, kmopts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, kmopts)
                    -- code-rename
                    vim.keymap.set('n', '<Leader>cr', vim.lsp.buf.rename, kmopts)
                    --  diagnostics
                    vim.keymap.set('n', '<Leader>cl', vim.diagnostic.setloclist, kmopts)
                    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count=-1, float=true}) end, kmopts)
                    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count=1, float=true}) end, kmopts)

                    vim.keymap.set('n', '<Leader>cf', function() vim.lsp.buf.format({ async = false }) end, kmopts)

                    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, kmopts)

                    if client.name == 'gopls' then
                        vim.keymap.set('n', '<leader>mf', require("go.reftool").fillstruct, kmopts)
                        vim.keymap.set('n', '<leader>mi', ':GoImpl', kmopts)
                        vim.keymap.set('n', '<leader>mta', ':GoAddTag json', { silent = false, noremap = true, buffer = args.buf })
                        vim.keymap.set('n', '<leader>mtr', ':GoRmTag json', { silent = false, noremap = true, buffer = args.buf })
                        vim.keymap.set('n', '<leader>mtc', ':GoClearTag', { silent = false, noremap = true, buffer = args.buf })
                    elseif client.name == "ruff" then
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end
                end,
            })

            local servers = opts.servers
            for server, server_opts in pairs(servers) do
                server_opts = server_opts == true and {} or server_opts
                vim.lsp.config[server] = server_opts
                vim.lsp.enable(server)
            end
        end,
    },

    {
        "ray-x/go.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function(lp, opts)
            require("go").setup(opts)
            local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    require('go.format').goimports()
                end,
                group = format_sync_grp,
            })
        end,
        event = {"CmdlineEnter"},
        ft = {"go", 'gomod'},
        build = ':lua require("go.install").update_all_sync()' -- install/update all binaries
    },
}
