" Don't try to be vi compatible
set nocompatible

set history=10000
set wildmenu
" For tab tab completion in commands (https://stackoverflow.com/a/13043196/6419007 & https://stackoverflow.com/a/21977418/6419007)
set wildmode=longest:list,full

set visualbell

" Case
set ignorecase
set smartcase

" Show trainling stuff. see https://stackoverflow.com/a/32588802/6419007
" Disable with `invlist`
set list   " Display unprintable characters
set listchars=tab:▸\ ,trail:·,extends:»,precedes:« " Unprintable chars mapping

set showcmd

" https://stackoverflow.com/a/30423919/6419007
" d -> delete
" Leader d -> cut
nnoremap x "ax
nnoremap d "ad
nnoremap c "ac
nnoremap D "aD
nnoremap C "aC
vnoremap d "ad
vnoremap c "ac

nnoremap <leader>q :q<CR>

nnoremap <leader>c "+c
nnoremap <leader>d "+d
nnoremap <leader>D "+D
nnoremap <leader>C "+C
nnoremap <leader>p "ap
nnoremap <leader>P "aP
vnoremap <leader>d "+d
nnoremap <leader>dd "+dd

set splitright

" Hide highlighting after searching
" nnoremap <silent> <cr> :noh<CR><CR>
nmap <silent> <esc><esc> :noh<cr>

" Could help for large files. Should be larger than the longest lines
set synmaxcol=200

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

let mapleader = " "

" Show line numbers
set number

" Show file stats
set ruler

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

set hlsearch
set incsearch
set showmatch

" Color scheme (terminal)
set t_Co=256
set background=dark
