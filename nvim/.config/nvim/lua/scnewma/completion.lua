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