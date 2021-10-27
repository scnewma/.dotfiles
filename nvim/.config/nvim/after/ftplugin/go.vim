command! -nargs=* -range GoAddTags lua require('go-tools').add_tags({<line1>, <line2>, <f-args>})
command! -nargs=* -range GoRemoveTags lua require('go-tools').remove_tags({<line1>, <line2>, <f-args>})
