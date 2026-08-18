-- Start treesitter
vim.api.nvim_create_autocmd('FileType', {
   pattern = { "c", "cpp", "toml", "python" },
   callback = function(ev)
      vim.treesitter.start(ev.buf)
   end
})
