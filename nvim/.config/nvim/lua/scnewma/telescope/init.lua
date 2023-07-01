local actions = require('telescope.actions')

-- use an rg wrapper script if it's where it's expected to be. this wrapper
-- script automatically sets RIPGREP_CONFIG_PATH if a .ripgreprc file is found
-- so that grepping is customizable and works the same in zsh as it does in nvim
local rgexec = "rg"
do
    local rgfuncpath = vim.env.HOME .. '/.dotfiles/scripts/rg.sh'
    if vim.fn.filereadable(rgfuncpath) == 1 then
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
                -- change split horizontal to <C-s>
                ["<C-x>"] = false,
                ["<C-s>"] = actions.select_horizontal,
            }
        },

        preview = {
            filesize_limit = 1,
            timeout = 1000,
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
        },

        file_browser = {
            -- show hidden files by default, toggle with <C-h>
            hidden = true,
        }
    }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

local M = {}

function M.edit_dotfiles()
    M.git_files {
        prompt_title = "~ dotfiles ~",
        cwd = "~/.dotfiles",
    }
end

-- default to show_untracked = true
function M.git_files(opts)
    opts = opts or {}
    if opts.show_untracked == nil then
        opts.show_untracked = true
    end

    require('telescope.builtin').git_files(opts)
end

-- this is used on my <SPC><SPC> binding to ensure that i can still search
-- for files with the generic binding even when i'm not in a git repository
function M.find_files_prefer_git()
    local git_dir = vim.fn.getcwd() .. '/.git'
    if vim.fn.isdirectory(git_dir) == 0 then
        return require('telescope.builtin').find_files()
    end

    return M.git_files()
end

function M.grep_string_prompt()
    require('telescope.builtin').grep_string {
        path_display = { "shorten" },
        search = vim.fn.input("Grep for > "),
        vimgrep_arguments = {rgexec, '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'},
    }
end

-- live_grep, but only search specific file types
-- see `rg --type-list` for possible values for type_filter
function M.live_grep_type(opts)
    opts = opts or {}
    local type_filter = opts.type_filter or vim.fn.input('Type > ')
    require('telescope.builtin').live_grep {
        type_filter = type_filter,
    }
end

-- thanks TJ
function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  local register = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", "")

  opts.path_display = { "shorten" }
  opts.word_match = "-w"
  opts.search = register

  require("telescope.builtin").grep_string(opts)
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
