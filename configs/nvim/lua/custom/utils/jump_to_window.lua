local M = {}

M.jump_to_window_telescope = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local entries = {}

  -- Get all open windows
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local tabnr = vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(winid))
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == '' then bufname = '[No Name]' end

    local entry = {
      display = string.format("Tab %d | Win %d: %s", tabnr, winid, bufname),
      ordinal = bufname,
      tabnr = tabnr,
      winid = winid,
    }
    table.insert(entries, entry)
  end

  pickers.new({}, {
    prompt_title = "Tabs + Windows",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        local entry = selection.value
        vim.cmd(entry.tabnr .. "tabnext")
        vim.api.nvim_set_current_win(entry.winid)
      end)
      return true
    end,
  }):find()
end

return M
