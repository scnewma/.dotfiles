local plug_fpath = vim.fn.stdpath('config') .. '/autoload/plug.vim'

local download_plug = function()
    if vim.fn.input("Download Plug? (y for yes) ") ~= "y" then
        return
    end

    local out = vim.fn.system(string.format(
        "curl -fLo %s --create-dirs %s",
        plug_fpath,
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    ))

    print(out)
    print("Downloading vim-plug...")
    print("( You'll need to restart now )")
end

return function()
    if not vim.fn.filereadable(plug_fpath) then
        download_plug()

        return true
    end

    return false
end
