-- Source: https://github.com/wincent/wincent/blob/2d926177773f/aspects/nvim/files/.config/nvim/plugin/snippets.lua

-- If ~/.github-handles.json exists, use it.
local cab = (vim.fn.filereadable(vim.fn.expand('~/.github-handles.json')) == 1) and
    fmt('Co-Authored-By: {}', {
        i(1, '@handle'),
    }) or
    fmt('Co-Authored-By: {} <{}@{}>', {
        i(1, 'Name'),
        i(2, 'user'),
        i(3, 'github.com'),
    })

return {
    s({ trig = 'cab', dscr = "Co-Authored-By:" }, cab)
}
