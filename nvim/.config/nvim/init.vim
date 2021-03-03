let mapleader="\<SPACE>"

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(expand('~/.config/nvim/plugged'))
Plug 'sainnhe/gruvbox-material'

" nvim-telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-project.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
" substitution for abbreviations, case-respecting replacement
Plug 'tpope/vim-abolish'

" argument text objects
Plug 'b4winckler/vim-angry'

" allows forward searching for text objects among other things
Plug 'wellle/targets.vim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'

"   Lua LSP
Plug 'tjdevries/nlua.nvim'
Plug 'euclidianAce/BetterLua.vim' " better syntax highlighting

" Languages
Plug 'hashivim/vim-terraform'
Plug 'google/vim-jsonnet'
Plug 'jjo/vim-cue'
Plug 'stephpy/vim-yaml'

call plug#end()

lua << EOF
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Mappings
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'g<C-d>', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    --      code-rename
    buf_set_keymap('n', '<Leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<Leader>cR', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    --      automatic formatting
    if vim.tbl_contains({"go"}, filetype) then
        vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
    end

    --      completion
    require('completion').on_attach(client)
end

local codelens_capabilities = vim.lsp.protocol.make_client_capabilities()
codelens_capabilities.textDocument.codeLens = {
    dynamicRegistration = false,
}

lspconfig.gopls.setup{
    on_attach = on_attach,

    capabilities = codelens_capabilities,

    settings = {
        gopls = {
            codelenses = { test = true },
        }
    }
}

-- Overwrite of defaults for nlua.lsp.nvim
local sumneko_command = function()
  local cache_location = vim.fn.stdpath('cache')

  -- this needed to be updated 
  local bin_location = jit.os
  if bin_location == "OSX" then
      bin_location = "macOS"
  end

  return {
    string.format(
      "%s/lspconfig/sumneko_lua/lua-language-server/bin/%s/lua-language-server",
      cache_location,
      bin_location
    ),
    "-E",
    -- also needed to remove extra nvim in this path
    string.format(
      "%s/lspconfig/sumneko_lua/lua-language-server/main.lua",
      cache_location
    ),
  }
end

require('nlua.lsp.nvim').setup(lspconfig, {
    on_attach = on_attach,

    cmd = sumneko_command(),

    globals = {
        -- Colorbuddy
        "Color", "c", "Group", "g", "s",
    }
})
EOF
