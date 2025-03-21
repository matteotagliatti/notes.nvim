local M = {}

-- Function to create all commands
function M.setup_commands()
    -- Date/Time related commands
    vim.api.nvim_create_user_command('Today', function()
        local date = os.date('%Y-%m-%d')
        vim.api.nvim_put({date}, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Yesterday', function()
        local date = os.date('%Y-%m-%d', os.time() - 86400)
        vim.api.nvim_put({date}, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Now', function()
        local time = os.date('%H:%M:%S')
        vim.api.nvim_put({time}, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('DateTime', function()
        local date = os.date('%Y-%m-%d')
        local time = os.date('%H:%M:%S')
        vim.api.nvim_put({date .. ' ' .. time}, 'c', true, true)
    end, {})

    vim.api.nvim_create_user_command('Frontmatter', function()
        local date = os.date('%Y-%m-%d')
        local header = {
            '---',
            'tags:',
            'date: ' .. date,
            '---'
        }
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, header)
    end, {})
end

return M 