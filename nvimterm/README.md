# NvimTerm - Terminal Manager Plugin

A Neovim plugin for managing a persistent terminal session with programmatic read/write capabilities.

## Features

- **Persistent Terminal**: Maintains a single terminal session across plugin calls
- **Control Character Support**: Send control sequences, Alt/Meta keys, and raw bytes
- **Screen Reading**: Read visible terminal content with cursor position
- **Window Management**: Show/hide terminal panel with configurable positioning
- **Lua API**: Simple programmatic interface for automation

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/nvimterm",
  config = function()
    require("term-manager").setup({
      height = 20,  -- Terminal window height
      position = 'bottom'  -- Position of terminal panel
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/nvimterm",
  config = function()
    require("term-manager").setup()
  end
}
```

## Usage

### Basic Commands

```vim
:TermManagerShow    " Show the terminal panel
:TermManagerRead    " Print current screen contents
:TermManagerWrite echo hello  " Send text to terminal
```

### Lua API

```lua
local term = require('term-manager')

-- Show/hide terminal
term.show()
term.hide()
term.toggle()

-- Write to terminal
term.write('ls -la\n')                    -- Send command
term.write(term.keys.CTRL_C)              -- Send Ctrl+C
term.write(term.alt_key('f'))             -- Send Alt+F
term.write({'echo "test"', term.keys.ENTER})  -- Send multiple items

-- Read screen contents
local screen = term.read_screen()
print(vim.inspect(screen.lines))         -- Current visible lines
print(screen.cursor_pos)                 -- Cursor position
print(screen.dimensions)                 -- Terminal dimensions
```

### Control Characters

The plugin provides helpers for common control sequences:

```lua
local term = require('term-manager')

-- Predefined keys
term.keys.CTRL_C      -- '\x03'
term.keys.CTRL_D      -- '\x04'  
term.keys.CTRL_Z      -- '\x1a'
term.keys.ESC         -- '\x1b'
term.keys.ENTER       -- '\r'
term.keys.TAB         -- '\t'
term.keys.BACKSPACE   -- '\x08'
term.keys.DELETE      -- '\x7f'

-- Helper functions
term.ctrl_key('a')    -- Generate Ctrl+A
term.alt_key('f')     -- Generate Alt+F (ESC + f)
```

## Configuration

```lua
require('term-manager').setup({
  height = 15,        -- Terminal window height (default: 15)
  position = 'bottom' -- Terminal position (default: 'bottom')
})
```

## Examples

### Interactive Shell Session

```lua
local term = require('term-manager')

-- Start a Python REPL
term.show()
term.write('python\n')

-- Wait a moment, then send Python code
vim.defer_fn(function()
  term.write('print("Hello, World!")\n')
  
  -- Read the output after execution
  vim.defer_fn(function()
    local screen = term.read_screen()
    for _, line in ipairs(screen.lines) do
      if line:match('Hello, World!') then
        print("Found output: " .. line)
      end
    end
  end, 100)
end, 500)
```

### Automated Testing

```lua
local term = require('term-manager')

local function run_test(command, expected_output)
  term.write(command .. '\n')
  
  vim.defer_fn(function()
    local screen = term.read_screen()
    local output = table.concat(screen.lines, '\n')
    
    if output:match(expected_output) then
      print("✓ Test passed: " .. command)
    else
      print("✗ Test failed: " .. command)
    end
  end, 1000)
end

-- Run tests
term.show()
run_test('echo "test1"', 'test1')
run_test('echo "test2"', 'test2')
```

## API Reference

### Functions

- `setup(opts)` - Initialize plugin with configuration
- `show()` - Show terminal panel
- `hide()` - Hide terminal panel  
- `toggle()` - Toggle terminal panel visibility
- `write(data)` - Send data to terminal (string, table, or number)
- `read_screen()` - Read current visible screen contents
- `get_cursor_position()` - Get terminal cursor position

### Objects

- `keys` - Table of common control character constants
- `ctrl_key(char)` - Generate control key combination
- `alt_key(char)` - Generate Alt/Meta key combination

## License

MIT License - see LICENSE file for details.