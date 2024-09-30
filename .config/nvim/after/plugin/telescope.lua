local builtin = require('telescope.builtin')

vim.keymap.set('n', "<leader>fb", builtin.buffers, { noremap = true })
vim.keymap.set('n', "<leader>ff", function() builtin.find_files({ hidden = true }) end, { noremap = true })
vim.keymap.set('n', "<C-p>", builtin.git_files, { noremap = true })
vim.keymap.set('n', "<leader>fg", builtin.live_grep, { noremap = true })
