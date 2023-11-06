local opt = vim.opt

opt.guicursor=""
opt.number=true
opt.relativenumber=true
opt.hlsearch=false
opt.ignorecase=true
opt.smartcase=true
opt.hidden=true
opt.errorbells=false
opt.tabstop=4
opt.softtabstop=4
opt.shiftwidth=4
opt.expandtab=true
opt.smartindent=true
opt.backup=false
opt.writebackup=false
opt.swapfile=false
opt.undolevels=1000
opt.undodir=vim.fn.expand("~/.vim/undodir")
opt.undofile=true
opt.incsearch=true
opt.termguicolors=true
opt.scrolloff=1
opt.history=200
opt.wildmenu=true
opt.wildmode="full"
opt.updatetime=300
opt.autowrite=true
opt.encoding="utf-8"
-- lazy.nvim fails first install with an error if this is set
-- opt.fileencoding="utf-8"
opt.fileencodings="utf-8"
opt.backspace={"indent","eol","start"}
opt.signcolumn="yes"
opt.mousemodel="popup"
opt.modeline=true
opt.modelines=10
opt.title=true
opt.titleold="Terminal"
opt.titlestring="%F"
opt.listchars={ trail = "·", tab = "»·" }
opt.mouse="a"
opt.splitbelow=true
opt.splitright=true
opt.formatoptions="jcql"

vim.cmd [[set statusline=\ %f%m%r%h%w%=\ \|\ %p%%\ \|\ L%l:%c\ ]]

vim.g.markdown_fenced_languages = {
    "ts=typescript"
}

opt.shell = "/bin/sh"
if vim.env.SHELL then
    opt.shell = vim.env.SHELL
end
