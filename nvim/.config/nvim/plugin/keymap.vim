" This is where most of my basic keymaps go.
"
"   Plugin keymaps will all be found in their respective files.

" prevent fat-fingering commands
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

" expands %% into the relative directory of the current buffer in cmd mode
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" file management
nnoremap <Leader>s :w<CR>
nnoremap <Leader>S :wa<CR>

" window management
"   split-below-focus
nnoremap <Leader>ws <C-w>s<C-w>j<CR>
"   split-below
nnoremap <Leader>wS <C-w>s<CR>
"   split-right-focus
nnoremap <Leader>wv <C-w>v<C-w>l<CR>
"   split-right
nnoremap <Leader>wV <C-w>v<CR>
"   delete-window
nnoremap <Leader>wd :q<CR>
"   focus-left
nnoremap <Leader>wh <C-w>h
"   focus-down
nnoremap <Leader>wj <C-w>j
"   focus-up
nnoremap <Leader>wk <C-w>k
"   focus-right
nnoremap <Leader>wl <C-w>l
"   focus-only
nnoremap <Leader>wo <C-w>o

" buffer management
"   find-buffer -- in fuzzy finder .after/plugin/*
"   delete-buffer
nnoremap <Leader>bd :bdelete<CR>
"   next-buffer
nnoremap <Leader>bn :bn<CR>
"   previous-buffer
nnoremap <Leader>bp :bp<CR>
"   reload-buffer
nnoremap <Leader>bR :bR<CR>

" toggles
"   toggle-line-numbers
nnoremap <Leader>tn :set number!<CR>
"   toggle-line-wrap
nnoremap <Leader>tl :set wrap!<CR>

" random
"   yank-to-eol
nnoremap Y y$
