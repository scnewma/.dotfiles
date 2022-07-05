vim.opt.completeopt = { "menu", "menuone", "noselect" }

local cmp = require("cmp")
local lspkind = require("lspkind")
lspkind.init()

cmp.setup({
    completion = {
        completeopt = "menu,menuone,noinsert",
    },

    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    },

    sources = {
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "vsnip" },
        { name = "buffer", keyword_length = 5, max_item_count = 10 },
    },

    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },

    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            menu = { buffer = "[buf]", nvim_lsp = "[LSP]", nvim_lua = "[api]", path = "[path]", vsnip = "[snip]" }
        }),
    },

    experimental = {
        ghost_text = true,
    }
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' }}))

vim.cmd [[
    imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]]
