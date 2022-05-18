require('lightspeed').setup {
    limit_ft_matches = 1,
}

-- use builtins for singe character search
vim.cmd [[
unmap t
unmap T
unmap f
unmap F
unmap ;
]]
