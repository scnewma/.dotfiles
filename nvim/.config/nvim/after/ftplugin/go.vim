" command! -nargs=* -range GoAddTags lua require('go-tools').add_tags({<line1>, <line2>, <f-args>})
" command! -nargs=* -range GoRemoveTags lua require('go-tools').remove_tags({<line1>, <line2>, <f-args>})

augroup go-format-on-save
    autocmd!
    autocmd BufWritePre *.go :silent! lua require("go.format").goimports()
augroup END

nmap <Leader>faa :GoAlt<CR>
nmap <Leader>fas :GoAltS<CR>
nmap <Leader>fav :GoAltV<CR>
nmap <Leader>o :lua require('scnewma.lsp.go').go_pkg_doc_open()<CR>

" delete formatprg that nvim sets, I want to be able to use gqq to set line
" length!
" https://github.com/neovim/neovim/blob/ea2d226df6f344451306274f3f99911d459fb9dd/runtime/ftplugin/go.vim#L21
setlocal formatprg=
