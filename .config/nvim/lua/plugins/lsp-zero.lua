return {
   'VonHeikemen/lsp-zero.nvim',
   branch = 'v2.x',
   dependencies = {
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
      { 'hrsh7th/nvim-cmp' },     -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      { 'L3MON4D3/LuaSnip' }      -- Required
   }
}
