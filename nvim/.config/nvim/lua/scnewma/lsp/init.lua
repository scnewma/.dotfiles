local has_lsp, _ = pcall(require, 'lspconfig')
if not has_lsp then
    return
end

-- styling
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, {
    border = 'single',
})

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
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
    buf_set_keymap('i', '<C-s>', '<cmd>lua require("scnewma/lsp").signature_line()<CR>', opts)

    --      code-rename
    buf_set_keymap('n', '<Leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<Leader>cR', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    --  diagnostics
    buf_set_keymap('n', '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev({ popup_opts = { border = \"single\" }})<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next({ popup_opts = { border = \"single\" }})<CR>', opts)

    buf_set_keymap('n', '<Leader>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)

    --      automatic formatting
    if vim.tbl_contains({"go"}, filetype) then
        vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
        vim.cmd [[autocmd BufWritePre <buffer> :lua require('scnewma.lsp').goimports(1000)]]
    end

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

-- config that activets keymaps and enabled snippet support
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

local function setup_servers()
    require('lspinstall').setup()

    local servers = require('lspinstall').installed_servers()

    for _, server in pairs(servers) do
        local config = make_config()

        -- language specific config
        if server == "lua" then
            config.settings = lua_settings
        end

        if server == "go" then
            config.settings = go_settings
        end

        if server == "rust" then
            config.settings = rust_settings
        end

        require('lspconfig')[server].setup(config)
    end
end

setup_servers()

-- automatically reload after `:LspInstall <server>` so we don't have to
-- restart neovim
require('lspinstall').post_install_hook = function()
    setup_servers() -- reload installed servers
    vim.cmd("bufdo e") -- triggers the FileType autocmd that starts the server
end

local M = {}

-- use lspinstall to install all servers in the installed_servers table
function M.install_servers()
    local wanted = { bash=true, dockerfile=true, elixir=true, go=true, json=true, lua=true, python=true, vim=true, yaml=true }
    for server in pairs(wanted) do
        require('lspinstall').install_server(server)
    end
end

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

function M.signature_line()
    local ts_utils = require('nvim-treesitter.ts_utils')
    local current_node  = ts_utils.get_node_at_cursor()
    local current_node_range = ts_utils.node_to_lsp_range(current_node)

    local params = vim.lsp.util.make_position_params()
    params.position.character = current_node_range["end"].character

    vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(_, result, _, _)
        if not (result and result.signatures and result.signatures[1]) then
            print("No signature help available")
            return
        end
        local active_signature = result.activeSignature or 0
        -- If the activeSignature is not inside the valid range, then clip it.
        if active_signature >= #result.signatures then
            active_signature = 0
        end
        local signature = result.signatures[active_signature + 1]
        if not signature then
            return
        end
        local label = signature.label
        local prefix = ""
        if #result.signatures > 1 then
            prefix = string.format("(1/%d) ", #result.signatures)
        end
        print(prefix .. label)
    end)
end

return M
