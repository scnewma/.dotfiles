-- This will be available for everyone when tj merges:
--  https://github.com/neovim/neovim/pull/13479
-- Until then, it is patched here `./lua/scnewma/globals/opt.lua
local opt = vim.opt

opt.guicursor=""
opt.number=true
opt.relativenumber=true
opt.hlsearch=false -- TODO: is this the same as :set nohlsearch
opt.ignorecase=true
opt.smartcase=true
opt.hidden=true
opt.errorbells=false -- TODO: is this the same as :set noerrorbells
opt.tabstop=4 
opt.softtabstop=4
opt.shiftwidth=4
opt.expandtab=true
opt.smartindent=true
opt.backup=false -- TODO: nobackup
opt.writebackup=false -- TODO: nowritebackup
opt.swapfile=false -- TODO: noswapfile
opt.undolevels=1000
opt.undodir="~/.vim/undodir"
opt.undofile=true
opt.incsearch=true
opt.termguicolors=true
opt.scrolloff=2
opt.history=200
opt.wildmenu=true
opt.wildmode="full"
opt.updatetime=300
opt.autowrite=true
opt.encoding="utf-8"
opt.fileencoding="utf-8"
opt.fileencodings="utf-8"
opt.backspace={"indent","eol","start"}
-- TODO: move to completion
vim.cmd [[set shortmess+=c]]
opt.signcolumn="yes"
opt.mousemodel="popup"
opt.modeline=true
opt.modelines=10
opt.title=true
opt.titleold="Terminal"
opt.titlestring="%F"

vim.cmd [[set statusline=\ %f%m%r%h%w%=\ %{fugitive#statusline()}\ \|\ %p%%\ \|\ L%l:%c\ ]]

opt.shell = "/bin/sh"
if vim.env.SHELL then
    opt.shell = vim.env.SHELL
end
