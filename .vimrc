let s:dein_dir = expand('~/.vim/plugins')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#add('Shougo/dein.vim')
  call dein#add ('Shougo/neocomplcache')
  call dein#add ('Shougo/unite.vim')
  call dein#add ('Shougo/vimfiler.vim')
  call dein#add ('w0ng/vim-hybrid')
  call dein#add ('rking/ag.vim')
  call dein#add ('itchyny/lightline.vim')
  call dein#add ('tpope/vim-fugitive')
  call dein#add ('scrooloose/nerdtree')
endif
if dein#check_install()
  call dein#install()
endif
call dein#end()
filetype plugin indent on

" Switch syntax highlighting on, when the terminal has colors
syntax on
" Use vim, not vi api
set nocompatible
" No backup files
set nobackup
" No write backup
set nowritebackup
" No swap file
set noswapfile
" Command history
set history=100
" Always show cursor
set ruler
" Show incomplete commands
set showcmd
" インクリメンタルサーチ. １文字入力毎に検索を行う
set incsearch
" 検索結果をハイライト
set hlsearch
" 検索パターンに大文字を含んでいたら大文字小文字を区別する
set smartcase
" 検索パターンに大文字小文字を区別しない
set ignorecase
" A buffer is marked as ‘hidden’ if it has unsaved changes, and it is not currently loaded in a window
" if you try and quit Vim while there are hidden buffers, you will raise an error:
" E162: No write since last change for buffer “a.txt”
set hidden
" Turn word wrap off
set nowrap
" Allow backspace to delete end of line, indent and start of line characters
set backspace=indent,eol,start
" タブ入力を複数の空白入力に置き換える
set expandtab
" 画面上でタブ文字が占める幅
set tabstop=2
" 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set softtabstop=2
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に前の行の構文をチェックし次の行のインデントを増減する
set smartindent
" smartindentで増減する幅
set shiftwidth=2
" The number of spaces inserted for a tab (used for auto indenting)
set shiftwidth=2
" 行番号を表示
set number
" Highlight tailing whitespace
set list listchars=tab:\ \ ,trail:·
" Get rid of the delay when pressing O (for example)
" http://stackoverflow.com/questions/2158516/vim-delay-before-o-opens-a-new-line
set timeout timeoutlen=1000 ttimeoutlen=100
" ステータスバーの表示
set laststatus=2
" Hide the toolbar
set guioptions-=T
" UTF encoding
set encoding=utf-8
scriptencoding utf-8
" Autoload files that have changed outside of vim
set autoread
" Use system clipboard
" http://stackoverflow.com/questions/8134647/copy-and-paste-in-vim-via-keyboard-between-different-mac-terminals
set clipboard+=unnamed
" Don't show intro
set shortmess+=I
" Better splits (new windows appear below and to the right)
set splitbelow
set splitright
" カーソルラインをハイライト
set cursorline
" Ensure Vim doesn't beep at you every time you make a mistype
set visualbell
" コマンドモードの補完
set wildmenu
" redraw only when we need to (i.e. don't redraw when executing a macro)
set lazyredraw
" highlight a matching [{()}] when cursor is placed on start/end character
set showmatch
" Set built-in file system explorer to use layout similar to the NERDTree plugin
" let g:netrw_liststyle=3
" Always highlight column 80 so it's easier to see where
" cutoff appears on longer screens
" autocmd BufWinEnter * highlight ColorColumn ctermbg=darkred
" set colorcolumn=80

" vim-indent-guides

" vimfiler
let g:vimfiler_as_default_explorer = 1
noremap <silent> :tree :VimFiler -split -simple -winwidth=45 -no-quit
noremap <C-X><C-T> :VimFiler -split -simple -winwidth=45 -no-quit<ENTER>
autocmd FileType vimfiler nmap <buffer> <CR> <Plug>(vimfiler_expand_or_edit)

" neocomplcache
let g:acp_enableAtStartup = 0 " Disable AutoComplPop.
let g:neocomplcache_enable_at_startup = 1 " Use neocomplcache.
let g:neocomplcache_enable_smart_case = 1 " Use smartcase.
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3 " Set minimum syntax keyword length.
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : ''
    \ }

" NERDTree
nnoremap <silent><C-T> :NERDTreeToggle<CR>


" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

set guifont=Ricty\ for\ Powerline:h18
" vim-lightline setting
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'mode_map': {'c': 'NORMAL'},
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
  \ },
  \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
  \ 'subseparator': { 'left': "\u2b81", 'right': "\u2b83" },
  \ 'component_function': {
  \   'modified': 'LightLineModified',
  \   'readonly': 'LightLineReadonly',
  \   'fugitive': 'LightLineFugitive',
  \   'filename': 'LightLineFilename',
  \   'fileformat': 'LightLineFileformat',
  \   'filetype': 'LightLineFiletype',
  \   'fileencoding': 'LightLineFileencoding',
  \   'mode': 'LightLineMode'
  \ }
  \ }

function! LightLineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '\u2b64' : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
  \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
  \  &ft == 'unite' ? unite#get_status_string() :
  \  &ft == 'vimshell' ? vimshell#get_status_string() :
  \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
  \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      let _ = fugitive#head()
      return strlen(_) ? "\u2b60 "._ : ''
    endif
  catch
  endtry
    return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return winwidth(0) > 70 ? lightline#mode() : ''
endfunction


filetype on
