local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local fmt = require("luasnip.extras.fmt").fmt
-- local m = require("luasnip.extras").m
-- local lambda = require("luasnip.extras").l
-- local postfix = require("luasnip.extras.postfix").postfix

-- duplicate the value from another index within snippet
local same = function(index)
  return f(function(args)
    return args[1]
  end, { index })
end

-- represents a newline in a text snippet
-- more understandable that just an empty string
local NL = ''

ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
}

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

vim.keymap.set('n', '<leader>rs', '<cmd>source ~/.config/nvim/lua/scnewma/snippets.lua<CR>')

-- clear existing snippets before re-adding
ls.cleanup()

ls.add_snippets("all", {
})

ls.add_snippets('sh', {
    s('sh', {
        t({ '#!/bin/bash', NL, 'set -euo pipefail', NL, NL }),
    }),
})

ls.add_snippets('go', {
    -- main function
    s('main', {
        t { 'package main', NL, 'func main() {', '\t', },
        i(0),
        t { NL, '}' },
    }),

    -- declare interface
    s('tyi', {
        t('type '),
        i(1),
        t { ' interface {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- declare struct
    s('tys', {
        t('type '),
        i(1),
        t { ' struct {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- declare function type
    s('tyf', {
        t('type '),
        i(1),
        t(' func('),
        i(2),
        t(') '),
        i(0),
    }),

    -- func(...) ... { ... }
    s('func', {
        t('func '),
        i(1),
        t('('),
        i(2),
        t(') '),
        i(3),
        t { ' {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- func (r *recv) Name(args) RET { ... }
    s('meth', {
        t('func ('),
        i(1),
        t(') '),
        i(2),
        t('('),
        i(3),
        t(') '),
        i(4),
        t { ' {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- switch ... {
    -- case ...:
    --     ...
    -- }
    s('switch', {
        t('switch '),
        i(1),
        t { ' {', 'case ' },
        i(2),
        t { ':', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- case ...:
    --    ...
    s('case', {
        t('case '),
        i(1),
        t { ':', '\t' },
        i(0),
    }),

    -- for _, i := range items { ... }
    s('forr', {
        t('for '),
        i(1, '_'),
        t(', '),
        i(2),
        t(' := range '),
        i(3),
        t { ' {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- for i := 0; i < len(...); i++ { ... }
    s('fori', {
        t('for '),
        i(1, 'i'),
        t(' := '),
        i(2, '0'),
        t('; '),
        same(1),
        t(' < '),
        c(3, {
            sn(nil, { t('len('), i(1), t(')') }), -- len of slice
            i(), -- input your own
        }),
        t('; '),
        same(1),
        t { '++ {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- map[type]type{}
    s('map', {
        t('map['),
        i(1, 'string'),
        t(']'),
        i(2, 'string'),
        t('{}'),
    }),

    -- m := map[type]type{}
    s('mapv', {
        i(1, 'm'),
        t(' := map['),
        i(2, 'string'),
        t(']'),
        i(3, 'string'),
        t('{}'),
    }),

    -- if v, ok := map[key]; ok { ... }
    s('mok', {
        t('if '),
        i(1, 'v'),
        t(', ok := '),
        i(2, 'm'),
        t('['),
        i(3, 'key'),
        t { ']; ok {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- if condition { ... }
    s('if', {
        t('if '),
        i(1, 'true'),
        t { ' {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- if v := statement; v { ... }
    s('ifv', {
        t('if '),
        i(1, 'v'),
        t(' := '),
        i(2),
        t('; '),
        -- duplicates the first insert node, but is still itself an
        -- insert node
        d(3, function(args)
            return sn(nil, {
                i(1, args[1])
            })
        end, { 1 }),
        t { ' {', '\t' },
        i(0),
        t { NL, '}' },
    }),

    -- if err != nil { return _, err }
    s('err', {
        t { 'if err != nil {', '\treturn ' },
        i(1),
        -- append comma if first return value is provided
        f(function(args)
            if args[1][1] ~= '' then
                return ','
            else
                return ''
            end
        end, { 1 }),
        t(' '),
        i(2, 'err'),
        t { NL, '}' },
    }),

    -- fmt.Printf("...", ...)
    s('pf', {
        t('fmt.Printf("'),
        i(1, "%v"),
        i(2, '\\n'),
        t('", '),
        i(3),
        t(')'),
    }),

    -- fmt.Println("...")
    s('pn', {
        t('fmt.Println("'),
        i(1, "msg"),
        t('")'),
    }),

    -- func Test...(t *testing.T) { ... }
    s('tf', {
        t('func Test'),
        i(1),
        t { '(t *testing.T) {', '\t' },
        i(0),
        t { NL, '}' },
    }),
})
