return {
   -- LSP Support
   -- nvim-lspconfig: Providing basic, default LSP client configurations.
   -- Is used for installing LSPs for various languages.
   { 'neovim/nvim-lspconfig' }, -- Required
   {                            -- Optional
      'williamboman/mason.nvim',
      build = function()
         pcall(vim.cmd, 'MasonUpdate')
      end,
   },
   { 'williamboman/mason-lspconfig.nvim' }, -- Optional

   -- Autocompletion
   { 'hrsh7th/nvim-cmp' }, -- Required
   { 'hrsh7th/cmp-buffer' },
   { 'hrsh7th/cmp-path' },
   { 'hrsh7th/cmp-nvim-lsp' }, -- Required
   {
      'L3MON4D3/LuaSnip',
      version = "v2.*",
      build = "make install_jsregexp"
   } -- Required
}
