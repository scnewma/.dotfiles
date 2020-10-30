"*****************************************************************************
"" Vim-PLug core
"*****************************************************************************
if has('vim_starting')
  set nocompatible               " Be iMproved
endif

let vimplug_exists=expand('~/.vim/autoload/plug.vim')

if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.vim/plugged'))

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sheerun/vim-polyglot'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'b4winckler/vim-angry'
Plug 'junegunn/vim-easy-align'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'wellle/targets.vim'
Plug 'tpope/vim-abolish'
Plug 'hashivim/vim-terraform'
Plug 'mhinz/vim-startify'

Plug 'janko/vim-test'
Plug 'jgdavey/tslime.vim'

"" Color
Plug 'tomasr/molokai'
Plug 'joshdick/onedark.vim'

"*****************************************************************************
"" Custom bundles
"*****************************************************************************

" go
"" Go Lang Bundle
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoInstallBinaries' }

Plug 'stephpy/vim-yaml', { 'for': 'yaml' }

"*****************************************************************************
"*****************************************************************************

call plug#end()

" Required:
filetype plugin indent on

runtime macros/matchit.vim

"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
set history=200

set wildmenu
set wildmode=full

set updatetime=300

" automatically write when calling 'make', 'GoBuild', etc...
set autowrite

"" Disable octal number formats
set nrformats-=octal

"" Disable Ex-Mode
map Q <Nop>

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set bomb
set binary
set ttyfast

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" Map leader to ,
let mapleader = "\<SPACE>"
let maplocalleader = ","

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Directories for swp files
set nobackup
set nowritebackup
set noswapfile

set fileformats=unix,dos,mac

if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

"" expands %% into the relative directory of the current buffer in cmd mode
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

"" disable beeping
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

"" F5 will toggle paste mode
set pastetoggle=<f5>

"" persistent undo history
set undolevels=1000
if has('persistent_undo')
    set undodir=~/.local/share/vim/undo
    set undofile
endif

nnoremap Y y$

"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler
set number
set relativenumber

set shortmess+=c
set signcolumn=yes

let no_buffers_menu=1
" if !exists('g:not_finish_vimplug')
"   let g:rehash256 = 1
"   let g:molokai_original = 1
"   colorscheme molokai
" endif
colorscheme onedark

set mousemodel=popup
set t_Co=256
set guioptions=egmrti
set gfn=Monospace\ 10

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
  else
    if $TERM == 'xterm'
      set term=xterm-256color
    endif
  endif
  
endif


if &term =~ '256color'
  set t_ut=
endif


"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=1

"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" Change color of matched pair
hi MatchParen ctermbg=lightblue guibg=lightblue

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
" nnoremap n nzzzv
" nnoremap N Nzzzv

if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif

" vim-airline
let g:airline_theme = 'minimalist'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_skip_empty_sections = 1

"*****************************************************************************
"" Abbreviations
"*****************************************************************************
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

"*****************************************************************************
"" Functions
"*****************************************************************************
if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif

function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
        call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
        call go#cmd#Build(0)
    endif
endfunction

"*****************************************************************************
"" Autocmd Rules
"*****************************************************************************
"" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

"" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=200
augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"" txt
augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

augroup vimrc-incsearch-highlight
  autocmd!
  autocmd CmdlineEnter /,\? :set hlsearch
  autocmd CmdlineLeave /,\? :set nohlsearch
augroup END

set autoread

"*****************************************************************************
"" Mappings
"*****************************************************************************
function Keyboard(type)
    if a:type == "workman"
        set langmap=qq,dw,re,wr,bt,jy,fu,ui,po,\\;p,aa,ss,hd,tf,gg,yh,nj,ek,ol,i\\;,zz,xx,mc,cv,vb,kn,lm,QQ,DW,RE,WR,BT,JY,FU,UI,PO,:P,AA,SS,HD,TF,GG,YH,NJ,EK,OL,I:,ZZ,XX,MC,CV,VB,KN,LM
    else " qwerty
        set langmap=aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,ll,mm,nn,oo,pp,qq,rr,ss,tt,uu,vv,ww,xx,yy,zz,AA,BB,CC,DD,EE,FF,GG,HH,II,JJ,KK,LL,MM,NN,OO,PP,QQ,RR,SS,TT,UU,VV,WW,XX,YY,ZZ,\\;\\;,::
    endif
endfunction

" autocmd VimEnter * call Keyboard("workman")

