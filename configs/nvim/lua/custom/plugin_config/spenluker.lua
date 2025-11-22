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
  "vim", "js", "jsx", "json", "md", "ts", "html", "css", "scss"
}

local pattern = table.concat(
  vim.tbl_map(function(ext) return "*." .. ext end, spellcheck_filetypes),
  ","
)

vim.cmd("augroup spelunker")
vim.cmd("autocmd!")
vim.cmd("autocmd BufWinEnter,BufWritePost " .. pattern .. " call spelunker#check()")
vim.cmd("autocmd CursorHold " .. pattern .. " call spelunker#check_displayed_words()")
vim.cmd("augroup END")

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
