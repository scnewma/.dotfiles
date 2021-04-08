local M = {}

-- Reload Vim configuration
function M.Reload()
    require('plenary.reload').reload_module('scnewma')
    vim.cmd [[luafile $MYVIMRC]]
end

return M
