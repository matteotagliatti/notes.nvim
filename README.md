# notes.nvim

A Neovim plugin for taking notes.

## Requirements

- Neovim >= 0.8.0
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'matteotagliatti/notes.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim',
    },
    config = function()
        require('notes').setup()
    end,
}
```

## Default Configuration

The plugin comes with a default configuration. You can override the default configuration by passing a table to the `setup` function.

```lua
{
    keymaps = {
        follow_link = "<leader>nf",  -- default keybinding for following wiki links
        show_tags = "<leader>nt",    -- default keybinding for showing tags
        journal = "<leader>nj",      -- default keybinding for opening journal
        daily_note = "<leader>nd",   -- default keybinding for opening daily note
        formatting = {
            bold = "<leader>b",      -- default keybinding for bold in visual mode
            italic = "<leader>i",    -- default keybinding for italic in visual mode
            underline = "<leader>u", -- default keybinding for underline in visual mode
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
```

## Usage

### Commands

- `:Frontmatter` - Insert a frontmatter with the current `date` and the `tags`
- `:Today` - Insert the current date in the format `YYYY-MM-DD`
- `:Yesterday` - Insert the date of yesterday in the format `YYYY-MM-DD`
- `:Now` - Insert the current time in the format `HH:MM:SS`
- `:DateTime` - Insert the current date and time in the format `YYYY-MM-DD HH:MM:SS`

### Wikilinks

- `<leader>nf` - Follow a wikilink. Wikilinks are created by using the `[[Note Title]]` syntax. This will create a link to the note with the title `Note Title`.

### Tags

Supports tags inside the frontmatter and hashtags in the content.

- `<leader>nt` - Open a floating window with all the tags in the current directory and subdirectories. Press `<CR>` to open the selected tag in Telescope.
- `:Tag <tag>` - Open a Telescope prompt to search for files with the tag `<tag>`.

### Journal

- `<leader>nj` - Open the journal file.
- `<leader>nd` - Open the daily note file.
