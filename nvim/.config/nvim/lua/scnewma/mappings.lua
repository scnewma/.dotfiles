local nmap = require('scnewma.keymap').nmap
local inoremap = require('scnewma.keymap').inoremap
local nnoremap = require('scnewma.keymap').nnoremap
local vnoremap = require('scnewma.keymap').vnoremap
local cnoremap = require('scnewma.keymap').cnoremap

nmap { 'gQ', '<Nop>' }
nmap { '-', '<CMD>Oil<CR>' }
nmap { '<Leader>fp', function() require("scnewma/project").pick() end }

-- window management
--   split-below-focus
nnoremap { '<Leader>ws', '<C-w>s<CR>' }
--   split-below
nnoremap { '<Leader>wS', '<C-w>s<C-w>k<CR>' }
--   split-right-focus
nnoremap { '<Leader>wv', '<C-w>v<CR>' }
--   split-right
nnoremap { '<Leader>wV', '<C-w>v<C-w>h<CR>' }
--   delete-window
nnoremap { '<Leader>wd', ':q<CR>' }
--   focus-left
nnoremap { '<Leader>wh', '<C-w>h' }
--   focus-down
nnoremap { '<Leader>wj', '<C-w>j' }
--   focus-up
nnoremap { '<Leader>wk', '<C-w>k' }
--   focus-right
nnoremap { '<Leader>wl', '<C-w>l' }
--   focus-only
nnoremap { '<Leader>wo', '<C-w>o' }
--   focus-top-left
nnoremap { '<Leader>wt', '<C-w>t' }
--   focus-bot-right
nnoremap { '<Leader>wb', '<C-w>b' }

-- buffer management
--   delete-buffer
nnoremap { '<Leader>bd', ':bdelete<CR>' }
--   next-buffer
nnoremap { '<Leader>bn', ':bn<CR>' }
--   previous-buffer
nnoremap { '<Leader>bp', ':bp<CR>' }
--   reload-buffer
nnoremap { '<Leader>bR', ':bR<CR>' }


-- toggles
--   toggle-line-numbers
nnoremap { '<Leader>tn', ':set number!<CR>' }
--   toggle-line-wrap
nnoremap { '<Leader>tl', ':set wrap!<CR>' }

-- random
--   yank-to-eol
nnoremap { 'Y', 'y$' }

-- interact with system clipboard
nnoremap { '<Leader>p', '"*p' }
vnoremap { '<Leader>p', '"*p' }
nnoremap { '<Leader>P', '"*P' }
vnoremap { '<Leader>P', '"*P' }
nnoremap { '<Leader>y', '"*y' }
nnoremap { '<Leader>Y', '"*y$' }
vnoremap { '<Leader>y', '"*y' }

-- blackhole register FTW!!
nnoremap { '<Leader>d', '"_d' }
vnoremap { '<Leader>d', '"_d' }

-- Easier remap for accessing alternate file. Neither ^ or 6 are easy
-- to hit on my keyboard layout.
nnoremap { '<Leader>a', '<C-^>' }

-- Easier quickfix list navigation
nnoremap { ']q', ':cnext<CR>' }
nnoremap { '[q', ':cprev<CR>' }

-- Easier location list navigation
nnoremap { ']l', ':lnext<CR>' }
nnoremap { '[l', ':lprev<CR>' }

-- Rename word under cursor on this line
nnoremap { '<Leader>rl', ':s/\\<<C-r><C-w>\\>//g<Left><Left>' }
-- Rename word under cursor in this buffer
nnoremap { '<Leader>rb', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>' }
-- Rename word under cursor in this buffer, with confirmation
nnoremap { '<Leader>rB', ':%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>' }

-- Quickly insert the previously yanked text.
inoremap { '<C-]>', '<C-g>u<C-r>0' }
cnoremap { '<C-]>', '<C-r>0' }

-- Start a new change before pasting from register so it's easily undoable
inoremap { '<C-r>', '<C-g>u<C-r>' }

-- Split line moving to the right of the cursor upward
nnoremap { '<Leader><C-j>', 'DO<Esc>pj:s/\\s\\+$//<CR>' }

nnoremap { '<Leader>fE', '<cmd>:e ~/.dotfiles/nvim/.config/nvim/lua/scnewma/plugins/init.lua<CR>' }

-- expands %% into the relative directory of the current buffer in cmd mode
cnoremap {
    '%%',
    function ()
        if vim.fn.getcmdtype() == ':' then
            return vim.fn.expand('%:h') .. '/'
        else
            return '%%'
        end
    end,
    { expr = true },
}

-- Maps <CR> to :write, which saves the file. This mapping only
-- executes when in a normal buffer to avoid breaking things like the
-- terminal or quickfix list
nnoremap {
    '<CR>',
    function()
        if vim.api.nvim_buf_get_option(0, 'buftype') == "" then
            return ':write<CR>'
        else
            return '<CR>'
        end
    end,
    { silent = true, expr = true }
}

nnoremap { 'gp', '`[v`]' }

-- Store relative line number jumps in the jumplist if they are given a count
local function jumplistify(letter)
    return function()
        local motion = ""
        if vim.v.count > 1 then
            motion = "m'" .. vim.v.count
        end
        return motion .. letter
    end
end
nnoremap { 'k', jumplistify('k'), { expr = true } }
nnoremap { 'j', jumplistify('j'), { expr = true } }

-- Close all floating windows when pressing Escape in normal mode
nnoremap { '<Esc>',
    function()
        local windows = vim.api.nvim_list_wins()
        for _, win in ipairs(windows) do
            local config = vim.api.nvim_win_get_config(win)
            -- A window is floating if it has 'relative' set to something other than empty string
            if config.relative and config.relative ~= '' then
                vim.api.nvim_win_close(win, false)
            end
        end
    end,
    { desc = 'Close all floating windows' }
}

-- prevent fat-fingering commands
vim.cmd [[
    cnoreabbrev W! w!
    cnoreabbrev Q! q!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wq wq
    cnoreabbrev Wa wa
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qall qall
]]
