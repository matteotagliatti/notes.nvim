local M = {}

-- Check if telescope is available
local has_telescope, _ = pcall(require, 'telescope.builtin')
if not has_telescope then
    error("This plugin requires telescope.nvim to be installed")
end

-- Function to check if a file contains a specific tag
local function file_has_tag(filepath, tag)
    local content = vim.fn.readfile(filepath)
    if not content then return false end
    content = table.concat(content, "\n")

    -- Check frontmatter
    local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
    if frontmatter then
        local tag_line = string.match(frontmatter, "tags: ([^\n]+)")
        if tag_line then
            for t in string.gmatch(tag_line, "[^,]+") do
                if vim.trim(t) == tag then
                    return true
                end
            end
        end
    end

    -- Check hashtags
    for t in string.gmatch(content, "#([%w-]+)") do
        if t == tag then
            return true
        end
    end

    return false
end

-- Function to get all files containing a specific tag
local function get_files_with_tag(tag)
    -- Use find command to recursively get all markdown files
    local files = vim.fn.systemlist('find . -type f -name "*.md"')
    local result = {}

    for _, file in ipairs(files) do
        if file_has_tag(file, tag) then
            table.insert(result, file)
        end
    end

    return result
end

-- Function to extract tags from frontmatter
local function extract_frontmatter_tags(content)
    local tags = {}
    local frontmatter = string.match(content, "^%-%-%-\n(.-)\n%-%-%-")
    if frontmatter then
        -- Look specifically for the tags field
        local tag_line = string.match(frontmatter, "tags: ([^\n]+)")
        if tag_line then
            -- Split by comma and trim each tag
            for tag in string.gmatch(tag_line, "[^,]+") do
                local trimmed_tag = vim.trim(tag)
                if trimmed_tag ~= "" then
                    table.insert(tags, trimmed_tag)
                end
            end
        end
    end
    return tags
end

-- Function to extract hashtags from content
local function extract_hashtags(content)
    local tags = {}
    for tag in string.gmatch(content, "#([%w-]+)") do
        table.insert(tags, tag)
    end
    return tags
end

-- Function to get all unique tags from a file
local function get_file_tags(filepath)
    local content = vim.fn.readfile(filepath)
    if not content then return {} end
    content = table.concat(content, "\n")

    local tags = {}
    local frontmatter_tags = extract_frontmatter_tags(content)
    local hashtags = extract_hashtags(content)

    -- Combine and deduplicate tags
    for _, tag in ipairs(frontmatter_tags) do
        tags[tag] = true
    end
    for _, tag in ipairs(hashtags) do
        tags[tag] = true
    end

    -- Convert back to array
    local result = {}
    for tag, _ in pairs(tags) do
        table.insert(result, tag)
    end
    return result
end

-- Function to get all tags from all markdown files in the current directory and subdirectories
local function get_all_tags()
    local tags = {}
    -- Use find command to recursively get all markdown files
    local files = vim.fn.systemlist('find . -type f -name "*.md"')

    -- First pass: collect all tags and their counts
    for _, file in ipairs(files) do
        local file_tags = get_file_tags(file)
        for _, tag in ipairs(file_tags) do
            if not tags[tag] then
                tags[tag] = 0
            end
            tags[tag] = tags[tag] + 1
        end
    end

    -- Convert to array of {tag, count} pairs and sort by tag name
    local result = {}
    for tag, count in pairs(tags) do
        table.insert(result, { tag = tag, count = count })
    end
    table.sort(result, function(a, b) return a.tag < b.tag end)
    return result
end

-- Function to show tags in a floating window
local function show_tags()
    local tag_data = get_all_tags()
    if #tag_data == 0 then
        vim.notify("No tags found in your notes", vim.log.levels.INFO)
        return
    end

    -- Format the content with tag counts
    local content = {}
    for _, data in ipairs(tag_data) do
        table.insert(content, string.format("%s (%d)", data.tag, data.count))
    end

    -- Create a custom picker
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local state = require('telescope.actions.state')
    local themes = require('telescope.themes').get_dropdown({
        previewer = false,
        winblend = 10,
    })

    pickers.new(themes, {
        prompt_title = "Notes Tags",
        finder = finders.new_table({
            results = content,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function()
            actions.select_default:replace(function()
                local selection = state.get_selected_entry()
                if selection then
                    local tag = string.match(selection[1], "([^(]+)")
                    if tag then
                        tag = vim.trim(tag)
                        local files = get_files_with_tag(tag)

                        -- Open another Telescope with files containing the tag
                        require('telescope.builtin').find_files({
                            prompt_title = "Notes with tag: " .. tag,
                            search_dirs = files,
                            find_command = nil,
                            attach_mappings = function(_, map)
                                map('i', '<CR>', actions.select_default)
                                map('n', '<CR>', actions.select_default)
                                return true
                            end,
                        })
                    end
                end
            end)
            return true
        end,
    }):find()
end

-- Function to search files by tag using Telescope
local function search_files_by_tag(tag)
    if tag == "" then
        vim.notify("Please provide a tag to search for", vim.log.levels.ERROR)
        return
    end

    local files = get_files_with_tag(tag)
    if #files == 0 then
        vim.notify("No files found with tag: " .. tag, vim.log.levels.INFO)
        return
    end

    -- Open Telescope with only the files containing the tag
    require('telescope.builtin').find_files({
        prompt_title = "Notes with tag: " .. tag,
        search_dirs = files,
        find_command = nil, -- Use default find command
        attach_mappings = function(_, map)
            local actions = require('telescope.actions')
            map('i', '<CR>', actions.select_default)
            map('n', '<CR>', actions.select_default)
            return true
        end,
    })
end

function M.setup_tags(keymap)
    -- Set up the keybinding for showing tags
    vim.keymap.set('n', keymap, show_tags, { desc = '[N]otes: Show [T]ags' })

    -- Create command to search files by tag
    vim.api.nvim_create_user_command('Tag', function(opts)
        search_files_by_tag(opts.args)
    end, {
        nargs = 1,
        complete = function()
            local tag_data = get_all_tags()
            local completions = {}
            for _, data in ipairs(tag_data) do
                table.insert(completions, data.tag)
            end
            return completions
        end
    })
end

return M
