local M = {}

-- Default configuration
local config = {
    keymaps = {
        follow_link = "<leader>nf", -- default keybinding for following wiki links
        show_tags = "<leader>nt",   -- default keybinding for showing tags
        journal = "<leader>nj",     -- default keybinding for opening journal
        daily_note = "<leader>nd",  -- default keybinding for opening daily note
        formatting = {
            bold = "<leader>b",     -- default keybinding for bold in visual mode
            italic = "<leader>i",   -- default keybinding for italic in visual mode
            wikilink = "<leader>w", -- default keybinding for wikilink in visual mode
        }
    },
    highlights = {
        wikilink = {
            fg = nil, -- nil means use the default colorscheme
            underline = true,
        }
    },
    journal = {
        file = "journal.md",       -- default journal file name
        daily_notes_dir = "daily", -- default directory for daily notes
    },
    utils = {
        date_format = '%Y-%m-%d', -- default date format
        time_format = '%H:%M:%S', -- default time format
    }
}

-- Setup function
function M.setup(opts)
    -- Merge user configuration with defaults
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- Setups
    local utils = require('notes.utils')
    utils.setup(config.utils)

    local commands = require('notes.commands')
    commands.setup_commands()

    local wikilinks = require('notes.wikilinks')
    wikilinks.setup_wikilinks(config.keymaps.follow_link, config.highlights.wikilink)

    local tags = require('notes.tags')
    tags.setup_tags(config.keymaps.show_tags)

    local journal = require('notes.journal')
    journal.setup_journal(
        config.keymaps.journal,
        config.journal.file,
        config.keymaps.daily_note,
        config.journal.daily_notes_dir
    )

    local formatting = require('notes.formatting')
    formatting.setup_formatting(config.keymaps.formatting)
end

return M
