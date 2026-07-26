-- for spell checking, source: https://github.com/kamykn/spelunker.vim
vim.g.enable_spelunker_vim = 1
vim.g.enable_spelunker_vim_on_readonly = 1
vim.g.spelunker_target_min_char_len = 2
vim.g.spelunker_max_suggest_words = 15
vim.g.spelunker_max_hi_words_each_buf = 100
vim.g.spelunker_check_type = 1
vim.g.spelunker_highlight_type = 1
vim.g.spelunker_disable_uri_checking = 1
vim.g.spelunker_disable_email_checking = 1
vim.g.spelunker_disable_account_name_checking = 1
vim.g.spelunker_disable_acronym_checking = 1
vim.g.spelunker_disable_backquoted_checking = 1
vim.g.spelunker_disable_auto_group = 0

local spellcheck_filetypes = {
  "vim", "js", "jsx", "json", "md", "ts", "html", "css", "scss", "py"
}

local spellcheck_patterns = vim.tbl_map(function(ext) return "*." .. ext end, spellcheck_filetypes)

local max_line_length_for_spellcheck = 3000

local function buffer_has_long_line(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if #line > max_line_length_for_spellcheck then
      return true
    end
  end
  return false
end

local spelunker_group = vim.api.nvim_create_augroup("spelunker", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = spelunker_group,
  pattern = spellcheck_patterns,
  callback = function(args)
    vim.b[args.buf].spelunker_skip = buffer_has_long_line(args.buf)
    if not vim.b[args.buf].spelunker_skip then
      vim.fn["spelunker#check"]()
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  group = spelunker_group,
  pattern = spellcheck_patterns,
  callback = function(args)
    if not vim.b[args.buf].spelunker_skip then
      vim.fn["spelunker#check_displayed_words"]()
    end
  end,
})

vim.g.spelunker_spell_bad_group = "SpelunkerSpellBad"
vim.g.spelunker_complex_or_compound_word_group = "SpelunkerComplexOrCompoundWord"

-- Override highlight setting with Error color from the current theme.
local error_color = vim.fn.synIDattr(vim.fn.hlID("Error"), "fg")
vim.cmd(string.format("highlight SpelunkerSpellBad cterm=underline gui=undercurl guisp=%s", error_color))
vim.cmd(
  string.format(
    "highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=undercurl guisp=%s",
    error_color
  )
)
print("Spelunker.vim loaded with custom settings.")
