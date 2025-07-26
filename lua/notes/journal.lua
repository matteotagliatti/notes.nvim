local M = {}
local utils = require("notes.utils")

local function open_journal_for_date(journal_dir, date_offset)
	date_offset = date_offset or 0

	if vim.fn.isdirectory(journal_dir) == 0 then
		vim.fn.mkdir(journal_dir, "p")
	end

	local date
	if date_offset == 0 then
		date = utils.get_today_date()
	else
		date = utils.get_date_with_offset(date_offset)
	end

	local filename = date .. ".md"
	local filepath = journal_dir .. "/" .. filename

	vim.cmd("edit " .. filepath)
end

local function open_journal(journal_dir)
	open_journal_for_date(journal_dir, 0)
end

local function open_yesterday_journal(journal_dir)
	open_journal_for_date(journal_dir, -1)
end

local function open_tomorrow_journal(journal_dir)
	open_journal_for_date(journal_dir, 1)
end

function M.setup_journal(keymap, journal_dir, yesterday_keymap, tomorrow_keymap)
	vim.keymap.set("n", keymap, function()
		open_journal(journal_dir)
	end, { desc = "[N]ote [J]ournal: Open/Create journal entry for today" })

	if yesterday_keymap then
		vim.keymap.set("n", yesterday_keymap, function()
			open_yesterday_journal(journal_dir)
		end, { desc = "[N]ote [J]ournal: Open/Create journal entry for yesterday" })
	end

	if tomorrow_keymap then
		vim.keymap.set("n", tomorrow_keymap, function()
			open_tomorrow_journal(journal_dir)
		end, { desc = "[N]ote [J]ournal: Open/Create journal entry for tomorrow" })
	end
end

return M
