augroup vim-highlight-on-yank
    autocmd!
    autocmd TextYankPost * lua vim.highlight.on_yank {on_visual = false}
augroup END

augroup vim-toggle-list-option
    autocmd!
    autocmd BufRead,BufNewFile * setlocal list
    " gofmt uses tabs and I only want them showing when I should convert them
    " to spaces
    autocmd BufRead,BufNewFile *.go setlocal nolist
augroup END
