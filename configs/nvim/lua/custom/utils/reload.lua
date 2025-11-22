local M = {}

M.reload = function()
  local modules_to_reload = {
    'custom.keymaps',
    'custom.plugins',
    'custom.plugin_config.nvimtree',
    'custom.plugin_config.telescope',
  }

  -- Reload init.lua
  dofile(vim.env.MYVIMRC)

  -- Unload and re-require modules
  for _, module in ipairs(modules_to_reload) do
    package.loaded[module] = nil
  end

  require 'custom.keymaps'
  require 'custom.plugins'
  require('custom.plugin_config.telescope').setup()

  print '🔁 Reload complete: init.lua + modules ✔️'
end

return M
