if has("win32")
    "Windows options here

    set nocompatible
    source $VIMRUNTIME/vimrc_example.vim
    "source $VIMRUNTIME/mswin.vim
    behave mswin

    set diffexpr=MyDiff()
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction

else
    if has("unix")
        let s:uname = system("uname")
        if s:uname == "Darwin\n"
            "Mac options here
        endif
    endif
endif

"
" My Settings
"
set packpath=~/.vim/
filetype plugin indent on
syntax on

if has("gui_running")
    " set guifont=JetBrains\ Mono:h15
    " set guifont=Droid\ Sans\ Mono:h14
    " set guifont=Menlo:h12
    " set guifont=DejaVu\ Sans
    let g:tex_conceal = ''

    set guioptions-=l
    set guioptions-=L
    set guioptions-=r
    set guioptions-=R
    set guioptions-=t
    set guioptions-=b
    set guioptions-=B
    set guioptions-=T
    set guiheadroom=1
endif

" Theme
packadd! vim-hybrid
set background=dark
colorscheme hybrid

"Set indentation
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

" Following makes searches case sensitive when there is an uppercase letter.
set ignorecase
set smartcase

" Do not save workfiles in source dir
set backupdir=$HOME/.vim/swap//
set directory=$HOME/.vim/swap//
set undodir=$HOME/.vim/swap//
set undofile

set nowrap
set cursorline "causes slow ruby files
set hlsearch
set nu "linenumbers
set smartcase
set showmatch
set autoindent
set ruler
set noerrorbells
set nocompatible
set showcmd
set mouse=a
set history=1000
set undolevels=1000
:set colorcolumn=80

" allow hidden buffers
set hidden

" Search in subfolders.
set path+=**

" Display all matching files when we tab complete
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico,*.DS_Store,*.swp
set wildignore+=*.pdf,*.psd
set wildignore+=*.o
set wildignore+=node_modules/*,bower_components/*,.git/*

" Generate tags
command! MakeTags !ctags -R .
" use ^] to jump to tag under cursor.
" use g^] for ambiguous tags.
" use ^t to jump back.
command! MakeRustTags !rusty-tags vi
autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/

" vim jumplist. 
" Ctrl+O and Ctrl+I can be used to jump back and forward.

" ^x^n find in this file
" ^x^] find tags only
" ^x^f find file
" ^x^k dictionary
set dictionary+=/usr/share/dict/words

" ctrp
packadd! ctrlp.vim
nnoremap <leader>. :CtrlPTag<cr>
" :help ctrlp.txt
" once ctrp is open
" Use <c-y> to create a new file and its parent directories.
" Use <c-z> to mark/unmark multiple files and <c-o> to open them.

" Tagbar
packadd! tagbar
nmap <F8> :TagbarToggle<CR>


" Tweaks for file browsing
let g:netrw_banner=0            " disable banner
let g:netrw_list_hide=netrw_gitignore#Hide()
"let g:netrw_liststyle=3         " tree view

" Snippets
nnoremap ,sc :-1read $HOME/.vim/snippets/skeleton.c<CR>4jA
nnoremap ,shtml :-1read $HOME/.vim/snippets/skeleton.html<CR>3jf>a
nnoremap ,spy :-1read $HOME/.vim/snippets/skeleton.py<CR>

" Disable hover tooltips -- slow ruby
set noballooneval
let g:netrw_nobeval = 1

" reload .vimrc
map ,vr :so $MYVIMRC<CR>
map ,vc :vsplit ~/.vim/peter.vimrc<CR>
map ,v.c :vsplit $MYVIMRC<CR>

" Add to .vimrc to enable project-specific vimrc
set exrc
set secure


" compile
"map <F5> :botright :copen <bar> AsyncRun make<CR>
"map ,b :botright :copen <bar> AsyncRun make<CR>
"map ,k :botright :copen <bar> AsyncRun make clean<CR>

" Notes
" - :cl to list errors
" - :cn, :cp to naviagate

" close quickfix
map ,c :copen<CR><C-W>J
map ,q :cclose<CR>
map <C-z> :cp<CR>
map <C-x> :cn<CR>


" == Maxscript ==
if has("win32")
    function! RunCurrentFileInMaxFunc()
        let cmdstr = 'python "' . $HOME . '/.vim/misc/runmxs/runmxs.py" "' .expand("%:p"). '"'
        let result = system(cmdstr)
        echo result
    endfunction
    :command RunCurrentFileInMax call RunCurrentFileInMaxFunc()
    map ,rm :RunCurrentFileInMax<CR>
endif

" == ALE ==
packadd! ale
" Disable enable: ALEToggle
highlight clear ALEErrorSign
highlight clear ALEWarningSign
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '.'
let g:ale_sign_column_always = 1
let g:LanguageClient_useVirtualText = 1
nmap <silent> <C-e> <Plug>(ale_next_wrap)
let g:ale_fixers = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'rust': ['rustfmt'],
            \}
let g:ale_linters = {
            \   'rust': ['rls'],
            \}
" Use quicklist instead
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_list_vertical = 1
" let g:ale_open_list = 1
" let g:ale_list_window_size = 5
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
map ;a :ALEToggle<CR>
map ;d :ALEDetail<CR>
map ;= :ALEFix<CR>
map ;g :ALEGoToDefinition<CR>
map ;f :ALEFindReferences<CR>
" set omnifunc=ale#completion#OmniFunc
let g:ale_completion_enabled = 1
set completeopt=menu,menuone,preview,noselect,noinsert
" let g:ale_completion_tsserver_autoimport = 1
let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_insert_leave = 0
" let g:ale_set_highlights = 0


" == ==
" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL

