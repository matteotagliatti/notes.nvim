local M = {}
local utils = require("notes.utils")

-- Store the media directory (set during setup)
local media_dir = "media" -- default fallback

-- Function to create a new media entry
function M.create_media_entry()
	-- Get user input for media details
	local media_type = vim.fn.input("Media type (book/movie): ")
	if media_type == "" then
		print("Media creation cancelled")
		return
	end
	
	-- Validate media type
	if media_type ~= "book" and media_type ~= "movie" then
		print("Invalid media type. Please use 'book' or 'movie'")
		return
	end
	
	local title = vim.fn.input("Title: ")
	if title == "" then
		print("Media creation cancelled")
		return
	end
	
	local author = vim.fn.input("Author: ")
	if author == "" then
		print("Media creation cancelled")
		return
	end
	
	-- Get today's date
	local date = utils.get_today_date()
	
	-- Create frontmatter
	local frontmatter = {
		"---",
		"tags: " .. media_type,
		"title: " .. title,
		"author: " .. author,
		"date: " .. date,
		"---",
		"",
	}
	
	-- Create filename (sanitize title for filesystem)
	local space_replacement = utils.get_space_replacement()
	local filename = title:gsub("[^%w%s%-_]", ""):gsub("%s+", space_replacement):lower()
	local filepath = media_dir .. "/" .. filename .. ".md"
	
	-- Create media directory if it doesn't exist
	if vim.fn.isdirectory(media_dir) == 0 then
		vim.fn.mkdir(media_dir, "p")
	end
	
	-- Check if file already exists
	if vim.fn.filereadable(filepath) == 1 then
		local overwrite = vim.fn.input("File already exists. Overwrite? (y/N): ")
		if overwrite:lower() ~= "y" then
			print("Media creation cancelled")
			return
		end
	end
	
	-- Create and open the file
	vim.cmd("edit " .. filepath)
	
	-- Add frontmatter to the buffer
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, frontmatter)
	
	-- Save the file
	vim.cmd("write")
	
	print("Media entry created: " .. filepath)
end

-- Function to setup media keymaps
function M.setup_media(keymap, dir)
	media_dir = dir or "media"
	vim.keymap.set("n", keymap, M.create_media_entry, { desc = "[N]otes: Create new [m]edia entry" })
end

return M
