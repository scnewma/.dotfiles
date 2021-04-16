-- Source: https://github.com/tjdevries/config_manager/blob/4b6a08028914644f9390c913bd5c18e354bea6ff/xdg_config/nvim/lua/tj/globals/init.lua

P = function(v)
  print(vim.inspect(v))
  return v
end

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

-- `vim.opt`
require('scnewma.globals.opt')

