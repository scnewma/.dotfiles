local M = {}

function M.pick()
    local project_dir = os.getenv("HOME") .. "/dev"

    local fzf_lua = require('fzf-lua')
    local utils = require("fzf-lua.utils")

    local function hl_validate(hl)
        return not utils.is_hl_cleared(hl) and hl or nil
    end

    local function ansi_from_hl(hl, s)
        return utils.ansi_from_hl(hl_validate(hl), s)
    end

    local function expand_project_dir(dir)
        return project_dir .. "/" .. dir
    end

    local opts = {
        fzf_opts = {
            ["--header"] = string.format(
                ":: <%s> %s | <%s> %s | <%s> %s",
                ansi_from_hl("FzfLuaHeaderBind", "cr"),
                ansi_from_hl("FzfLuaHeaderText", "files"),
                ansi_from_hl("FzfLuaHeaderBind", "ctrl-s"),
                ansi_from_hl("FzfLuaHeaderText", "live_grep"),
                ansi_from_hl("FzfLuaHeaderBind", "ctrl-e"),
                ansi_from_hl("FzfLuaHeaderText", "explore")
            ),
        },
        fzf_colors = true,
        fn_transform = function(x)
            -- transform ~/dev/{project}/ to {project}
            x = x:gsub("^" .. project_dir, ""):gsub("^/", ""):gsub("/$", "")
            return fzf_lua.utils.ansi_codes.magenta(x)
        end,
        actions = {
            ["default"] = {
                function(selected)
                    fzf_lua.files({ cwd = expand_project_dir(selected[1]) })
                end,
            },
            ["ctrl-s"] = {
                function(selected)
                    fzf_lua.live_grep({ cwd = expand_project_dir(selected[1]) })
                end,
            },
            ["ctrl-e"] = {
                function(selected)
                    vim.api.nvim_win_close(0, false)
                    vim.cmd("vsplit")
                    require("oil").open(expand_project_dir(selected[1]))
                end,
            },
        }
    }

    fzf_lua.fzf_exec("fd --type d --max-depth 1 . " .. project_dir, opts)
end

return M
