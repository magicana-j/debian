" ============================================================
" ~/.vimrc  -  Debian 13 (trixie) / Vim 9.1 向け設定
" ============================================================

call plug#begin()

" List your plugins here
Plug 'tpope/vim-sensible'

call plug#end()

" ============================================================
" 基本設定
" ============================================================
filetype plugin indent on
syntax enable

set encoding=utf-8
set fileencoding=utf-8
set number
set relativenumber
set cursorline
set showmatch
set hlsearch
set incsearch
set ignorecase
set smartcase
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set backspace=indent,eol,start
set wildmenu
set laststatus=2
set clipboard=unnamedplus
set hidden

" ============================================================
" その他キーマップ
" ============================================================
nnoremap <Esc><Esc> :nohlsearch<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
