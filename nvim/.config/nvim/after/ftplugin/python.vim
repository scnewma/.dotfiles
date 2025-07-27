setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=8
autocmd BufWritePre *.py lua vim.lsp.buf.format()
