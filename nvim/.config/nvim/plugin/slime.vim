let g:slime_target = "tmux"
let g:slime_dont_ask_default = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}

let g:slime_no_mappings = 1
nmap <Leader>ee <Plug>SlimeParagraphSend
nmap <Leader>el <Plug>SlimeLineSend
xmap <Leader>e <Plug>SlimeRegionSend
