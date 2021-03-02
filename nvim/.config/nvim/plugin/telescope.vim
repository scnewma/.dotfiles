" find-files
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<CR>

" find-files (git-only)
nnoremap <leader><Space> <cmd>lua require('telescope.builtin').git_files()<CR>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').git_files()<CR>

" file-browser
nnoremap <leader>fb <cmd>lue require('telescope.builtin').file_browser()<CR>

" find-buffers
nnoremap <leader>bb <cmd>lua require('telescope.builtin').buffers()<CR>

" search-project-line
nnoremap <leader>sp <cmd>lua require('telescope.builtin').live_grep()<CR>

" search-buffer-line
nnoremap <leader>ss <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>

" search-command-history
nnoremap <leader>sc <cmd>lua require('telescope.builtin').command_history()<CR>

" search-commands
nnoremap <leader>: <cmd>lua require('telescope.builtin').commands()<CR>

" search-help
nnoremap <leader>sh <cmd>lua require('telescope.builtin').help_tags()<CR>

" search-colorscheme
nnoremap <leader>tc <cmd>lua require('telescope.builtin').colorscheme()<CR>
