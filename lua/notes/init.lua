local M = {}

-- Default configuration
local default_config = {
	keymaps = {
		follow_link = "<leader>nf", -- following wiki links
		show_tags = "<leader>nt", -- showing tags
		media = "<leader>nm", -- create new media entry
		journal = {
			today = "<leader>njj", -- opening journal for today
			yesterday = "<leader>njy", -- opening journal for yesterday
			tomorrow = "<leader>njt", -- opening journal for tomorrow
		},
	},
	wikilink = {
		fg = nil, -- nil means use the default colorscheme
		underline = true,
	},
	journal = {
		dir = "journal", -- directory for journal entries
	},
	media = {
		dir = "media", -- directory for media entries
	},
	utils = {
		date_format = "%Y-%m-%d", -- date format
		time_format = "%H:%M:%S", -- time format
		space_replacement = "-", -- space replacement character for filenames
	},
}

function M.setup(opts)
	local config = vim.tbl_deep_extend("force", default_config, opts or {}) -- Merge user configuration with defaults

	-- Setups
	local utils = require("notes.utils")
	utils.setup(config.utils)

	local commands = require("notes.commands")
	commands.setup_commands()

	local wikilinks = require("notes.wikilinks")
	wikilinks.setup_wikilinks(config.keymaps.follow_link, config.wikilink, config.utils.space_replacement)

	local tags = require("notes.tags")
	tags.setup_tags(config.keymaps.show_tags)

	local journal = require("notes.journal")
	journal.setup_journal(
		config.keymaps.journal.today,
		config.journal.dir,
		config.keymaps.journal.yesterday,
		config.keymaps.journal.tomorrow
	)

	local media = require("notes.media")
	media.setup_media(config.keymaps.media, config.media.dir)
end

M.defaults = default_config

return M
