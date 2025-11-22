local M = {}

M.open_closed_buffer = function(closed_buffers)
  local last_buf = closed_buffers[1]
  if last_buf and vim.fn.filereadable(last_buf) == 1 then
    vim.cmd('tab split')
    vim.cmd('edit ' .. vim.fn.fnameescape(last_buf))
    table.remove(closed_buffers, 1)
  else
    print("No recently closed buffer to reopen.")
  end
end

return M
