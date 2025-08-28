local M = {}

-- Check if telescope is available
local has_telescope, _ = pcall(require, "telescope.builtin")
if not has_telescope then
	error("This plugin requires telescope.nvim to be installed")
end

-- Function to check if a file contains a specific tag
local function file_has_tag(filepath, tag)
	local content = vim.fn.readfile(filepath)
	if not content then
		return false
	end
	content = table.concat(content, "\n")

	-- Check frontmatter
	local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
	if frontmatter then
		local tag_line = string.match(frontmatter, "tags: ([^\n]+)")
		if tag_line then
			for t in string.gmatch(tag_line, "[^,]+") do
				if vim.trim(t) == tag then
					return true
				end
			end
		end
	end

	-- Check hashtags
	for t in string.gmatch(content, "#([%w-]+)") do
		if t == tag then
			return true
		end
	end

	return false
end

-- Function to get all files containing a specific tag
local function get_files_with_tag(tag)
	-- Use find command to recursively get all markdown files
	local files = vim.fn.systemlist('find . -type f -name "*.md"')
	local result = {}

	for _, file in ipairs(files) do
		if file_has_tag(file, tag) then
			table.insert(result, file)
		end
	end

	return result
end

-- Function to extract tags from frontmatter
local function extract_frontmatter_tags(content)
	local tags = {}
	local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
	if frontmatter then
		-- Look specifically for the tags field
		local tag_line = string.match(frontmatter, "tags: ([^\n]+)")
		if tag_line then
			-- Split by comma and trim each tag
			for tag in string.gmatch(tag_line, "[^,]+") do
				local trimmed_tag = vim.trim(tag)
				if trimmed_tag ~= "" then
					table.insert(tags, trimmed_tag)
				end
			end
		end
	end
	return tags
end

-- Function to extract date from frontmatter
local function extract_frontmatter_date(content)
	local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
	if frontmatter then
		-- Look for the date field
		local date_line = string.match(frontmatter, "date: ([^\n]+)")
		if date_line then
			return vim.trim(date_line)
		end
	end
	return nil
end

-- Function to extract hashtags from content
local function extract_hashtags(content)
	local tags = {}
	for tag in string.gmatch(content, "#([%w-]+)") do
		table.insert(tags, tag)
	end
	return tags
end

-- Function to get all unique tags from a file
local function get_file_tags(filepath)
	local content = vim.fn.readfile(filepath)
	if not content then
		return {}
	end
	content = table.concat(content, "\n")

	local tags = {}
	local frontmatter_tags = extract_frontmatter_tags(content)
	local hashtags = extract_hashtags(content)

	-- Combine and deduplicate tags
	for _, tag in ipairs(frontmatter_tags) do
		tags[tag] = true
	end
	for _, tag in ipairs(hashtags) do
		tags[tag] = true
	end

	-- Convert back to array
	local result = {}
	for tag, _ in pairs(tags) do
		table.insert(result, tag)
	end
	return result
end

-- Function to check if a file has any tags
local function file_has_any_tags(filepath)
	local content = vim.fn.readfile(filepath)
	if not content then
		return false
	end
	content = table.concat(content, "\n")

	-- Check frontmatter
	local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
	if frontmatter then
		local tag_line = string.match(frontmatter, "tags: ([^\n]+)")
		if tag_line and tag_line ~= "" then
			return true
		end
	end

	-- Check hashtags
	local has_hashtag = string.match(content, "#([%w-]+)")
	return has_hashtag ~= nil
end

