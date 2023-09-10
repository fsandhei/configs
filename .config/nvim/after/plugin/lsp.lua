local il = require('inlay-hints')
il.setup()

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
   lsp.default_keymaps({ buffer = bufnr })
   -- format on save. This works for when only one languag server is running.
   lsp.buffer_autoformat()
end)

-- lsp.ensure_installed({
--    "rust_analyzer"
-- })

-- Let rust-tools handle setup of rust_analyzer
lsp.skip_server_setup({ "rust_analyzer" })

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup({
   lsp.nvim_lua_ls()
})

vim.diagnostic.config({
   -- No inlay diagnostic warning/error text.
   virtual_text = false,
   signs = true,
   update_in_insert = true,
   underline = true,
   severity_sort = false,
   float = {
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
   },
})

vim.api.nvim_create_autocmd({ "CursorHold" }, {
   callback = function()
      vim.diagnostic.open_float(nil, { focusable = false })
   end
})

lsp.setup()


local rust_tools = require('rust-tools')

rust_tools.setup({
   server = {
      on_attach = function(_, bufnr)
         vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, { buffer = bufnr })
      end
   }
})

local cmp = require('cmp')

cmp.setup({
   mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
   }
})
