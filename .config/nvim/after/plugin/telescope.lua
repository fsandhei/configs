local builtin = require('telescope.builtin')

vim.keymap.set('n', "<leader>fb", builtin.buffers, { noremap = true })
vim.keymap.set('n', "<leader>ff", builtin.find_files, { noremap = true })
vim.keymap.set('n', "<C-p>", builtin.git_files, { noremap = true })
vim.keymap.set('n', "<leader>fg", builtin.live_grep, { noremap = true })
