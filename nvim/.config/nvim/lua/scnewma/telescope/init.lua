local actions = require('telescope.actions')

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

require('telescope').setup {
    defaults = {
        layout_strategy = 'vertical',
        -- layout_config = {
        --     width = 0.80,
        --     height = 0.75,
        --     prompt_position = "bottom",

        --     horizontal = {
        --         preview_width = function(_, cols, _)
        --             if cols > 200 then
        --                 return math.floor(cols * 0.4)
        --             else
        --                 return math.floor(cols * 0.6)
        --             end
        --         end,
        --     },

        --     vertical = {
        --         width = 0.9,
        --         height = 0.95,
        --         preview_height = 0.5,
        --     },

        --     flex = {
        --         horizontal = {
        --             preview_width = 0.9,
        --         },
        --     },
        -- },

        mappings = {
            i = {
                -- do not exit to normal mode in prompt
                ["<esc>"] = actions.close,

                -- change split horizontal to <C-s>
                ["<C-x>"] = false,
                ["<C-s>"] = actions.select_horizontal,
            }
        },

        vimgrep_arguments = {
            rgexec,
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
        },
    },

    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },

        ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
        }
    }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

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


function M.grep_string_prompt()
    require('telescope.builtin').grep_string {
        path_display = { "shorten" },
        search = vim.fn.input("Grep for > "),
        vimgrep_arguments = {rgexec, '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'},
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
