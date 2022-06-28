local has_lsp, _ = pcall(require, 'lspconfig')
if not has_lsp then
    return
end

-- styling
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, {
    border = 'single',
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = false,
        virtual_text = {
            spacing = 4,
            source = 'always',
            severity_limit = 'Hint',
        },
        signs = true,
        severity_sort = true,
    }
)

local on_attach = function(_, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    -- Mappings
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    --      code-rename
    buf_set_keymap('n', '<Leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    --  diagnostics
    buf_set_keymap('n', '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev({ popup_opts = { border = \"single\" }})<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next({ popup_opts = { border = \"single\" }})<CR>', opts)

    buf_set_keymap('n', '<Leader>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)
    buf_set_keymap('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

    if vim.tbl_contains({"rust", "go"}, filetype) then
        vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
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

local M = {}

-- Source: https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-656372575
function M.goimports(timeout_ms)
    local context = { source = { organizeImports = true } }
    vim.validate { context = { context, "t", true } }
    local params = vim.lsp.util.make_range_params()
    params.context = context

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result then return end
    result = result[1].result
    if not result then return end
    local edit = result[1].edit
    vim.lsp.util.apply_workspace_edit(edit)
end

require("fidget").setup({})

return M
