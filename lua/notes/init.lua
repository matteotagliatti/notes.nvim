local M = {}

-- Default configuration
local config = {
    keymaps = {
        follow_link = "<leader>nf",  -- default keybinding for following wiki links
        show_tags = "<leader>nt",  -- default keybinding for showing tags
    },
    highlights = {
        wikilink = {
            fg = nil,  -- nil means use the default colorscheme
            underline = true,
        }
    }
}

-- Setup function
function M.setup(opts)
    -- Merge user configuration with defaults
    config = vim.tbl_deep_extend('force', config, opts or {})
    
    -- Setups
    local commands = require('notes.commands')
    commands.setup_commands()
    
    local wikilinks = require('notes.wikilinks')
    wikilinks.setup_wikilinks(config.keymaps.follow_link, config.highlights.wikilink)

    local tags = require('notes.tags')
    tags.setup_tags(config.keymaps.show_tags)
end

return M