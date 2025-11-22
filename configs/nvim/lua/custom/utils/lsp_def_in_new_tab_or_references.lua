local M = {}

local lsp_util = vim.lsp.util
local builtin = require('telescope.builtin')

M.lsp_def_in_new_tab_or_references = function()
  local params = lsp_util.make_position_params()
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_pos = vim.api.nvim_win_get_cursor(0)

  vim.lsp.buf_request_all(0, 'textDocument/definition', params, function(results)
    local defs = {}

    for _, res in pairs(results) do
      local result = res.result
      if result then
        if vim.islist(result) then
          vim.list_extend(defs, result)
        else
          table.insert(defs, result)
        end
      end
    end

    if vim.tbl_isempty(defs) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end

    for _, def in ipairs(defs) do
      local uri = def.uri or def.targetUri
      local range = def.range or def.targetSelectionRange
      local def_buf = vim.uri_to_bufnr(uri)
      local def_line = range.start.line

      if curr_buf == def_buf and curr_pos[1] - 1 == def_line then
        builtin.lsp_references()
        return
      end
    end

    vim.cmd('tab split')
    builtin.lsp_definitions()
  end)
end

return M
