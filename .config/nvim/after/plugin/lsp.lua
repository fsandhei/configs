local il = require('inlay-hints')
il.setup()

local lsp = require('lsp-zero').preset({})

-- lsp.preset("recommended")

lsp.on_attach(function(client, bufnr)
   lsp.default_keymaps({ buffer = bufnr })
   -- format on save. This works for when only one languag server is running.
   lsp.buffer_autoformat()
end)

-- Don't setup rust-analyzer; rust-tools will handle this for us.
lsp.skip_server_setup({ "rust_analyzer" })

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup({
   lsp.nvim_lua_ls()
})

lsp.setup()

local cmp = require('cmp')

cmp.setup({
   mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
   }
})

local rust_tools = require('rust-tools')

rust_tools.setup({
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})
