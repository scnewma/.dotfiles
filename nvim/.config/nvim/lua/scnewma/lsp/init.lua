local has_lsp, _ = pcall(require, 'lspconfig')
if not has_lsp then
    return
end

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
    map { 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>' }

    -- code-rename
    map { '<Leader>cr', require("lspsaga.rename").lsp_rename }

    --  diagnostics
    map { '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>' }

    map { '<Leader>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>' }
    map { '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>' }
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

local lspconfig = require('lspconfig');
lspconfig.bashls.setup(make_config())
lspconfig.dockerls.setup(make_config())
lspconfig.jsonls.setup(make_config())
lspconfig.pyright.setup(make_config())
lspconfig.vimls.setup(make_config())
lspconfig.yamlls.setup(vim.tbl_deep_extend("force", make_config(), {
    settings = {
        yaml = {
            keyOrdering = false,
        }
    }
}))
lspconfig.denols.setup(vim.tbl_deep_extend("force", make_config(), {
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
}))
lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", make_config(), {
    root_dir = lspconfig.util.root_pattern("package.json"),
    single_file_support = false,
}))

local lua_config = vim.tbl_deep_extend("force", make_config(), {
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
      },
    },
  },
})
lspconfig.lua_ls.setup(lua_config)

local go_config = vim.tbl_deep_extend("force", make_config(), {
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

    settings = {
        gopls = {
            ['local'] = require('scnewma.lsp.go').go_module_name(),
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
            },
        }
    }
})
lspconfig.gopls.setup(go_config)

require('rust-tools').setup({
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

            vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync(nil, 1000)]]
        end,
        capabilities = make_capabilities(),
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
    }
})

require("fidget").setup({})
