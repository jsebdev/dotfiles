-- lua/utils/addfiletoquestion.lua
-- Appends a picked file's contents into the *current buffer's file*.

local M = {}

local function ensure_dir_exists(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if dir ~= "" then
    vim.fn.mkdir(dir, "p")
  end
end

local function read_file(path)
  local f, err = io.open(path, "r")
  if not f then
    return nil, err or ("failed to open " .. path)
  end
  local content = f:read("*a")
  f:close()
  return content
end

-- Build the block lines we’ll append
local function build_block_lines(src_path, content)
  local rel = vim.fn.fnamemodify(src_path, ":.") -- nice relative tag
  local lines = {}

  -- blank line before
  table.insert(lines, "")
  table.insert(lines, "<" .. rel .. ">")

  -- add file content lines
  local parts = vim.split(content, "\n", { plain = true })
  -- vim.split keeps a trailing "" when content ends with \n; that’s fine.

  -- If content didn't end with newline, we still want the closing tag on the next line
  for _, ln in ipairs(parts) do
    table.insert(lines, ln)
  end

  -- If content didn't end with newline, the last element won't be "", which is OK:
  -- we’ll put the closing tag as its own new line below.
  table.insert(lines, "</" .. rel .. ">")

  -- blank line after
  table.insert(lines, "")

  return lines
end

-- Append to disk (creating file/dirs if needed)
local function append_block_to_file(dest_path, src_path, content)
  ensure_dir_exists(dest_path)

  local rel = vim.fn.fnamemodify(src_path, ":.")
  local ok, err = pcall(function()
    local f = assert(io.open(dest_path, "a"))
    f:write("\n") -- ensure we start on a new line
    f:write("<" .. rel .. ">\n")
    f:write(content)
    if not content:match("\n$") then
      f:write("\n")
    end
    f:write("</" .. rel .. ">\n\n")
    f:close()
  end)
  if not ok then
    return false, tostring(err)
  end
  return true
end

local function append_block_to_current_buffer(src_path, content)
  local buf = 0
  local lines = build_block_lines(src_path, content)
  local last = vim.api.nvim_buf_line_count(buf)
  -- Insert after last line (Neovim uses 0-index; end-exclusive)
  vim.api.nvim_buf_set_lines(buf, last, last, false, lines)
end

function M.pick_file_and_append_to_current()
  -- Determine destination: current buffer file path
  local dest = vim.api.nvim_buf_get_name(0)
  if dest == nil or dest == "" then
    vim.notify("Current buffer has no file path. Please save it first.", vim.log.levels.ERROR)
    return
  end

  local builtin = require("telescope.builtin")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  builtin.find_files({
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if not entry then
          vim.notify("No file selected", vim.log.levels.WARN)
          return
        end

        local src = entry.path or entry.filename or entry.value
        if not src or src == "" then
          vim.notify("Could not determine file path from selection", vim.log.levels.ERROR)
          return
        end

        local content, rerr = read_file(src)
        if not content then
          vim.notify("Could not read file: " .. tostring(rerr), vim.log.levels.ERROR)
          return
        end

        -- If destination is the same file we have open, modify the buffer directly
        if vim.fn.fnamemodify(dest, ":p") == vim.fn.fnamemodify(src, ":p") then
          append_block_to_current_buffer(src, content)
          vim.notify("Added (buffer) " .. vim.fn.fnamemodify(src, ":.") .. " → current file", vim.log.levels.INFO)
          return
        end

        -- Else, append on disk (create if missing)
        local ok, werr = append_block_to_file(dest, src, content)
        if not ok then
          vim.notify("Failed to append to " .. dest .. ": " .. tostring(werr), vim.log.levels.ERROR)
          return
        end

        -- If destination file is also open in another buffer, tell user to reload or we can auto-checktime
        -- We'll gently nudge Neovim to notice external changes:
        vim.cmd("checktime")

        vim.notify("Added " .. vim.fn.fnamemodify(src, ":.") .. " → " .. vim.fn.fnamemodify(dest, ":."), vim.log.levels.INFO)
      end)
      return true
    end,
  })
end

return M

