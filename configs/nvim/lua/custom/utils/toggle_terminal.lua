local M = {}

M.open_terminal = function(location)
  if location == 'new tab' then
    vim.cmd('tab terminal')
  else
    if location == 'horizontal' then
      vim.cmd('split')
    elseif location == 'vertical' then
      vim.cmd('vsplit')
    end
    vim.cmd('terminal')
  end
end

return M
