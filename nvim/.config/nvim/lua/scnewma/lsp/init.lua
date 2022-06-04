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
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'g<C-d>', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    --      code-rename
    buf_set_keymap('n', '<Leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<Leader>cR', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    --  diagnostics
    buf_set_keymap('n', '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev({ popup_opts = { border = \"single\" }})<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next({ popup_opts = { border = \"single\" }})<CR>', opts)

    buf_set_keymap('n', '<Leader>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)

    --      automatic formatting
    -- if vim.tbl_contains({"go"}, filetype) then
    --     vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
    --     vim.cmd [[autocmd BufWritePre <buffer> :lua require('scnewma.lsp').goimports(1000)]]
    -- end

    if vim.tbl_contains({"rust"}, filetype) then
        vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
    end
end

-- Configure lua language server for neovim development
local lua_settings = {
    Lua = {
        runtime = {
            -- LuaJIT for neovim
            version = 'LuaJIT',
            path = vim.split(package.path, ';'),
        },
        diagnostics = {
            -- get the language server to recognize the `vim` global
            globals = {'vim'},
        },
        workspace = {
            -- make the server aware of neovim runtime files
            library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            },
        },
    }
}

local go_settings = {
    gopls = {
        codelenses = { test = true },
    }
}

local rust_settings = {
    ["rust-analyzer"] = {
        -- checkOnSave = {
        --     command = "clippy"
        -- }
    }
}

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

local lsp_installer = require("nvim-lsp-installer")

local servers = {
    "bashls",
    "dockerls",
    "elixirls",
    "gopls",
    "jsonls",
    "sumneko_lua",
    "pyright",
    "rust_analyzer",
    "vimls",
    "yamlls",
}

for _, name in pairs(servers) do
    local server_is_found, server = lsp_installer.get_server(name)
    if server_is_found then
        if not server:is_installed() then
            print("Installing " .. name)
            server:install()
        end
    end
end

lsp_installer.on_server_ready(function(server)
    local opts = make_config()

    if server.name == "rust_analyzer" then
        require("rust-tools").setup {
            server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
        }
        server:attach_buffers()
    else
        server:setup(opts)
    end
end)

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

return M
