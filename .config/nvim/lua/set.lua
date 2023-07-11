vim.opt.runtimepath:append { "~/.config/nvim/bundle/Vundle.vim" }
vim.opt.runtimepath:append { "~/dev/github/nvim-base16" }

-- Colors and background settings
vim.o.background = dark
vim.g.base16colorspace = 256
vim.g.base16_shell_path = "~/dev/github/nvim-base16/colors"
-- vim.cmd([[colorscheme base16-gruvbox-dark-hard]])
vim.cmd.colorscheme("base16-gruvbox-dark-hard")

-- Make line numbers be relative to curser.
vim.opt.relativenumber = true
-- Show current line number.
vim.opt.number = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 3
vim.opt.shiftwidth = 3
vim.opt.textwidth = 120
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.laststatus = 2
-- Don't show the active nvim mode. Let lualine handle that.
vim.opt.showmode = false
vim.opt.clipboard:prepend { "unnamed", "unnamedplus" }
-- Fast update time
vim.opt.updatetime = 50

-- Set leader key to backslash
vim.g.mapleader = "\\"

-- Signcolumn always on, otherwise it would shift the text each time
-- diagnostics appear/become resolved.
vim.opt.signcolumn = "yes"

-- Highlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function() vim.highlight.on_yank() end
})

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
