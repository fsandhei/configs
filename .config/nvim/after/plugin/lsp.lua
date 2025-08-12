local il = require('inlay-hints')
il.setup()

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
   lsp.default_keymaps({ buffer = bufnr })
   -- format on save. This works for when only one languag server is running.
   lsp.buffer_autoformat()
   -- Enable inlay hinting.
   if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { 0 })
   end
end)

local lspconfig = require('lspconfig')

lspconfig.rust_analyzer.setup({
   settings = {
      ["rust-analyzer"] = {
         imports = {
            granularity = {
               group = "module",
            },
            prefix = "self",
         },
         cargo = {
            allFeatures = true,
            buildScripts = {
               enable = true,
            },
         },
         procMacro = {
            enable = true
         },
      }
   }
})

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

-- Auto completion
local cmp = require('cmp')

cmp.setup({
   mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
   }
})

lspconfig.gopls.setup({
   settings = {
      gopls = {
         analyses = {
            unusedparams = true,
         },
         staticcheck = true,
         gofumpt = true,
      },
   },
})
