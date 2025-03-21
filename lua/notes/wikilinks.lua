local M = {}

-- Function to setup wiki-style links
function M.setup_wikilinks(keymap)
  vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text" },
      desc = "Setup wiki-style links",
      callback = function()
          vim.fn.matchadd("WikiLink", "\\[\\[.\\+\\]\\]")
          
          vim.keymap.set("n", keymap, function()
              local line = vim.fn.getline(".")
              local link = string.match(line, "%[%[(.+)%]%]")
              if link then
                  local filename = string.gsub(link, " ", "_") .. ".md"
                  vim.cmd("edit " .. filename)
              end
          end, { buffer = true, desc = "[N]otes: [F]ollow link" })
      end
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Add WikiLink highlight group",
      callback = function()
          vim.api.nvim_set_hl(0, "WikiLink", { fg = "#83a598", underline = true })
      end,
  })
end

return M
