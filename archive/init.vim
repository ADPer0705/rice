" ===== General Settings =====
set mouse=a
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set autoindent
colorscheme elflord
set clipboard=unnamedplus
set hlsearch
set incsearch

" ===== ADPER'S CONFIGURATIONS =====

" Leader key
let mapleader = " "

" Move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize splits
nnoremap <A-h> :vertical resize -2<CR>
nnoremap <A-l> :vertical resize +2<CR>
nnoremap <A-j> :resize +2<CR>
nnoremap <A-k> :resize -2<CR>

" Create splits (mimicking i3/tmux split style)
nnoremap <Leader>: :split<CR>
nnoremap <Leader>" :vsplit<CR>
