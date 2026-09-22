local M = {}

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
