local M = {}

-- Default configuration
local config = {
    keymaps = {
        follow_link = "<leader>nf", -- following wiki links
        show_tags = "<leader>nt",   -- showing tags
        journal = {
            today = "<leader>njj",     -- opening journal for today
            yesterday = "<leader>njy", -- opening journal for yesterday
            tomorrow = "<leader>njt",  -- opening journal for tomorrow
        },
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
        dir = "journal", -- directory for journal entries
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
        config.keymaps.journal.today,
        config.journal.dir,
        config.keymaps.journal.yesterday,
        config.keymaps.journal.tomorrow
    )

    local formatting = require('notes.formatting')
    formatting.setup_formatting(config.keymaps.formatting)
end

return M
