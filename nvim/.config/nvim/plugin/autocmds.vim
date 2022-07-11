augroup vim-highlight-on-yank
    autocmd!
    autocmd TextYankPost * lua vim.highlight.on_yank()
augroup END

augroup vim-toggle-list-option
    autocmd!
    autocmd BufRead,BufNewFile * setlocal list
    " gofmt uses tabs and I only want them showing when I should convert them
    " to spaces
    autocmd BufRead,BufNewFile *.go setlocal nolist
augroup END

" automatically rebalance windows on vim resize
augroup vim-win-balance-resize
    autocmd!
    autocmd VimResized * :wincmd =
augroup END

" remember cursor position
augroup vim-remember-cursor
    autocmd!
    autocmd BufReadPost * lua require('scnewma/utils').RestoreCursorPos()
augroup END

augroup vimrc-incsearch-highlight
    autocmd!
    autocmd CmdlineEnter /,\? :set hlsearch
    autocmd CmdlineLeave /,\? :set nohlsearch
augroup END
