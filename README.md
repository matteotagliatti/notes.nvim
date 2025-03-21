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
        follow_link = "<leader>nf",
        show_tags = "<leader>nt",
    },
    highlights = {
        wikilink = {
            fg = nil,
            underline = true,
        }
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

- `<leader>nf` - Follow a wikilink.
- `[[Note Title]]` - Create a wikilink to a note with the title `Note Title`.

### Tags

Supports tags inside the frontmatter and hashtags in the content.

- `<leader>nt` - Open a floating window with all the tags in the current directory and subdirectories. Press `<CR>` to open the selected tag in Telescope.
- `:Tag <tag>` - Open a Telescope prompt to search for files with the tag `<tag>`.