-- Function to get all tags from all markdown files in the current directory and subdirectories
local function get_all_tags()
	local tags = {}
	-- Use find command to recursively get all markdown files
	local files = vim.fn.systemlist('find . -type f -name "*.md"')
	local untagged_count = 0

	-- First pass: collect all tags and their counts
	for _, file in ipairs(files) do
		local file_tags = get_file_tags(file)
		if #file_tags == 0 then
			untagged_count = untagged_count + 1
		else
			for _, tag in ipairs(file_tags) do
				if not tags[tag] then
					tags[tag] = 0
				end
				tags[tag] = tags[tag] + 1
			end
		end
	end

	-- Convert to array of {tag, count} pairs and sort by tag name
	local result = {}
	-- Add untagged category if there are untagged files
	if untagged_count > 0 then
		table.insert(result, { tag = "[untagged]", count = untagged_count })
	end
	for tag, count in pairs(tags) do
		table.insert(result, { tag = tag, count = count })
	end
	table.sort(result, function(a, b)
		-- Keep [untagged] at the top
		if a.tag == "[untagged]" then
			return true
		end
		if b.tag == "[untagged]" then
			return false
		end
		return a.tag < b.tag
	end)
	return result
end

-- Function to get files with a specific tag, including their dates
local function get_files_with_tag_and_dates(tag)
	-- Use find command to recursively get all markdown files
	local files = vim.fn.systemlist('find . -type f -name "*.md"')
	local result = {}

	for _, file in ipairs(files) do
		if file_has_tag(file, tag) then
			local content = vim.fn.readfile(file)
			if content then
				content = table.concat(content, "\n")
				local file_date = extract_frontmatter_date(content)
				table.insert(result, { file = file, date = file_date })
			end
		end
	end

	-- Sort by date (latest first), then by filename for entries without dates
	table.sort(result, function(a, b)
		-- If both have dates, sort by date (latest first)
		if a.date and b.date then
			return a.date > b.date
		end
		
		-- If only one has a date, prioritize the one with date
		if a.date and not b.date then
			return true
		end
		if not a.date and b.date then
			return false
		end
		
		-- If neither has a date, sort by filename
		return a.file < b.file
	end)
	
	return result
end

-- Function to count files with a specific tag for a given year
local function count_files_with_tag_for_year(tag, year)
	if tag == "" then
		return 0, {}
	end

	local files = vim.fn.systemlist('find . -type f -name "*.md"')
	local count = 0
	local matching_files = {}

	for _, file in ipairs(files) do
		if file_has_tag(file, tag) then
			local content = vim.fn.readfile(file)
			if content then
				content = table.concat(content, "\n")
				local file_date = extract_frontmatter_date(content)
				if file_date then
					-- Extract year from date (assuming YYYY-MM-DD format)
					local file_year = string.match(file_date, "^(%d%d%d%d)")
					if file_year and file_year == tostring(year) then
						count = count + 1
						table.insert(matching_files, { file = file, date = file_date })
					end
				end
			end
		end
	end

	-- Sort matching files by date (latest first)
	table.sort(matching_files, function(a, b)
		return a.date > b.date
	end)

	return count, matching_files
end

