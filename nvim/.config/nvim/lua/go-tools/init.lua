local function binary_exists(executable)
    if vim.fn.executable(executable) == 1 then
        return true
    end
    vim.api.nvim_echo({ {'No binary', 'ErrorMsg'}, { string.format('%s does not exist. Execute `go get github.com/fatih/gomodifytags`', executable) } })
    return false
end

local function exec(start, fin, fname)
    if not binary_exists('gomodifytags') then
        return
    end
    local line = string.format('%d,%d', start, fin)
    local cmd = { 'gomodifytags', '-file', fname, '-line', line, '-add-tags', 'json', '-format', 'json' }
    local response = vim.fn.json_decode(vim.fn.system(cmd))

    local i = 1
    for linenum = response.start,response['end'] do
        vim.fn.setline(linenum, response.lines[i])
        i = i + 1
    end
end

local M = {}

function M.add_tags(start, fin)
    local file_path = vim.fn.expand('%:p')
    exec(start, fin, file_path)
end

return M
