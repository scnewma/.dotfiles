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
        ["<C-n>"] = cmp.mapping.confirm({ select = true }),
        ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    },

    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },

    sources = {
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer", keyword_length = 5, max_item_count = 10 },
    },

    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
            },
        }),
    },

    experimental = {
        ghost_text = true,
    }
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' }}))
