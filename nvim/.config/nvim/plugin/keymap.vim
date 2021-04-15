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

" Maps <CR> to :write, which saves the file. This mapping only executes when
" in a normal buffer to avoid breaking things like the terminal or quickfix
" list
nnoremap <silent> <expr> <CR> empty(&buftype) ? ':write<CR>' : '<CR>'

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
"   focus-top-left
nnoremap <Leader>wt <C-w>t
"   focus-bot-right
nnoremap <Leader>wb <C-w>b

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

"   interact with system clipboard
nnoremap <Leader>p "*p
vnoremap <Leader>p "*p
nnoremap <Leader>P "*P
vnoremap <Leader>P "*P
nnoremap <Leader>y "*y
vnoremap <Leader>y "*y

"   blackhole register FTW!!
nnoremap <Leader>d "_d
vnoremap <Leader>d "_d

" Store relative line number jumps in the jumplist if they are given a count
nnoremap <expr> k (v:count > 1 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 1 ? "m'" . v:count : '') . 'j'

" Easier remap for accessing alternate file. Neither ^ or 6 are easy to hit on
" my keyboard layout.
nnoremap <Leader>a <C-^>

" Easier quickfix list navigation
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>

" Easier location list navigation
nnoremap ]l :lnext<CR>
nnoremap [l :lprev<CR>

" Rename word under cursor on this line
nnoremap <Leader>rl :s/\<<C-r><C-w>\>//g<Left><Left>
" Rename word under cursor in this buffer
nnoremap <Leader>rb :%s/\<<C-r><C-w>\>//g<Left><Left>
" Rename word under cursor in this buffer, with confirmation
nnoremap <Leader>rB :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>

" Quickly insert the previously yanked text.
inoremap <C-]> <C-g>u<C-r>0

" Start a new change before pasting from register so it's easily undoable
inoremap <C-r> <C-g>u<C-r>

" Add newline above/below current cursor; retain cursor position
noremap <Leader>o mlo<Esc>`l
noremap <Leader>O mlO<Esc>`l

" Remove trailing whitespace within current buffer
command! Chomp %s/\s\+$// | normal! ``
nnoremap <Leader>w :Chomp<CR>

" Split line moving to the right of the cursor upward
nnoremap <Leader><C-j> DO<Esc>pj:s/\s\+$//<CR>

" Toggle scratch buffer
nnoremap <Leader>ts :lua require('scnewma/scratch').toggle()<CR>
