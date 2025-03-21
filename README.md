# notes.nvim

A Neovim plugin for taking notes.

## Requirements

- Neovim >= 0.8.0

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'matteotagliatti/notes.nvim',
    config = function()
        require('notes').setup()
    end,
}
```

## Usage

### Commands

- `:Today` - Insert the current date in the format `YYYY-MM-DD`
- `:Yesterday` - Insert the date of yesterday in the format `YYYY-MM-DD`
- `:Now` - Insert the current time in the format `HH:MM:SS`
- `:DateTime` - Insert the current date and time in the format `YYYY-MM-DD HH:MM:SS`

### Wikilinks

- `[[Note Title]]` - Create a wikilink to a note with the title `Note Title`.
