" command! -nargs=* -range GoAddTags lua require('go-tools').add_tags({<line1>, <line2>, <f-args>})
" command! -nargs=* -range GoRemoveTags lua require('go-tools').remove_tags({<line1>, <line2>, <f-args>})

autocmd BufWritePre *.go :silent! lua require("go.format").goimport()

nmap <Leader>faa :GoAlt<CR>
nmap <Leader>fas :GoAltS<CR>
nmap <Leader>fav :GoAltV<CR>
