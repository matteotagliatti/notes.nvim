local M = {}

-- Function to setup wiki-style links
function M.setup_wikilinks(keymap, highlight_config)
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
          -- Only set custom highlight if fg color is specified
          if highlight_config.fg then
              vim.api.nvim_set_hl(0, "WikiLink", {
                  fg = highlight_config.fg,
                  underline = highlight_config.underline
              })
          else
              -- Use the default colorscheme's link color
              vim.api.nvim_set_hl(0, "WikiLink", {
                  link = "Underlined",
                  underline = highlight_config.underline
              })
          end
      end,
  })
end

return M
