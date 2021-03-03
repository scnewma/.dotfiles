require('telescope').setup {
    defaults = {},

    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}

-- Load the fzy native extension
pcall(require('telescope').load_extension, 'fzy_native')

local M = {}

function M.edit_dotfiles()
    require('telescope.builtin').git_files {
        prompt_title = "~ dotfiles ~",
        cwd = "~/.dotfiles", 
    }
end

return setmetatable({}, {
    __index = function(_, k)
        if M[k] then
            return M[k]
        else
            return require('telescope.builtin')[k]
        end
    end
})
