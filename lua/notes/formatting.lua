local M = {}

function M.setup_formatting(keymaps)
  vim.keymap.set('v', keymaps.bold, "c**<C-r>\"**<Esc>", { desc = '[M]arkdown [B]old' })
  vim.keymap.set('v', keymaps.italic, "c*<C-r>\"*<Esc>", { desc = '[M]arkdown [I]talic' })
  vim.keymap.set('v', keymaps.underline, "c_<C-r>\"_<Esc>", { desc = '[M]arkdown [U]nderline' })
end

return M
