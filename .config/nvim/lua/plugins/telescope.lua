return {
   'nvim-telescope/telescope.nvim',
   tag = 'v0.2.1',
   -- or                              , branch = '0.1.x',
   dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
   }
}
