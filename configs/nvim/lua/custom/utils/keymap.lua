local M = {}

local opts = { noremap = true, silent = true }

-- Generic map function with description
function M.defaultMap(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
end

return M
