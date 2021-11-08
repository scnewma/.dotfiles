require('lightspeed').setup {
    grey_out_search_area = false,
    limit_ft_matches = 1,
}

-- use builtins for singe character search
vim.cmd [[
unmap t
unmap T
unmap f
unmap F
]]
