return {
    -- snippets
}, {
    -- autosnippets
    s('#!', fmt([[
        #!/bin/bash

        set -euo pipefail

        {}
    ]], { i(0) }), { condition = conds.line_begin }),
}
