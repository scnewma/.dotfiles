local M = {}

-- defaults
M.options = {
    tags = 'json',
    transform = 'snakecase',
}

local function binary_exists(executable)
    if vim.fn.executable(executable) == 1 then
        return true
    end
    vim.api.nvim_echo({ {'No binary', 'ErrorMsg'}, { string.format('%s does not exist. Execute `go get github.com/fatih/gomodifytags`', executable) } })
    return false
end

-- args = { line_start, line_end, [tags], [transform] }
local function exec(mode, args)
    if not binary_exists('gomodifytags') then
        return
    end

    local line_start = args[1]
    local line_end = args[2]

    local fname = vim.fn.expand('%:p')
    local line = string.format('%d,%d', line_start, line_end)

    local transform = M.options.transform
    if #args >= 4 then
        transform = args[4]
    end

    local cmd = {
        'gomodifytags',
        '-format', 'json',
        '-file', fname,
        '-line', line,
        '-transform', transform,
    }

    local tags = M.options.tags
    if #args >= 3 then
        tags = args[3]
    end

    if mode == 'add' then
        table.insert(cmd, '-add-tags')
        table.insert(cmd, tags)
    elseif mode == 'remove' then
        table.insert(cmd, '-remove-tags')
        table.insert(cmd, tags)
    else
        return
    end

    local response = vim.fn.json_decode(vim.fn.system(cmd))

    -- write response back to buffer
    local i = 1
    for linenum = response.start,response['end'] do
        vim.fn.setline(linenum, response.lines[i])
        i = i + 1
    end
end

function M.add_tags(args)
    exec('add', args)
end

function M.remove_tags(args)
    exec('remove', args)
end

return M
