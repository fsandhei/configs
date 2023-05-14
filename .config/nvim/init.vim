set nocompatible          " required
filetype off

set rtp+=~/.config/nvim/bundle/Vundle.vim
set rtp+=~/dev/github/nvim-base16

"Colors and background settings
set background=dark
let base16colorspace=256
let g:base16_shell_path="~/dev/github/nvim-base16/colors"
colorscheme base16-gruvbox-dark-hard


"Swap j and k with gj and gk, respectively.
nnoremap j gj
nnoremap gj j

nnoremap k gk
nnoremap gk k

" Move in buffer with arrow keys
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" " Copy to clipboard
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>yy "+yy

vnoremap <M-y> "*y
nnoremap <M-Y> "*yg_
nnoremap <M-yy> "*yy

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" fzf mappings
" Open buffer
nnoremap <leader>fb :Buffers<CR>
" Open finder that searches for files
nnoremap <leader>ff :Files<CR>
" Open finder that searches for files within the git repository
nnoremap <C-p> :GFiles<CR>

" very magic by default
nnoremap / /\v
nnoremap ? ?\v

" Ctrl+h to stop searching
nnoremap <C-h> :nohlsearch<CR>
vnoremap <C-h> :nohlsearch<CR>

" -------- PLUGINS --------

call plug#begin(stdpath("data") . '/plugged')

" Preview markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Extension host for language servers.
" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Improved syntatical language support.
Plug 'rust-lang/rust.vim'

" Latex plugin
Plug 'lervag/vimtex'

" C++ enhanged syntax highlighting
Plug 'octol/vim-cpp-enhanced-highlight'

" Formatting
Plug 'sbdchd/neoformat'

" Semantic language support
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-lua/completion-nvim'

" Fuzzy search.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plugin around fzf that gives vim convenience functions.
Plug 'junegunn/fzf.vim'

" GUI improvements
Plug 'andymass/vim-matchup'
Plug 'itchyny/lightline.vim'
call plug#end()

filetype plugin indent on " required

syntax enable
set hidden
set relativenumber number
set tabstop=8
set softtabstop=3
set shiftwidth=3
set textwidth=120
set expandtab 
set autoindent
set laststatus=2
set noshowmode
" Copy from neovim to system clipboard.
set clipboard^=unnamed,unnamedplus 
" don't give |ins-completion-menu| messages.
set shortmess+=c 
" Enable mouse usage (all modes) in terminals
set mouse=a 
" Highlight yank
au TextYankPost * silent! lua vim.highlight.on_yank()

"Latex mappings
autocmd FileType tex map <C-b> :w <CR> <plug>(vimtex-compile-ss)
autocmd FileType tex noremap <Space><Space> <Esc>/<++><Enter>"_c4l

"Latex settings
let g:tex_flavor = 'latex'
let g:vimtex_context_pdf_viewer = 'zathura'
let g:vimtex_view_general_viewer = 'zathura'

" Autocompletion
" Better completion
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <c-CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Navigate through diagnostics.
nmap <silent> g( <Plug>(coc-diagnostic-prev)
nmap <silent> g) <Plug>(coc-diagnostic-next)
nmap <silent> g(( :CocDiagnostics<CR>
" Go to definition
nmap <silent> gd <Plug>(coc-definition)
" Go to type definition
nmap <silent> gy <Plug>(coc-type-definition)

" What are these settings? Do they cause indentation and line breaks?
set foldmethod=indent
set foldlevel=99

" -------- FILE SPECIFIC SETTINGS --------
" PEP-8 indentation
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=119 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set filetype=python 
set encoding=utf-8

au BufNewFile,BufRead *.sh
   \ set tabstop=4       |
   \ set softtabstop=4   |
   \ set shiftwidth=4    |
   \ set expandtab       |
   \ set fileformat=unix |
   \ set filetype=bash

" Run neoformat on save
augroup fmt
  autocmd!
  autocmd BufWritePre * Neoformat
augroup END

" rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" Fast out comment line
autocmd FileType cpp nnoremap <leader>c 0i//<Space><Esc>0
autocmd FileType cpp xnoremap <leader>c 0I//<Space><Esc>0

autocmd FileType h nnoremap <leader>c 0i//<Space><Esc>0
autocmd FileType h xnoremap <leader>c 0I//<Space><Esc>0

autocmd FileType hpp nnoremap <leader>c 0i//<Space><Esc>0
autocmd FileType hpp xnoremap <leader>c 0I//<Space><Esc>0

autocmd FileType sh nnoremap <leader>c 0i#<Space><Esc>0
autocmd FileType sh vnoremap <leader>c 0I#<Space><Esc>0

autocmd FileType py nnoremap <leader>c 0i#<Space><Esc>0
autocmd FileType py xnoremap <leader>c 0I#<Space><Esc>0

autocmd FileType rs nnoremap <leader>c ^i//<Space><Esc>0
autocmd FileType rs xnoremap <leader>c ^I//<Space><Esc>0

"On save, run xrdb on ~/.config/.Xresources
autocmd BufWritePost ~/.config/.Xresources !xrdb ~/.config/.Xresources