-- Function to show tags in a floating window
local function show_tags()
	local tag_data = get_all_tags()
	if #tag_data == 0 then
		vim.notify("No tags found in your notes", vim.log.levels.INFO)
		return
	end

	-- Format the content with tag counts
	local content = {}
	for _, data in ipairs(tag_data) do
		table.insert(content, string.format("%s (%d)", data.tag, data.count))
	end

	-- Create a custom picker
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local themes = require("telescope.themes").get_dropdown({
		previewer = false,
		winblend = 10,
	})

	pickers
		.new(themes, {
			prompt_title = "Notes Tags",
			finder = finders.new_table({
				results = content,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function()
				actions.select_default:replace(function()
					local selection = state.get_selected_entry()
					if selection then
						local tag = string.match(selection[1], "([^(]+)")
						if tag then
							tag = vim.trim(tag)
							local files = {}

							if tag == "[untagged]" then
								-- Get all markdown files
								local all_files = vim.fn.systemlist('find . -type f -name "*.md"')
								-- Filter for files without tags
								for _, file in ipairs(all_files) do
									if not file_has_any_tags(file) then
										table.insert(files, file)
									end
								end
							else
								files = get_files_with_tag(tag)
							end

							-- Open another Telescope with files containing the tag
							require("telescope.builtin").find_files({
								prompt_title = tag == "[untagged]" and "Untagged Notes" or "Notes with tag: " .. tag,
								search_dirs = files,
								find_command = nil,
								attach_mappings = function(_, map)
									map("i", "<CR>", actions.select_default)
									map("n", "<CR>", actions.select_default)
									return true
								end,
							})
						end
					end
				end)
				return true
			end,
		})
		:find()
end



-- Function to search files by tag using Telescope
local function search_files_by_tag(tag)
	if tag == "" then
		vim.notify("Please provide a tag to search for", vim.log.levels.ERROR)
		return
	end

	local files = {}
	if tag == "[untagged]" then
		-- Get all markdown files
		local all_files = vim.fn.systemlist('find . -type f -name "*.md"')
		-- Filter for files without tags
		for _, file in ipairs(all_files) do
			if not file_has_any_tags(file) then
				table.insert(files, file)
			end
		end
	else
		files = get_files_with_tag(tag)
	end

	if #files == 0 then
		vim.notify("No files found with tag: " .. tag, vim.log.levels.INFO)
		return
	end

	-- Open Telescope with only the files containing the tag
	require("telescope.builtin").find_files({
		prompt_title = tag == "[untagged]" and "Untagged Notes" or "Notes with tag: " .. tag,
		search_dirs = files,
		find_command = nil, -- Use default find command
		attach_mappings = function(_, map)
			local actions = require("telescope.actions")
			map("i", "<CR>", actions.select_default)
			map("n", "<CR>", actions.select_default)
			return true
		end,
	})
end

-- Function to search files by tag ordered by date using Telescope
local function search_files_by_tag_ordered_by_date(tag)
	if tag == "" then
		vim.notify("Please provide a tag to search for", vim.log.levels.ERROR)
		return
	end

	local file_data = {}
	if tag == "[untagged]" then
		-- Get all markdown files
		local all_files = vim.fn.systemlist('find . -type f -name "*.md"')
		-- Filter for files without tags and get their dates
		for _, file in ipairs(all_files) do
			if not file_has_any_tags(file) then
				local content = vim.fn.readfile(file)
				if content then
					content = table.concat(content, "\n")
					local file_date = extract_frontmatter_date(content)
					table.insert(file_data, { file = file, date = file_date })
				end
			end
		end
	else
		file_data = get_files_with_tag_and_dates(tag)
	end

	if #file_data == 0 then
		vim.notify("No files found with tag: " .. tag, vim.log.levels.INFO)
		return
	end

	-- Format the content with dates for display
	local content = {}
	for _, data in ipairs(file_data) do
		local date_str = data.date and (" [" .. data.date .. "]") or " [no date]"
		local display_name = vim.fn.fnamemodify(data.file, ":t:r") -- Get basename without extension
		table.insert(content, display_name .. date_str)
	end

	-- Create a custom picker
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")
	local themes = require("telescope.themes").get_dropdown({
		previewer = true,
		winblend = 10,
		width = 0.8,
		height = 0.8,
	})

	pickers
		.new(themes, {
			prompt_title = tag == "[untagged]" and "Untagged Notes (by Date)" or "Notes with tag: " .. tag .. " (by Date)",
			finder = finders.new_table({
				results = content,
				entry_maker = function(entry)
					local index = nil
					for i, display in ipairs(content) do
						if display == entry then
							index = i
							break
						end
					end
					return {
						value = file_data[index].file,
						display = entry,
						ordinal = entry,
						path = file_data[index].file,
					}
				end,
			}),
			previewer = previewers.vim_buffer_cat.new({
				title = "File Preview",
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function()
				actions.select_default:replace(function()
					local selection = state.get_selected_entry()
					if selection then
						vim.cmd("edit " .. selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

-- Function to show tag statistics for a specific year
local function show_tags_for_year(tag, year)
	if tag == "" then
		vim.notify("Please provide a tag to search for", vim.log.levels.ERROR)
		return
	end

	if not year or year == "" then
		vim.notify("Please provide a year (e.g., 2024)", vim.log.levels.ERROR)
		return
	end

	-- Convert year to number for validation
	local year_num = tonumber(year)
	if not year_num or year_num < 1000 or year_num > 9999 then
		vim.notify("Please provide a valid 4-digit year", vim.log.levels.ERROR)
		return
	end

	local count, matching_files = count_files_with_tag_for_year(tag, year_num)

	if count == 0 then
		vim.notify(string.format("No files found with tag '%s' for year %s", tag, year), vim.log.levels.INFO)
		return
	end

	-- Create message with count and option to view files
	local message = string.format("Found %d file(s) with tag '%s' for year %s", count, tag, year)
	
	-- If there are files, offer to show them
	if count > 0 then
		local choice = vim.fn.confirm(
			message .. "\n\nWould you like to view the files?",
			"&Yes\n&No",
			1
		)
		
		if choice == 1 then
			-- Format the content with dates for display
			local content = {}
			for _, data in ipairs(matching_files) do
				local display_name = vim.fn.fnamemodify(data.file, ":t:r") -- Get basename without extension
				table.insert(content, display_name .. " [" .. data.date .. "]")
			end

			-- Create a custom picker
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
			local state = require("telescope.actions.state")
			local themes = require("telescope.themes").get_dropdown({
				previewer = false,
				winblend = 10,
			})

			pickers
				.new(themes, {
					prompt_title = string.format("'%s' files for %s (%d found)", tag, year, count),
					finder = finders.new_table({
						results = content,
						entry_maker = function(entry)
							local index = nil
							for i, display in ipairs(content) do
								if display == entry then
									index = i
									break
								end
							end
							return {
								value = matching_files[index].file,
								display = entry,
								ordinal = entry,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function()
						actions.select_default:replace(function()
							local selection = state.get_selected_entry()
							if selection then
								vim.cmd("edit " .. selection.value)
							end
						end)
						return true
					end,
				})
				:find()
		end
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

function M.setup_tags(keymap)
	-- Set up the keybinding for showing tags
	vim.keymap.set("n", keymap, show_tags, { desc = "[N]otes: Show [T]ags" })

	-- Create command to search files by tag
	vim.api.nvim_create_user_command("Tag", function(opts)
		search_files_by_tag(opts.args)
	end, {
		nargs = 1,
		complete = function()
			local tag_data = get_all_tags()
			local completions = {}
			for _, data in ipairs(tag_data) do
				table.insert(completions, data.tag)
			end
			return completions
		end,
	})

	-- Create command to search files by tag ordered by date
	vim.api.nvim_create_user_command("TagsByDate", function(opts)
		search_files_by_tag_ordered_by_date(opts.args)
	end, {
		nargs = 1,
		desc = "Search files with a specific tag ordered by date in frontmatter",
		complete = function()
			local tag_data = get_all_tags()
			local completions = {}
			for _, data in ipairs(tag_data) do
				table.insert(completions, data.tag)
			end
			return completions
		end,
	})

	-- Create command to show tag statistics for a specific year
	vim.api.nvim_create_user_command("TagsForYear", function(opts)
		local args = vim.split(opts.args, "%s+")
		if #args < 2 then
			vim.notify("Usage: :TagsForYear <tag> <year>", vim.log.levels.ERROR)
			return
		end
		local tag = args[1]
		local year = args[2]
		show_tags_for_year(tag, year)
	end, {
		nargs = "+",
		desc = "Show count of files with a specific tag for a given year",
		complete = function(arg_lead, cmd_line, cursor_pos)
			local args = vim.split(cmd_line, "%s+")
			-- If we're completing the first argument (tag), provide tag completions
			if #args <= 2 then
				local tag_data = get_all_tags()
				local completions = {}
				for _, data in ipairs(tag_data) do
					if vim.startswith(data.tag, arg_lead) then
						table.insert(completions, data.tag)
					end
				end
				return completions
			-- If we're completing the second argument (year), provide some year suggestions
			elseif #args == 3 then
				local current_year = tonumber(os.date("%Y"))
				local years = {}
				for i = current_year, current_year - 10, -1 do
					table.insert(years, tostring(i))
				end
				return years
			end
			return {}
		end,
	})
end

return M
