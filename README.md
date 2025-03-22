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
```

## Usage

### Commands

- `:Frontmatter` - Insert a frontmatter with `tags:`
- `:Today` - Insert the current date with format specified in the configuration
- `:Yesterday` - Insert the date of yesterday in the format specified in the configuration
- `:Now` - Insert the current time in the format specified in the configuration
- `:DateTime` - Insert the current date and time in the format specified in the configuration

### Formatting

- `<leader>b` - Make the selected text bold in visual mode
- `<leader>i` - Make the selected text italic in visual mode
- `<leader>w` - Create or open a wikilink with the selected text in visual mode

### Wikilinks

- `<leader>nf` - Follow a wikilink. Wikilinks are created by using the `[[Note Title]]` syntax. This will create or open the note with the title `Note Title`.

### Tags

Supports tags inside the frontmatter and hashtags in the content.

- `<leader>nt` - Open a Telescope prompt with all the tags in the current directory and subdirectories. Press `<CR>` and a new Telescope prompt will open to search for files with the selected tag.
- `:Tag <tag>` - Open a Telescope prompt to search for files with the tag `<tag>`.

### Journal

- `<leader>nj` - Open the journal file.
- `<leader>nd` - Open the daily note file.
