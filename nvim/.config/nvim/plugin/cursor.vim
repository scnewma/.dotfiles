" remember cursor position
augroup vim-remember-cursor
    autocmd!
    autocmd BufReadPost * lua require('scnewma/utils').RestoreCursorPos()
augroup END
