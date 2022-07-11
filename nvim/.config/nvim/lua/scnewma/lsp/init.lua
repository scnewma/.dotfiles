local has_lsp, _ = pcall(require, 'lspconfig')
if not has_lsp then
    return
end

local on_attach = function(_, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

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
    map { 'K', require('lspsaga.hover').render_hover_doc }
    map { '<C-k>', require("lspsaga.signaturehelp").signature_help }

    -- code-rename
    map { '<Leader>cr', require("lspsaga.rename").lsp_rename }

    --  diagnostics
    map { '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>' }
    map { '[d', require("lspsaga.diagnostic").goto_prev }
    map { ']d', require("lspsaga.diagnostic").goto_next }

    map { '<Leader>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>' }
    map { '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>' }

    if vim.tbl_contains({"rust"}, filetype) then
        vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync(nil, 1000)]]
    end
end

-- config that activates keymaps and enabled snippet support
local function make_config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.snippetSupport = true
    capabilities.textDocument.codeLens = { dynamicRegistration = false }
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    return {
        capabilities = capabilities,
        on_attach = on_attach,
    }
end

local lspconfig = require('lspconfig');
lspconfig.bashls.setup(make_config())
lspconfig.dockerls.setup(make_config())
lspconfig.gopls.setup(make_config())
lspconfig.jsonls.setup(make_config())
lspconfig.pyright.setup(make_config())
lspconfig.rnix.setup(make_config())
lspconfig.rust_analyzer.setup(make_config())
lspconfig.vimls.setup(make_config())
lspconfig.yamlls.setup(make_config())

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
lspconfig.sumneko_lua.setup(lua_config)

require("fidget").setup({})

local M = {}

-- organize imports and run formatting
-- based on: https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
function M.goimports(timeout_ms)
    timeout_ms = timeout_ms or 1000

    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    for _, res in pairs(result) do
        for _, r in pairs(res.result or {}) do
            if r.edit and not vim.tbl_isempty(r.edit) then
                vim.lsp.util.apply_workspace_edit(r.edit, 'UTF-8')
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end

    vim.lsp.buf.formatting_sync(nil, timeout_ms)
end

return M
