augroup vim-highlight-on-yank
    autocmd!
    autocmd TextYankPost * lua vim.highlight.on_yank {on_visual = false}
augroup END
