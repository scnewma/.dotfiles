-- trims trailing whitespace in buffer
local function chomp()
    vim.api.nvim_command('%s/\\s\\+$// | normal! ``')
end
vim.api.nvim_create_user_command('Chomp', chomp, {})
