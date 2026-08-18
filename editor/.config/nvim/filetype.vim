" Filetype settings inspired by Jon Gjengset
" TODO: Rewrite to Lua, so it can be integrated into the ftplugin directory.

augroup filetypedetect
  " Mail
  autocmd BufRead,BufNewFile /tmp/mutt*              setfiletype mail
  autocmd Filetype mail                              setlocal tw=72
  autocmd Filetype mail                              setlocal fo+=w
  " Git commit message
  autocmd Filetype gitcommit                         setlocal spell tw=72 colorcolumn=73
  " nftables
  autocmd BufRead,BufNewFile *.nft setfiletype nftables
  " Shorter columns in text
  autocmd Filetype tex setlocal tw=120 colorcolumn=121
  autocmd Filetype text setlocal tw=72 spell

  " No autocomplete in text
  autocmd BufRead,BufNewFile /tmp/mutt* let b:coc_enabled = 0
  autocmd Filetype tex let b:coc_enabled = 0
  autocmd Filetype text let b:coc_enabled = 0
  autocmd Filetype markdown let b:coc_enabled = 0
augroup END
