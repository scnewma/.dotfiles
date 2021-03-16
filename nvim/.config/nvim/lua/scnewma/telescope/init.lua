local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                -- change split horizontal to <C-s>
                ["<C-x>"] = false,
                ["<C-s>"] = actions.select_horizontal,
            }
        }
    },

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

-- this is used on my <SPC><SPC> binding to ensure that i can still search
-- for files with the generic binding even when i'm not in a git repository
function M.find_files_prefer_git()
    local git_dir = vim.fn.getcwd() .. '/.git'
    -- not sure why i have to do `== 0` here...
    if vim.fn.isdirectory(git_dir) == 0 then
        return require('telescope.builtin').find_files()
    end

    return require('telescope.builtin').git_files()
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
