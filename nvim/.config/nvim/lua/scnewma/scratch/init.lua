local bufname = 'SCRATCH'

local config = {
    size = 15
}

-- local function set_defaults(defaults)
--     config = defaults or {}
-- end

local function get_bufnr()
    return vim.fn.bufnr('^'..bufname..'$')
end

local function create_win()
    vim.api.nvim_command('botright '.. config.size..'new ' .. bufname)
    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'scratch')
end

local function open_window()
    local bufnr = get_bufnr()
    if bufnr == -1 then
        create_win()
    else
        local winnr = vim.fn.bufwinnr(bufnr)
        if winnr == -1 then
            -- open window if one doesn't exist
            vim.api.nvim_command('botright '..config.size..'split +buffer' .. bufnr)
        else
            -- focus the window
            vim.api.nvim_command(winnr .. 'wincmd w')
        end
    end
end


local M = {}

-- function M.setup(opts)
--     set_defaults(opts.defaults)
-- end

function M.scratch()
    open_window()
end

function M.toggle()
    local bufnr = get_bufnr()
    if bufnr == -1 then
        open_window()
    else
        local winnr = vim.fn.bufwinnr(bufnr)
        if winnr == -1 then
            open_window()
        else
            vim.api.nvim_command(winnr .. 'close')
        end
    end
end

function M.close(wipeout)
    local bufnr = get_bufnr()
    if bufnr ~= -1 then
        local winnr = vim.fn.bufwinnr(bufnr)
        if winnr ~= -1 then
            vim.api.nvim_command(winnr..'close')
        end

        if wipeout then
            vim.api.nvim_command(bufnr..'bwipeout')
        end
    end
end

return M
