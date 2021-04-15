local M = {}

-- Reload Vim configuration
function M.Reload()
    require('plenary.reload').reload_module('scnewma')
    vim.cmd [[luafile $MYVIMRC]]
end

-- Restore the previous cursor position that you had when
-- you were last in this file, ignoring gitcommit filetype.
function M.RestoreCursorPos()
    if vim.api.nvim_buf_get_option(0, 'filetype') == 'gitcommit' then
        return
    end

    local prev_line = vim.fn.line("'\"")
    local max_buf_line = vim.fn.line('$')
    if prev_line > 1 and prev_line < max_buf_line then
        vim.cmd [[normal! g`"]]
    end
end

return M
