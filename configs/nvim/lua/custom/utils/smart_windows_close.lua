local M = {}

M.buffer_is_modified = function()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.bo[bufnr].modified
end

M.is_last_window = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local windows = vim.fn.win_findbuf(bufnr)
  return #windows == 1
end

M.save_buffer_to_closed_buffers = function(closed_buffers)
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  table.insert(closed_buffers, 1, bufname)
  if #closed_buffers > 10 then
    table.remove(closed_buffers)
  end
end

M.smart_windows_close = function(closed_buffers)
  if M.is_last_window() then
    M.save_buffer_to_closed_buffers(closed_buffers)
  end
  if M.buffer_is_modified() and M.is_last_window() then
    local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      vim.cmd('write')
      vim.cmd('q')
    elseif choice == 2 then
      vim.cmd('q!')
    end
  else
    vim.cmd('q')
  end
end


return M
