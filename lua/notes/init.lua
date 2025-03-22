local M = {}

-- Default configuration
local config = {
    keymaps = {
        follow_link = "<leader>nf", -- following wiki links
        show_tags = "<leader>nt",   -- showing tags
        journal = "<leader>nj",     -- opening journal
        daily_note = "<leader>nd",  -- opening daily note
        formatting = {
            bold = "<leader>b",     -- bold in visual mode
            italic = "<leader>i",   -- italic in visual mode
            wikilink = "<leader>w", -- wikilink in visual mode
        }
    },
    wikilink = {
        fg = nil, -- nil means use the default colorscheme
        underline = true,
        space_replacement = "_",
    },
    journal = {
        file = "journal.md",       -- journal file name
        daily_notes_dir = "daily", -- directory for daily notes
    },
    utils = {
        date_format = '%Y-%m-%d', -- date format
        time_format = '%H:%M:%S', -- time format
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
    wikilinks.setup_wikilinks(config.keymaps.follow_link, config.wikilink)

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
