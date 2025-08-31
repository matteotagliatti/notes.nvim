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
    opts = {}, -- optional, see "Default Configuration" below
}
```

## Default Configuration

The plugin comes with a default configuration. You can override it by passing your own configuration table to the `opts` field when setting up the plugin.

```lua
{
    keymaps = {
        follow_link = "<leader>nf", -- following wiki links
        show_tags = "<leader>nt",   -- showing tags
        media = "<leader>nm",       -- create new media entry
        journal = {
            today = "<leader>njj",     -- opening journal for today
            yesterday = "<leader>njy", -- opening journal for yesterday
            tomorrow = "<leader>njt",  -- opening journal for tomorrow
        },
    },
    wikilink = {
        fg = nil, -- nil means use the default colorscheme
        underline = true,
    },
    journal = {
        dir = "journal", -- directory for journal entries
    },
    utils = {
        date_format = '%Y-%m-%d', -- date format
        time_format = '%H:%M:%S', -- time format
        space_replacement = "-",  -- space replacement character for filenames
    }
}
```

## Usage

### Commands

- `:Frontmatter` - Insert a frontmatter with `tags:`
- `:Today` - Insert the current date with format specified in the configuration
- `:Yesterday` - Insert the date of yesterday in the format specified in the configuration

### Wikilinks

- `<leader>nf` - Follow a wikilink. Wikilinks are created by using the `[[Note Title]]` syntax. This will create or open the note with the title `Note Title`.

### Tags

Supports tags inside the frontmatter and hashtags in the content.

- `<leader>nt` - Open a Telescope prompt with all the tags in the current directory and subdirectories. Press `<CR>` and a new Telescope prompt will open to search for files with the selected tag.
- `:Tag <tag>` - Open a Telescope prompt to search for files with the tag `<tag>`.
- `:TagsByDate <tag>` - Open a Telescope prompt showing files with the specified tag, ordered by date in frontmatter (most recent first). Files with dates appear first, followed by files without dates (alphabetically sorted).
- `:TagsForYear <tag> <year>` - Show count of files with the specified tag for a given year (e.g., `:TagsForYear book 2025`). Optionally browse and open the matching files.

### Journal

- `<leader>njj` - Open today's journal entry
- `<leader>njy` - Open yesterday's journal entry
- `<leader>njt` - Open tomorrow's journal entry
