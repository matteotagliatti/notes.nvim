local M = {}
local utils = require('notes.utils')

-- Function to create all commands
function M.setup_commands()
    -- Date/Time related commands
    vim.api.nvim_create_user_command('Today', function()
        local date = utils.get_today_date()
        vim.api.nvim_put({ date }, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Yesterday', function()
        local date = utils.get_yesterday_date()
        vim.api.nvim_put({ date }, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Now', function()
        local time = utils.get_current_time()
        vim.api.nvim_put({ time }, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('DateTime', function()
        local date = utils.get_today_date()
        local time = utils.get_current_time()
        vim.api.nvim_put({ date .. ' ' .. time }, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Frontmatter', function()
        local header = {
            '---',
            'tags:',
            '---'
        }
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, header)
    end, {})
end

return M
