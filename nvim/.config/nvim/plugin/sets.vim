set guicursor=
set number
set relativenumber
set nohlsearch
set ignorecase
set smartcase
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nobackup
set nowritebackup
set noswapfile
set undolevels=1000
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=2
set history=200
set wildmenu
set wildmode=full
set updatetime=300
set autowrite
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set backspace=indent,eol,start
set shortmess+=c
set signcolumn=yes
set mousemodel=popup
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set statusline=\ %f%m%r%h%w%=\ %{fugitive#statusline()}\ \|\ %p%%\ \|\ L%l:%c\ 

if exists('$SHELL')
	set shell=$SHELL
else
	set shell=/bin/sh
endif
