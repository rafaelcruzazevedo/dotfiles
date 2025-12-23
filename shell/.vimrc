set termguicolors
syntax on

" Environment
set nocompatible           " disable vi compatibility
set noswapfile             " no swap files
set nobackup               " no backup files
set dir=/tmp,/var/tmp      " swap directory (if enabled)
set enc=utf8               " encoding
set ff=unix                " file format
set ffs=unix               " file formats
set hidden                 " allow hidden buffers
set autoread               " auto reload changed files
set ttyfast                " fast terminal
set visualbell             " visual bell instead of beep
set mousehide              " hide mouse while typing

" UI
set number                 " show line numbers
set ruler                  " show cursor position
set laststatus=2           " always show status line
set wildmenu               " command line completion
set wildmode=list:longest,full
set cmdheight=2            " command line height
set noshowcmd              " don't show incomplete commands
set noshowmode             " don't show mode (status line handles this)
set shortmess=filtIoOA     " shorten messages
set report=0               " always report changes
set nostartofline          " keep cursor column on page up/down

" Search
set incsearch              " incremental search
set hlsearch               " highlight search results
set showmatch              " show matching brackets
set mat=5                  " blink matching brackets (1/10 sec)
set ignorecase             " case insensitive search
set smartcase              " unless uppercase used
set gdefault               " global replace by default

" Indentation
set autoindent             " auto indent
set copyindent             " copy previous indent
set smartindent            " smart indent

" Tabs (2 spaces)
set tabstop=2              " tab width
set softtabstop=2          " soft tab width
set shiftwidth=2           " indent width
set shiftround             " round indent to multiples
set expandtab              " use spaces, not tabs

" Text
set nowrap                 " don't wrap lines
set nolist                 " don't show invisible chars
set nofoldenable           " disable folding
set formatoptions+=n       " recognize numbered lists
set virtualedit=block      " virtual edit in visual block
set backspace=indent,eol,start  " backspace over everything
set whichwrap+=<,>,h,l,[,]      " wrap cursor movement

" Tags
set tags+=vendor.tags

" Ignore patterns
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/*cache,*/logs,*/web/bundles,.DS_Store

" Persistent undo
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" Clipboard (use system clipboard)
if has('clipboard')
  set clipboard=unnamed
endif

" Strip all trailing whitespace in file (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction

noremap <leader>ss :call StripWhitespace()<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Git commit messages
  autocmd FileType gitcommit setlocal textwidth=72 formatoptions+=tcq
augroup END

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
