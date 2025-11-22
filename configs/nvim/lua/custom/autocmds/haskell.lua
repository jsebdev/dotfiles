vim.api.nvim_create_augroup("CustomHaskellSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "haskell",
  group = "CustomHaskellSettings",
  callback = function()
    print("Setting Haskell specific options")
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

