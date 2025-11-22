local M = {}

-- function that puts in the file what neovim receives as keys pressed
function M.LogRawKeySequence()
  local seq = {}
  while true do
    local key = vim.fn.getchar(0) -- non-blocking read
    if key == 0 then
      break
    end -- stop when no more input
    table.insert(seq, key)
  end

  if #seq == 0 then
    table.insert(seq, vim.fn.getchar())
  end

  local decoded = {}
  for _, code in ipairs(seq) do
    if type(code) == 'number' then
      local hex = string.format('\\x%02X', code)
      local char = vim.fn.nr2char(code)
      local safe_char = type(char) == 'string' and char or '?'
      table.insert(decoded, string.format('%s (%q)', hex, safe_char))
    else
      table.insert(decoded, string.format('<?> (non-numeric input: %s)', tostring(code)))
    end
  end

  local msg = '🧠 Key sequence: ' .. table.concat(decoded, ', ')

  local line = vim.fn.line '.'
  vim.api.nvim_buf_set_lines(0, line, line, false, { msg })
end

return M
