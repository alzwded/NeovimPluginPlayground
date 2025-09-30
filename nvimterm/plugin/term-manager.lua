-- Plugin entry point for term-manager
-- This file is automatically loaded by Neovim when the plugin is installed

if vim.g.loaded_term_manager then
  return
end
vim.g.loaded_term_manager = 1

-- Set up the plugin with default configuration
local term_manager = require('term-manager')
term_manager.setup()

-- Optional: Create global keymaps (uncomment if desired)
-- vim.keymap.set('n', '<leader>tt', term_manager.toggle, { desc = 'Toggle terminal' })
-- vim.keymap.set('n', '<leader>ts', term_manager.show, { desc = 'Show terminal' })
-- vim.keymap.set('n', '<leader>th', term_manager.hide, { desc = 'Hide terminal' })