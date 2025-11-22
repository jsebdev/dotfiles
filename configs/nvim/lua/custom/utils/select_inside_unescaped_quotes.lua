local M = {}
--------------------------------------------------------------------------------
-- 1) Helpers that move backward or forward in the buffer looking for
--    an unescaped double quote (i.e., a quote preceded by an even number
--    of consecutive backslashes).
--------------------------------------------------------------------------------

---Returns (line, col) of the nearest unescaped `"` *behind* (line,col),
---or nil if none is found. Both `line` and `col` are 0-based.
local function find_prev_unescaped_quote(bufnr, line, col)
  while line >= 0 do
    local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
    while col >= 0 do
      if text:sub(col + 1, col + 1) == '"' then
        -- Count consecutive backslashes immediately preceding this quote
        local bcount = 0
        local scan = col
        while scan > 0 and text:sub(scan, scan) == "\\" do
          bcount = bcount + 1
          scan = scan - 1
        end
        -- If we have an even number of backslashes, this quote is unescaped
        if (bcount % 2) == 0 then
          return line, col
        end
      end
      col = col - 1
    end
    line = line - 1
    if line >= 0 then
      -- Jump to the end of the previous line
      col = #vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] - 1
    end
  end
  return nil, nil
end

---Returns (line, col) of the nearest unescaped `"` *ahead* of (line,col),
---or nil if none is found.
local function find_next_unescaped_quote(bufnr, line, col)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  while line < line_count do
    local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
    while col < #text do
      if text:sub(col + 1, col + 1) == '"' then
        -- Count consecutive backslashes immediately preceding this quote
        local bcount = 0
        local scan = col - 1
        while scan >= 0 and text:sub(scan + 1, scan + 1) == "\\" do
          bcount = bcount + 1
          scan = scan - 1
        end
        if (bcount % 2) == 0 then
          return line, col
        end
      end
      col = col + 1
    end
    line = line + 1
    col = 0
  end
  return nil, nil
end

--------------------------------------------------------------------------------
-- 2) The main function that:
--    - finds the nearest unescaped `"` behind the cursor
--    - finds the nearest unescaped `"` ahead of the cursor
--    - visually selects everything *between* them
--------------------------------------------------------------------------------
function M.select_inside_unescaped_quotes()
  local bufnr = 0  -- current buffer
  -- Get current cursor (1-based row, 0-based col)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor[1] - 1  -- convert row to 0-based
  local start_col  = cursor[2]

  -- 1) Find the "opening" quote behind the cursor
  local o_line, o_col = find_prev_unescaped_quote(bufnr, start_line, start_col)
  if not o_line then
    return  -- no quote found behind
  end

  -- 2) Find the "closing" quote ahead of the cursor
  local c_line, c_col = find_next_unescaped_quote(bufnr, start_line, start_col)
  if not c_line then
    return  -- no quote found ahead
  end

  -- We want everything INSIDE the quotes, not including the quotes themselves.
  -- So we'll visually select from (o_line,o_col+1) to (c_line,c_col-1).
  local vstart = { o_line + 1, o_col + 1 }  -- convert back to 1-based line, already 0-based col
  local vend   = { c_line + 1, c_col - 1 }

  -- Make sure we don't do something crazy if quotes are reversed or adjacent
  if vend[2] < vstart[2] and vstart[1] == vend[1] then
    return
  end

  -- 3) Enter visual mode and highlight the region
  --    We'll:
  --      - move the cursor to `vstart`
  --      - start visual mode
  --      - move the cursor to `vend`
  vim.fn.setpos("'<", { 0, vstart[1], vstart[2]+1, 0 })  -- start of selection
  vim.fn.setpos("'>", { 0, vend[1], vend[2]+1, 0 }) -- end of selection
  vim.cmd("normal! gv")                -- reselect the visual area
end

return M
