" ============================================================
" vim-plug (auto-install)
" ============================================================
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
call plug#end()

" ============================================================
" General
" ============================================================
set nocompatible
filetype plugin indent on
syntax on

set encoding=utf-8
scriptencoding utf-8
set nobackup
set nowritebackup
set noswapfile
set hidden
set autoread
set clipboard+=unnamed
set shortmess+=I
set visualbell
set mouse=a
set history=500
set backspace=indent,eol,start

" ============================================================
" UI
" ============================================================
set number
set cursorline
set laststatus=2
set showcmd
set showmatch
set wildmenu
set wildmode=longest:full,full
set lazyredraw
set splitbelow
set splitright
set list listchars=tab:▸\ ,trail:·
set termguicolors
set timeout timeoutlen=1000 ttimeoutlen=100

silent! colorscheme catppuccin_mocha

" ============================================================
" Search
" ============================================================
set incsearch
set hlsearch
set ignorecase
set smartcase

" ============================================================
" Indent
" ============================================================
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent

" ============================================================
" Keymaps
" ============================================================
let mapleader = ' '

nnoremap <Esc><Esc> :nohlsearch<CR>

nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>h :History<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ============================================================
" Plugin Settings
" ============================================================
let g:lightline = { 'colorscheme': 'catppuccin_mocha' }
set updatetime=250
