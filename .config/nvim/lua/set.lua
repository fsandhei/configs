-- vim.opt.runtimepath:append { "~/dev/github/nvim-base16" }

-- Toggle highlight of current line.
vim.opt.cursorline = true
-- Set highlight of current line to only highlight the line number.
vim.opt.cursorlineopt = "number"
-- Enable True Color schemes
vim.opt.termguicolors = true
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


vim.api.nvim_create_autocmd("FileType", {
   pattern = "tex",
   callback = function(args)
      vim.keymap.set('n', '<leader>lb', ':!pdflatex -interaction=nonstopmode %<CR>', { buffer = args.buf })
   end
})
