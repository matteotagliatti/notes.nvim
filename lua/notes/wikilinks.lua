local M = {}

function M.setup_wikilinks(keymap, highlight_config, space_replacement)
	-- Default to dash if no replacement character is specified
	space_replacement = space_replacement or "-"

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "markdown", "text" },
		desc = "Setup wiki-style links",
		callback = function()
			vim.fn.matchadd("WikiLink", "\\[\\[.\\+\\]\\]")

			vim.keymap.set("n", keymap, function()
				local line = vim.fn.getline(".")
				local link = string.match(line, "%[%[(.+)%]%]")
				if link then
					-- Check if link contains pipe separator for [[href|display]] format
					local href, display_text = string.match(link, "^([^|]+)|(.+)$")
					if not href then
						-- No pipe found, use the entire link as both href and display
						href = link
						display_text = link
					end

					-- Use href for filename, display_text for title
					local filename = string.gsub(href, " ", space_replacement) .. ".md"
					-- Check if file exists
					if vim.fn.filereadable(filename) == 0 then
						-- Create new file with a basic template using display_text for title
						vim.fn.writefile({ "# " .. display_text }, filename)
					end
					vim.cmd("edit " .. filename)
				end
			end, { buffer = true, desc = "[N]otes: [F]ollow link" })
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		desc = "Add WikiLink highlight group",
		callback = function()
			-- Only set custom highlight if fg color is specified
			if highlight_config.fg then
				vim.api.nvim_set_hl(0, "WikiLink", {
					fg = highlight_config.fg,
					underline = highlight_config.underline,
				})
			else
				-- Use the default colorscheme's link color
				vim.api.nvim_set_hl(0, "WikiLink", {
					link = "Underlined",
					underline = highlight_config.underline,
				})
			end
		end,
	})
end

return M
