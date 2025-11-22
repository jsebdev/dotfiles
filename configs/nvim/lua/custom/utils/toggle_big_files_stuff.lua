local M = {}

-- Configuration
M.config = {
  size_threshold_mb = 1, -- Auto-disable for files larger than this
  extreme_threshold_mb = 10, -- Make read-only for files larger than this
}

local function set_buffer_keymap(buf, mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, opts)
end

-- Function to disable heavy features (can be called by autocmd)
M.disable_big_file_features = function(buf, is_extreme)
  buf = buf or vim.api.nvim_get_current_buf()

  -- Save original state
  vim.b[buf].original_filetype = vim.bo[buf].filetype
  vim.b[buf].attached_clients = vim.lsp.get_clients({ bufnr = buf })

  -- Disable swap and undo for large files
  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false

  -- Disable Treesitter highlighting
  pcall(function()
    vim.cmd("TSBufDisable highlight")
  end)

  -- Clear filetype (which disables filetype plugins)
  vim.bo[buf].filetype = ''
  vim.bo[buf].syntax = 'off'

  -- Detach all LSP clients
  for _, client in pairs(vim.b[buf].attached_clients) do
    vim.lsp.buf_detach_client(buf, client.id)
  end

  -- For extreme files, make read-only
  if is_extreme then
    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
  end

  set_buffer_keymap(buf, 'n', '<C-u>', '<Nop>', {})
  set_buffer_keymap(buf, 'n', '<C-d>', '<Nop>', {})

  vim.b[buf].big_file_mode = true
  vim.b[buf].is_extreme = is_extreme or false
end

-- Function to re-enable features
M.enable_features = function(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  -- Re-enable filetype
  vim.bo[buf].filetype = vim.b[buf].original_filetype or ''

  -- Re-enable Treesitter highlighting (only if parser exists)
  pcall(function()
    vim.cmd("TSBufEnable highlight")
  end)

  -- Reattach LSP clients
  for _, client in pairs(vim.b[buf].attached_clients or {}) do
    if client and client.name and vim.lsp.get_client_by_id(client.id) then
      vim.lsp.buf_attach_client(buf, client.id)
    end
  end

  -- Re-enable modifiable if it was made read-only
  if vim.b[buf].is_extreme then
    vim.bo[buf].readonly = false
    vim.bo[buf].modifiable = true
  end

  set_buffer_keymap(buf, 'n', '<C-u>', '<C-u>', {})
  set_buffer_keymap(buf, 'n', '<C-d>', '<C-d>', {})

  vim.b[buf].big_file_mode = false
  vim.b[buf].is_extreme = false
end

-- Toggle function for manual use
M.toggle_big_files_stuff = function()
  local buf = vim.api.nvim_get_current_buf()

  -- Initialize toggle state if not already
  if vim.b[buf].big_file_mode == nil then
    vim.b[buf].big_file_mode = false
  end

  -- Toggle state
  if not vim.b[buf].big_file_mode then
    M.disable_big_file_features(buf, false)
    vim.notify("Big file mode ON", vim.log.levels.INFO)
  else
    M.enable_features(buf)
    vim.notify("Big file mode OFF", vim.log.levels.INFO)
  end
end

return M
