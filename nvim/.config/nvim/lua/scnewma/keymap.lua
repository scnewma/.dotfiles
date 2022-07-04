local M = {}

M.imap = function(tbl)
    vim.keymap.set('i', tbl[1], tbl[2], tbl[3])
end

M.inoremap = function(tbl)
    if tbl[3] == nil then
        tbl[3] = {}
    end
    tbl[3].noremap = true
    vim.keymap.set('i', tbl[1], tbl[2], tbl[3])
end

M.nmap = function(tbl)
    vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

M.nnoremap = function(tbl)
    if tbl[3] == nil then
        tbl[3] = {}
    end
    tbl[3].noremap = true
    vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

M.vmap = function(tbl)
    vim.keymap.set('v', tbl[1], tbl[2], tbl[3])
end

M.vnoremap = function(tbl)
    if tbl[3] == nil then
        tbl[3] = {}
    end
    tbl[3].noremap = true
    vim.keymap.set('v', tbl[1], tbl[2], tbl[3])
end

M.cnoremap = function(tbl)
    if tbl[3] == nil then
        tbl[3] = {}
    end
    tbl[3].noremap = true
    vim.keymap.set('c', tbl[1], tbl[2], tbl[3])
end

return M
