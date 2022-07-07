local ls = require('luasnip')

ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
}

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

vim.keymap.set('n', '<leader>rs', '<cmd>source ~/.config/nvim/lua/scnewma/snippets.lua<CR>')

vim.api.nvim_create_user_command('LuaSnipEdit', function()
    require('luasnip.loaders').edit_snippet_files({})
end, {})

local path = vim.fn.stdpath('config') .. '/lua/scnewma/snippets'
require('luasnip.loaders.from_lua').lazy_load({ paths = path })
