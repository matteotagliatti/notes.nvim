local M = {}

-- Default configuration
local config = {
    keymaps = {
        follow_link = "<leader>nf",  -- default keybinding for following wiki links
    }
}

-- Setup function
function M.setup(opts)
    -- Merge user configuration with defaults
    config = vim.tbl_deep_extend('force', config, opts or {})
    
    -- Setup commands and wikilinks
    local commands = require('notes.commands')
    commands.setup_commands()
    
    local wikilinks = require('notes.wikilinks')
    wikilinks.setup_wikilinks(config.keymaps.follow_link)
end

return M