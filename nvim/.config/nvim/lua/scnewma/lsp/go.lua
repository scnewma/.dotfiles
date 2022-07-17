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

function M.go_module_name()
    if vim.fn.filereadable('go.mod') == 1 then
        local cmd = { 'go', 'mod', 'edit', '-json' }
        local response = vim.fn.json_decode(vim.fn.system(cmd))
        return response['Module']['Path']
    end
    return ''
end

return M
