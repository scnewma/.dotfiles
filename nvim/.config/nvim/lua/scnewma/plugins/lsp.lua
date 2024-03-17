local on_attach = function(_, bufnr)
    local function map(tbl)
        if tbl[3] == nil then
            tbl[3] = {}
        end
        tbl[3].silent = true
        tbl[3].noremap = true
        tbl[3].buffer = bufnr
        vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
    end

    -- Mappings
    map { 'gD', vim.lsp.buf.declaration }
    map { 'K', vim.lsp.buf.hover }
    vim.keymap.set('i', '<C-k>',
        vim.lsp.buf.signature_help,
        { silent = true, noremap = true, buffer = bufnr })

    -- code-rename
    map { '<Leader>cr', vim.lsp.buf.rename }

    --  diagnostics
    map { '<Leader>cl', vim.diagnostic.setloclist }
    map { '[d', vim.diagnostic.goto_prev }
    map { ']d', vim.diagnostic.goto_next }

    map { '<Leader>cf', function() vim.lsp.buf.format({ async = false }) end }
    map { '<Leader>ca', vim.lsp.buf.code_action }
end

local function make_capabilities()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.textDocument.completion.snippetSupport = true
    capabilities.textDocument.codeLens = { dynamicRegistration = false }
    return capabilities
end

-- config that activates keymaps and enabled snippet support
local function make_config()
    return {
        capabilities = make_capabilities(),
        on_attach = on_attach,
    }
end

return {
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'j-hui/fidget.nvim',
        },
        opts = {
            servers = {
                bashls = {},
                dockerls = {},
                jsonls = {},
                pyright = {},
                vimls = {},
                yamlls = {},
                denols = {},
                tsserver = {},
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
            },
            setup = {
                denols = function(opts)
                    opts = vim.tbl_deep_extend('force', opts, {
                        root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
                    })
                    require('lspconfig').denols.setup(opts)
                end,
                tsserver = function(opts)
                    opts = vim.tbl_deep_extend('force', opts, {
                        root_dir = require('lspconfig').util.root_pattern('package.json'),
                        single_file_support = false,
                    })
                    require('lspconfig').tsserver.setup(opts)
                end,
                gopls = function(opts)
                    opts = vim.tbl_deep_extend('force', opts, {
                        on_attach = function(client, bufnr)
                            -- call default on_attach
                            on_attach(client, bufnr)

                            local function map(tbl)
                                if tbl[3] == nil then
                                    tbl[3] = {}
                                end

                                if tbl[3]['silent'] == nil then
                                    tbl[3].silent = true
                                end

                                tbl[3].noremap = true
                                tbl[3].buffer = bufnr
                                vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
                            end

                            map { '<leader>mf', require("go.reftool").fillstruct }
                            map { '<leader>mi', ':GoImpl' }
                            -- TODO: I wish this didn't include the type on end of comment, but
                            -- that's hardcoded in the plugin...
                            map { '<leader>mc', require('go.comment').gen }
                            map { '<leader>mta', ':GoAddTag json', { silent = false } }
                            map { '<leader>mtr', ':GoRmTag json', { silent = false } }
                            map { '<leader>mtc', ':GoClearTag', { silent = false } }
                        end,

                        ['local'] = require('scnewma.lsp.go').go_module_name(),
                        analyses = {
                            nilness = true,
                            unusedparams = true,
                            unusedwrite = true,
                        },
                    })

                    require('lspconfig').gopls.setup(opts)
                    require('go').setup({
                        comment_placeholder = '',
                        build_tags = "integration",
                    })
                end
            },
        },
        config = function(_, opts)
            local servers = opts.servers
            for server, server_opts in pairs(servers) do
                server_opts = server_opts == true and {} or server_opts
                server_opts = vim.tbl_deep_extend('force', make_config(), server_opts)
                if opts.setup[server] then
                    opts.setup[server](server_opts)
                else
                    require('lspconfig')[server].setup(server_opts)
                end
            end
        end,
    },

    {
        'simrat39/rust-tools.nvim',
        dependencies = {
            'j-hui/fidget.nvim',
        },
        ft = 'rust',
        opts = {
            tools = {
                autoSetHints = false,
            },

            server = {
                on_attach = function(client, bufnr)
                    -- call default on_attach
                    on_attach(client, bufnr)

                    local function map(tbl)
                        if tbl[2] == nil then
                            return
                        end

                        if tbl[3] == nil then
                            tbl[3] = {}
                        end
                        tbl[3].silent = true
                        tbl[3].noremap = true
                        tbl[3].buffer = bufnr
                        vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
                    end

                    -- overrside 'K' to a rust-specific version
                    map { 'K', require('rust-tools.hover_actions').hover_actions }

                    -- open "module" description (i.e. Cargo.toml)
                    map { '<leader>cm', require('rust-tools.open_cargo_toml').open_cargo_toml }

                    -- rust-aware join lines
                    map { 'J', require('rust-tools.join_lines').join_lines }

                    -- inlay hint management
                    map { '<leader>mhe', require('rust-tools.inlay_hints').set }
                    map { '<leader>mhd', require('rust-tools.inlay_hints').unset }

                    vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.format({ timeout_ms = 1000 })]]
                end,
                capabilities = make_capabilities(),
                cmd = { "rustup", "run", "stable", "rust-analyzer" },
            }
        }
    }
}
