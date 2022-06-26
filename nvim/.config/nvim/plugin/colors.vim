set background=dark
let g:gruvbox_material_background = 'hard' " hard, medium, soft
let g:gruvbox_material_palette = 'mix'
colorscheme gruvbox-material

" makes listchars more visible
highlight Whitespace guifg='#af2528' ctermfg='88'

" make popup same color as terminal background
"   separation is made with a border
highlight! NormalFloat ctermfg=223 ctermbg=235 guifg=#e2cca9 guibg=#282828
