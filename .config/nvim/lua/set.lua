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

-- Highlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function() vim.highlight.on_yank() end
})