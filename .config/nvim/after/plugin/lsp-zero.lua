local lsp = require('lsp-zero').preset({})

-- lsp.preset("recommended")

lsp.on_attach(function(client, bufnr)
   lsp.default_keymaps({ buffer = bufnr })
   lsp.buffer_autoformat()
end)

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({ "rust_analyzer" })

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup({
   lsp.nvim_lua_ls()
})

lsp.setup()
