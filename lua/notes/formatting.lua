local M = {}

function M.setup_formatting(keymaps)
  vim.keymap.set('v', keymaps.bold, "c**<C-r>\"**<Esc>", { desc = '[B]old' })
  vim.keymap.set('v', keymaps.italic, "c*<C-r>\"*<Esc>", { desc = '[I]talic' })
  vim.keymap.set('v', keymaps.wikilink, "c[[<C-r>\"]]<Esc>", { desc = '[W]ikilink' })
end

return M
