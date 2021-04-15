local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                -- do not exit to normal mode in prompt
                ["<esc>"] = actions.close,

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
    if vim.fn.isdirectory(git_dir) == 0 then
        return require('telescope.builtin').find_files()
    end

    return require('telescope.builtin').git_files()
end

-- use an rg wrapper script if it's where it's expected to be. this wrapper
-- script automatically sets RIPGREP_CONFIG_PATH if a .ripgreprc file is found
-- so that grepping is customizable and works the same in zsh as it does in nvim
local rgexec = "rg"
do
    local rgfuncpath = vim.env.HOME .. '/.config/zsh/functions/rg'
    if vim.fn.filereadable(rgfuncpath) then
        rgexec = rgfuncpath
    end
end

function M.grep_string_prompt()
    require('telescope.builtin').grep_string {
        shorten_path = true,
        search = vim.fn.input("Grep for > "),
        vimgrep_arguments =
            {rgexec, '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'},
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
