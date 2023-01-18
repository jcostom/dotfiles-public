set nocompatible
filetype off
syntax on
filetype plugin indent on
set modelines=0
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
set backspace=indent,eol,start
set ttyfast
set laststatus=2
set showmode
set showcmd
set matchpairs+=<:>
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}
set encoding=utf-8
set hlsearch
set incsearch
set ignorecase
set smartcase
set viminfo='100,<9999,s100
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview"

call plug#begin()

Plug 'junegunn/vim-easy-align'
Plug 'junegunn/vim-github-dashboard'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()