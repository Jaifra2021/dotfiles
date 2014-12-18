syntax on

" Allow mouse to resize splits without moving the cursor
set mouse=a
nnoremap <LeftMouse> m'<LeftMouse>
nnoremap <LeftRelease> <LeftRelease>g``

" Improve mouse selections when using vim in tmux
set ttymouse=xterm2

" Specify if vim window is in a dark or light terminal
set bg=dark

" Keep window split sizes from changing when closed
set noequalalways

" Enhanced mode for command-line/tab completion
set wildmenu
set wildignore+=*.o,*~,*.pyc,*.swp,*.swo

" Allow virtual editing in all modes (move cursor where nothing exists)
set virtualedit=all

" Set end-of-line format (dos, unix, mac)
set fileformat=unix

" Show cursor position at all times
set ruler

" Show partial command and display current mode in status line
set showcmd
set showmode

" Highlight all search matches and show in-progress matches while typing
set hlsearch
set incsearch

" Allow search commands to wrap around to end of buffer
set wrapscan

" Ignore case while searching, unless search has uppercase characters
set ignorecase
set smartcase

" Use spaces to insert a <tab> and set number of spaces that a <tab> inserts
set expandtab
set tabstop=4
set softtabstop=4

" Auto-indent new lines and set number of spaces for indent
set autoindent
set shiftwidth=4
set smarttab

" Round to 'shiftwidth' for << and >>
set shiftround

" Send file to printer in landscape mode
set popt=portrait:n

if has("autocmd")
    " Remember cursor position when re-editing a file
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exec "normal! g`\"" | endif

    " Change tab settings for different file types
    autocmd FileType gitcommit setlocal tw=72 spell
    autocmd FileType markdown setlocal ts=4 sts=4 sw=4 tw=80 fo=tcq expandtab
    autocmd FileType text setlocal ts=4 sts=4 sw=4 tw=80 fo=tcq expandtab
    autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab

    " Treat *.md as markdown file
    autocmd BufRead,BufNewFile *.md set filetype=markdown
endif

" Use 'Ctrl+c' to copy selected text with system clipboard in visual mode
vmap <C-c> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>

" Use 'Ctrl+v' to paste text from system clipboard in insert mode
imap <C-v> <ESC>:call setreg("\"",system("xclip -o -selection clipboard"))<CR>p")")")"))
