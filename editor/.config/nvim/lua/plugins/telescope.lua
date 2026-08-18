return {
   'nvim-telescope/telescope.nvim',
   version = '*',
   -- or                              , branch = '0.1.x',
   dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
   }
}
