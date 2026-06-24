local il = require('inlay-hints')
il.setup()

vim.opt.signcolumn = "yes:1"

vim.diagnostic.config({
   -- No inlay diagnostic warning/error text.
   virtual_text = true,
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

vim.api.nvim_create_autocmd('LspAttach', {
   group = vim.api.nvim_create_augroup('UserLspConfig', {}),
   callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local bufnr = ev.buf

      -- Set up default keymaps (equivalent to lsp.default_keymaps)
      local opts = { buffer = bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>cf', function()
         vim.lsp.buf.format { async = true }
      end, opts)

      -- Format on save (equivalent to lsp.buffer_autoformat)
      vim.api.nvim_create_autocmd('BufWritePre', {
         buffer = bufnr,
         callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
         end,
      })
      -- Go format on save. Organize imports and formats code.
      vim.api.nvim_create_autocmd('BufWritePre', {
         pattern = "*.go",
         callback = function()
            vim.lsp.buf.format({ async = false })
         end
      })

      -- Enable inlay hints
      if vim.lsp.inlay_hint then
         vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
   end,
})

vim.lsp.config('luals', {
   cmd = { 'lua-language-server' },
   filetypes = { 'lua' },
   root_markers = { '.luarc.json', '.luarc.jsonc' },
})

vim.lsp.enable({ 'luals', 'rust_analyzer', 'gopls' })

-- Auto completion
local cmp = require('cmp')

cmp.setup({
   mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-e>'] = cmp.mapping.abort(),
   }),
   snippet = {
      expand = function(args)
         require("luasnip").lsp_expand(args.body)
      end,
   },
   sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "nvim_lua" },
      { name = "luasnip" },
      { name = "path" },
   }, {
      { name = "buffer", keyword_length = 3 },
   }),
})
