vim.keymap.set('n', 'gQ', '<Nop>' )
vim.keymap.set('n', '-', '<CMD>Oil<CR>' )
vim.keymap.set('n', '<Leader>fp', function() require("scnewma/project").pick() end )

-- window management
--   split-below-focus
vim.keymap.set('n', '<Leader>ws', '<C-w>s<CR>' )
--   split-below
vim.keymap.set('n', '<Leader>wS', '<C-w>s<C-w>k<CR>' )
--   split-right-focus
vim.keymap.set('n', '<Leader>wv', '<C-w>v<CR>' )
--   split-right
vim.keymap.set('n', '<Leader>wV', '<C-w>v<C-w>h<CR>' )
--   delete-window
vim.keymap.set('n', '<Leader>wd', ':q<CR>' )
--   focus-left
vim.keymap.set('n', '<Leader>wh', '<C-w>h' )
--   focus-down
vim.keymap.set('n', '<Leader>wj', '<C-w>j' )
--   focus-up
vim.keymap.set('n', '<Leader>wk', '<C-w>k' )
--   focus-right
vim.keymap.set('n', '<Leader>wl', '<C-w>l' )
--   focus-only
vim.keymap.set('n', '<Leader>wo', '<C-w>o' )
--   focus-top-left
vim.keymap.set('n', '<Leader>wt', '<C-w>t' )
--   focus-bot-right
vim.keymap.set('n', '<Leader>wb', '<C-w>b' )

-- buffer management
--   delete-buffer
vim.keymap.set('n', '<Leader>bd', ':bdelete<CR>' )
--   next-buffer
vim.keymap.set('n', '<Leader>bn', ':bn<CR>' )
--   previous-buffer
vim.keymap.set('n', '<Leader>bp', ':bp<CR>' )
--   reload-buffer
vim.keymap.set('n', '<Leader>bR', ':bR<CR>' )


-- toggles
--   toggle-line-numbers
vim.keymap.set('n', '<Leader>tn', ':set number!<CR>' )
--   toggle-line-wrap
vim.keymap.set('n', '<Leader>tl', ':set wrap!<CR>' )

-- random
--   yank-to-eol
vim.keymap.set('n', 'Y', 'y$' )

-- interact with system clipboard
vim.keymap.set('n', '<Leader>p', '"*p' )
vim.keymap.set('v', '<Leader>p', '"*p' )
vim.keymap.set('n', '<Leader>P', '"*P' )
vim.keymap.set('v', '<Leader>P', '"*P' )
vim.keymap.set('n', '<Leader>y', '"*y' )
vim.keymap.set('n', '<Leader>Y', '"*y$' )
vim.keymap.set('v', '<Leader>y', '"*y' )

-- blackhole register FTW!!
vim.keymap.set('n', '<Leader>d', '"_d' )
vim.keymap.set('v', '<Leader>d', '"_d' )

-- Easier remap for accessing alternate file. Neither ^ or 6 are easy
-- to hit on my keyboard layout.
vim.keymap.set('n', '<Leader>a', '<C-^>' )

-- Easier quickfix list navigation
vim.keymap.set('n', ']q', ':cnext<CR>' )
vim.keymap.set('n', '[q', ':cprev<CR>' )

-- Easier location list navigation
vim.keymap.set('n', ']l', ':lnext<CR>' )
vim.keymap.set('n', '[l', ':lprev<CR>' )

-- Rename word under cursor on this line
vim.keymap.set('n', '<Leader>rl', ':s/\\<<C-r><C-w>\\>//g<Left><Left>' )
-- Rename word under cursor in this buffer
vim.keymap.set('n', '<Leader>rb', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>' )
-- Rename word under cursor in this buffer, with confirmation
vim.keymap.set('n', '<Leader>rB', ':%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>' )

-- Quickly insert the previously yanked text.
vim.keymap.set('i', '<C-]>', '<C-g>u<C-r>0' )
vim.keymap.set('c', '<C-]>', '<C-r>0' )

-- Start a new change before pasting from register so it's easily undoable
vim.keymap.set('i', '<C-r>', '<C-g>u<C-r>' )

-- Split line moving to the right of the cursor upward
vim.keymap.set('n', '<Leader><C-j>', 'DO<Esc>pj:s/\\s\\+$//<CR>' )

vim.keymap.set('n', '<Leader>fE', '<cmd>:e ~/.dotfiles/nvim/.config/nvim/lua/scnewma/plugins/init.lua<CR>' )

-- expands %% into the relative directory of the current buffer in cmd mode
vim.keymap.set('c',
    '%%',
    function ()
        if vim.fn.getcmdtype() == ':' then
            return vim.fn.expand('%:h') .. '/'
        else
            return '%%'
        end
    end,
    { expr = true }
)

-- Maps <CR> to :write, which saves the file. This mapping only
-- executes when in a normal buffer to avoid breaking things like the
-- terminal or quickfix list
vim.keymap.set('n',
    '<CR>',
    function()
        if vim.api.nvim_buf_get_option(0, 'buftype') == "" then
            return ':write<CR>'
        else
            return '<CR>'
        end
    end,
    { silent = true, expr = true }
)

vim.keymap.set('n', 'gp', '`[v`]' )

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
vim.keymap.set('n', 'k', jumplistify('k'), { expr = true })
vim.keymap.set('n', 'j', jumplistify('j'), { expr = true })

-- Close all floating windows when pressing Escape in normal mode
vim.keymap.set('n', '<Esc>',
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
)

vim.keymap.set('n', '<leader>gc', ':r! git log -1 --pretty=\\%B<CR>' )
vim.keymap.set('n', '<leader>jc', ":r! jj log -r @ --no-graph -T'description ++ \"\\n\"'<CR>" )

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
