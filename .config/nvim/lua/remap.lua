vim.keymap.set('n', "j", "gj", { noremap = true })
vim.keymap.set('n', "gj", "j", { noremap = true })

vim.keymap.set('n', "k", "gk", { noremap = true })
vim.keymap.set('n', "gk", "k", { noremap = true })

vim.keymap.set('n', "<left>", "<cmd>bp<CR>", { noremap = true })
vim.keymap.set('n', "<right>", "<cmd>bn<CR>", { noremap = true })

-- Mappings to yank to the 'real' clipboard.
vim.keymap.set('n', "<leader>y", "\"+y", { noremap = true })
vim.keymap.set('v', "<leader>y", "\"+y", { noremap = true })
vim.keymap.set('n', "<leader>Y", "\"+Y", { noremap = true })
vim.keymap.set('v', "<leader>Y", "\"+Y", { noremap = true })

vim.keymap.set('n', "<leader>p", "\"+p", { noremap = true })
vim.keymap.set('v', "<leader>p", "\"+p", { noremap = true })
vim.keymap.set('n', "<leader>P", "\"+P", { noremap = true })
vim.keymap.set('v', "<leader>P", "\"+P", { noremap = true })

-- " very magic by default
vim.keymap.set('n', "/", "/\\v", { noremap = true })
vim.keymap.set('n', "?", "?\\v", { noremap = true })

vim.keymap.set('n', "<C-h>", "<cmd>nohlsearch<CR>", { noremap = true })
vim.keymap.set('v', "<C-h>", "<cmd>nohlsearch<CR>", { noremap = true })

-- Convenience remap for pasting over highlighted text with content from buffer.
vim.keymap.set('x', "<leader>p", "\"_dP")
