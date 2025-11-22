local M = {}

M.print_current_line_with_formats = function(expr_format, eval_format)
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]

    -- Capture indentation (spaces or tabs)
    local indent = line:match '^%s*' or ''
    local trimmed_line = vim.trim(line)

    local file = vim.fn.expand '%:t' -- file name
    local linenr = row

    local print_expr = indent .. string.format(expr_format, file, linenr, trimmed_line)
    local print_eval = indent .. string.format(eval_format, trimmed_line)

    -- Replace the original line with the two print lines
    vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { print_expr, print_eval })
    vim.cmd('normal! j') -- Move cursor down to the next line
end

return M
