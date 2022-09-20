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

-- open the import defined on the current line in https://pkg.go.dev
function M.go_pkg_doc_open()
    local line = vim.fn.getline(".")
    local matches = vim.fn.matchlist(line, '\\s*"\\(.*\\)"\\s*')
    if #matches > 0 then
        local cmd = { 'open', 'https://pkg.go.dev/' .. matches[2] }
        vim.fn.system(cmd)
        print(matches[2])
    else
        print("E: no import found")
    end
end

return M
