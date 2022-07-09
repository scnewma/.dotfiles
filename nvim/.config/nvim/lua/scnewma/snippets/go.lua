return {
    s('main', fmt([[
        package main

        func main() {{
            {}
        }}
    ]], { i(0) })),
}, {
    s('errn', fmt([[
        if {} != nil {{
            return {}
        }}
    ]], {
        i(1, 'err'),
        dl(2, l._1, 1),
    })),

    s('errw', fmt([[
        if {} != nil {{
            return fmt.Errorf("{}: %w", {})
        }}
    ]], {
        i(1, 'err'),
        i(2),
        dl(3, l._1, 1),
    })),

    s('tyi', fmt([[
        type {} interface {{
            {}
        }}
    ]], { i(1), i(0) })),

    s('tys', fmt([[
        type {} struct {{
            {}
        }}
    ]], { i(1), i(0) })),

    s('tyf', fmt('type {} func({}) {}', { i(1), i(2), i(0) })),

    s('fnx', fmt([[
        func {}({}) {} {{
            {}
        }}
    ]], { i(1), i(2), i(3), i(0) })),

    s('meth', fmt([[
        func ({}) {}({}) {} {{
            {}
        }}
    ]], { i(1), i(2), i(3), i(4), i(0) }),
    { condition = conds.line_begin }),

    s('swx', fmt([[
        switch {} {{
        case {}:
            {}
        }}
    ]], { i(1), i(2), i(0) })),

    s('forr', fmt([[
        for {}, {} := range {} {{
            {}
        }}
    ]], { i(1, '_'), i(2), i(3), i(0) })),

    s('fori', fmt([[
        for {} := {}; {} < {}; {}++ {{
            {}
        }}
    ]], {
        i(1, 'i'), i(2, '0'), rep(1),
        c(3, {
            sn(nil, fmt('len({})', { i(1) })),
            i(),
        }),
        rep(1), i(0),
    })),

    s('mapx', fmt(
        'map[{}]{}{{}}',
        { i(1, 'string'), i(2, 'string') }
    )),

    s('mapv', fmt(
        '{} := map[{}]{}{{}}',
        { i(1, 'm'), i(2, 'string'), i(3, 'string') }
    )),

    s('mapk', fmt([[
        if {}, ok := {}[{}]; ok {{
            {}
        }}
    ]], { i(1, 'v'), i(2, 'm'), i(3, 'k'), i(0) })),

    s('ifx', fmt([[
        if {} {{
            {}
        }}
    ]], { i(1, 'true'), i(0) })),

    s('ifv', fmt([[
        if {} := {}; {} {{
            {}
        }}
    ]], { i(1, 'v'), i(2), dl(3, l._1, 1), i(0) })),

    s('pfx', fmt(
        'fmt.Printf("{}{}", {})',
        { i(1, '%v'), i(2, '\\n'), i(3) }
    ), { condition = conds.line_begin }),

    s('pnx', fmt(
        'fmt.Println("{}")',
        { i(1, 'msg') }
    ), { condition = conds.line_begin }),

    s('tfx', fmt([[
        func Test{}(t *testing.T) {{
            {}
        }}
    ]], { i(1), i(2) }), { condition = conds.line_begin }),
}
