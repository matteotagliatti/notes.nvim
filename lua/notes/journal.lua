local M = {}
local utils = require('notes.utils')

-- Function to open or create journal file
local function open_journal(journal_file)
    -- Open the file
    vim.cmd('edit ' .. journal_file)
end

-- Function to open or create daily note
local function open_daily_note(daily_notes_dir)
    -- Ensure the directory exists
    if vim.fn.isdirectory(daily_notes_dir) == 0 then
        vim.fn.mkdir(daily_notes_dir, 'p')
    end

    -- Create the daily note filename
    local filename = utils.get_today_date() .. '.md'
    local filepath = daily_notes_dir .. '/' .. filename

    -- Open the file
    vim.cmd('edit ' .. filepath)
end

function M.setup_journal(keymap, journal_file, daily_notes_keymap, daily_notes_dir)
    -- Set up the keybinding for opening journal
    vim.keymap.set('n', keymap, function()
        open_journal(journal_file or 'journal.md')
    end, { desc = '[N]ote [J]ournal: Open/Create journal' })

    -- Set up the keybinding for opening daily note
    vim.keymap.set('n', daily_notes_keymap, function()
        open_daily_note(daily_notes_dir or 'daily')
    end, { desc = '[N]ote [D]aily: Open/Create daily note' })
end

return M
