-- Auto-detect large files and disable heavy features to prevent freezing
local big_file_utils = require('custom.utils.toggle_big_files_stuff')

vim.api.nvim_create_augroup("LargeFileAutoDetect", { clear = true })

-- Detect file size BEFORE reading the file
vim.api.nvim_create_autocmd("BufReadPre", {
  group = "LargeFileAutoDetect",
  pattern = "*",
  callback = function(ev)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if not ok or not stats then
      return
    end

    -- local size_mb = stats.size / (1024 * 1024)
    local size_mb = stats.size / (1024 * 1024)

    -- For extremely large files (>10MB)
    if size_mb > big_file_utils.config.extreme_threshold_mb then
      vim.b[ev.buf].detected_large_file = true
      vim.b[ev.buf].detected_extreme = true

      -- Disable features BEFORE loading to prevent freeze
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.undolevels = -1

      vim.schedule(function()
        vim.notify(
          string.format(
            "Extreme file size detected: %.1f MB\nOpening in read-only mode. Use :set modifiable to edit.",
            size_mb
          ),
          vim.log.levels.WARN
        )
      end)
    -- For large files (>1MB)
    elseif size_mb > big_file_utils.config.size_threshold_mb then
      vim.b[ev.buf].detected_large_file = true
      vim.b[ev.buf].detected_extreme = false

      -- Disable features BEFORE loading
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false

      vim.schedule(function()
        vim.notify(
          string.format("Large file detected: %.1f MB - Disabling heavy features", size_mb),
          vim.log.levels.INFO
        )
      end)
    end
  end,
})

-- Apply full restrictions AFTER file is loaded
vim.api.nvim_create_autocmd("BufReadPost", {
  group = "LargeFileAutoDetect",
  pattern = "*",
  callback = function(ev)
    local buf = ev.buf

    if vim.b[buf].detected_large_file then
      local is_extreme = vim.b[buf].detected_extreme or false
      big_file_utils.disable_big_file_features(buf, is_extreme)
    end
  end,
})
