require('lightspeed').setup {
    grey_out_search_area = false,
    limit_ft_matches = 1,
}

vim.cmd [[
    nmap ; <Plug>Lightspeed_;_ft
    nmap , <Plug>Lightspeed_,_ft
]]