:noremap <Leader>w :call Keyboard("workman")<CR>:echom "Workman Keyboard Layout"<CR>

" pbcopy for OSX copy/pasbegin-selectionte
vnoremap <C-x> :!pbcopy<CR>
vnoremap <C-c> :w !pbcopy<CR><CR>

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"*****************************************************************************
"" Spacemacs Bindings
"*****************************************************************************

" editor file
nnoremap <Leader>fed :e $MYVIMRC<CR>
nnoremap <Leader>feR :source $MYVIMRC<CR>

" windows
nnoremap <Leader>ws <C-w>s<C-w>j<CR>
nnoremap <Leader>wv <C-w>v<C-w>l<CR>
nnoremap <Leader>wS <C-w>s
nnoremap <Leader>wV <C-w>v
nnoremap <Leader>wd :q<CR>
nnoremap <Leader>wq :q<CR>
nnoremap <Leader>wh <C-w>h
nnoremap <Leader>wj <C-w>j
nnoremap <Leader>wk <C-w>k
nnoremap <Leader>wl <C-w>l
nnoremap <Leader>wo <C-w>o

" buffers
" nnoremap <Leader>bb :buffers<CR>:buffer<Space> 
nnoremap <Leader>bd :bdelete<CR>
nnoremap <Leader>bk :bdelete<CR>
nnoremap <Leader>bn :bn<CR>
nnoremap <Leader>bp :bp<CR>
nnoremap <Leader>bR :e<CR>

" files
nnoremap <Leader>ff :e <C-R>=substitute(expand("%:p:h"), $HOME, "~", "")<CR>/

" save
nnoremap <Leader>s :w<CR>
nnoremap <Leader>S :wa<CR>

" projects
nnoremap <Leader>pf :e 

" toggles
nnoremap <Leader>tn :set number!<CR>
nnoremap <Leader>tl :set wrap!<CR>

" help
nnoremap <Leader>h :help 

"" Plugins

" CtrlP
nnoremap <Leader><Space> :CtrlPRoot<CR>
nnoremap <Leader>bb :CtrlPBuffer<CR>

" Fugitive
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gf :Gpull<CR>
nnoremap <Leader>gl :Glog<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gm :Gmove 

"*****************************************************************************
"" Custom configs
"*****************************************************************************

" ale
let g:ale_linters = {'go': ['gopls']}
let g:ale_linters_explicit = 1
let g:ale_go_golangci_lint_options = '
    \ --fast
    \ --enable=golint
    \ --enable=misspell
    \ --disable=errcheck
    \'
let g:ale_go_golangci_lint_package = 1
let g:ale_set_signs = 0

" vim-test
nmap <silent> <localleader>tt :TestNearest<cr>
nmap <silent> <localleader>t :TestFile<cr>
nmap <silent> <localleader>tv <Plug>SetTmuxVars
let test#strategy = "tslime"

" vim-go
let g:go_fmt_command = "goimports"
let g:go_addtags_transform = "snakecase"
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_build_tags = "integration"
let g:go_info_mode = "gopls"
let g:go_def_mode = "gopls"
let g:go_code_completion_enabled = 0

augroup go
    autocmd!

    autocmd FileType go nmap <localleader>r <Plug>(go-run)
    " autocmd FileType go nmap <localleader>t <Plug>(go-test)
    " autocmd FileType go nmap <localleader>tf <Plug>(go-test-func)
    autocmd FileType go nmap <localleader>c  <Plug>(go-coverage-toggle)
    autocmd FileType go nmap <localleader>i <Plug>(go-info)
    autocmd FileType go nmap <localleader>b :<C-u>call <SID>build_go_files()<CR>
    autocmd FileType go nmap <localleader>d <Plug>(go-doc)
    autocmd FileType go nmap <localleader>a :GoAlternate<CR>
    autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
augroup END

" CtrlP
let g:ctrlp_show_hidden = 1
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" UltiSnips
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"

augroup yaml
    autocmd!

    autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab
augroup END

" Align GitHub-flavored Markdown tables
augroup markdown
    autocmd!

    autocmd FileType markdown vmap <localleader>f :EasyAlign*<Bar><Enter>
augroup END

" vim-which-key
nnoremap <silent> <Leader> :WhichKey '<Space>'<CR>

"*****************************************************************************
"" Convenience variables
"*****************************************************************************

" vim-terraform
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" vim-airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

