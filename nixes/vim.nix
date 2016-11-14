{pkgs?import <nixpkgs> {}}:
let
vimrcConfig = {
  vam.knownPlugins = pkgs.vimPlugins;
  vam.pluginDictionaries = [ {
    names = [
        "airline"
        "ctrlp"
        "gitgutter"
        "undotree"
        "syntastic"
        "fugitive"
        "The_NERD_Commenter"
        "The_NERD_tree"
        "taglist"
        "youcompleteme"
        "molokai"
    ];
  }];
  customRC = ''
    set cindent
    set history=700
    set t_Co=256
    set tabpagemax=1000
    set colorcolumn=80
    let g:airline#extensions#branch#enabled = 1
    let g:airline#extensions#syntastic#enabled = 1
    let g:airline#extensions#ctrlp#enabled = 1
    let g:airline#extensions#undotree#enabled = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_theme='dark'
    let g:airline_detect_modified=1
    let g:airline_powerline_fonts = 1
    set guifont=Source\ Code\ Pro\ for\ Powerline\ Regular\ 11

    set laststatus=2
    set number

    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlPMixed'
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => General
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Set to auto read when a file is changed from the outside
    set autoread
    let mapleader = ","
    let g:mapleader = ","
    map <C-u> :UndotreeToggle<CR>
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => VIM user interface
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Set 5 lines to the cursor - when moving vertically using j/k
    set so=5
    " Ignore compiled files
    set wildignore=*.o,*~,*.pyc
    "Always show current position
    set ruler
    " Height of the command bar
    set cmdheight=1
    " Configure backspace so it acts as it should act
    set backspace=eol,start,indent
    set whichwrap+=<,>,h,l
    " Ignore case when searching
    set ignorecase
    " When searching try to be smart about cases
    set smartcase
    " Highlight search results
    set hlsearch
    " Makes search act like search in modern browsers
    set incsearch
    " Don't redraw while executing macros (good performance config)
    set lazyredraw
    " For regular expressions turn magic on
    set magic
    " Show matching brackets when text indicator is over them
    set showmatch
    " No annoying sound on errors
    set noerrorbells
    set novisualbell
    set t_vb=
    set tm=500
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => Colors and Fonts
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Enable syntax highlighting
    syntax enable
    let g:molokai_original = 1
    colorscheme molokai

    " Set utf8 as standard encoding and en_US as the standard language
    set encoding=utf8
    " Use Unix as the standard file type
    set ffs=unix,dos,mac

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => Text, tab and indent related
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set expandtab       "Use softtabstop spaces instead of tab characters for indentation
    set shiftwidth=4    "Indent by 4 spaces when using >>, <<, == etc.
    set softtabstop=4   "Indent by 4 spaces when pressing <TAB>

    set autoindent      "Keep indentation from previous line
    set smartindent     "Automatically inserts indentation in some cases

    " Be smart when using tabs ;)
    set smarttab
    " 1 tab == 4 spaces
    set tabstop=4
    set shiftround                  "Round spaces to nearest shiftwidth multiple
    set nojoinspaces                "Don't convert spaces to tabs

    func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
    endfunc
    autocmd BufWrite *.py :call DeleteTrailingWS()
    autocmd BufWrite *.coffee :call DeleteTrailingWS()

    set cursorline

    function! s:get_visual_selection()
      " Why is this not a built-in Vim script function?!
      let [lnum1, col1] = getpos("'<")[1:2]
      let [lnum2, col2] = getpos("'>")[1:2]
      let lines = getline(lnum1, lnum2)
      let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
      let lines[0] = lines[0][col1 - 1:]
      return join(lines, "\n")
    endfunction

    map <PageUp> 30<up>
    map <PageDown> 30<down>

    map <C-PageUp> :bprev<Return>
    map <C-PageDown> :bnext<Return>
    map <C-w> :bd<Return>
    map <C-n> :badd new.file
    map <C-q> :qall<Return>

    map <left> h
    map <right> l
    map <up> k
    map <down> j

    vmap <C-c> "+y
    nmap <C-c> "+yy
    imap <C-c> <esc>"+yyli

    vmap <C-x> "+c
    nmap <C-x> "+dd
    imap <C-x> <esc>"+ddi

    vmap <C-v> c<ESC>"+p
    nmap <C-v> "+p
    imap <C-v> <C-r><C-o>+

    map <C-z> u
    map! <C-z> <esc>u
    map <C-y> <C-R>
    map! <C-y> <esc><C-R>
    map <C-Enter> o
    imap <C-Enter> <esc>o
    map <C-k> dd
    map <C-s> :w<Return>
    map! <C-s> <esc>:w<Return>
    "map <C-d> /\<<C-R>=expand('<cword>')<CR>\><CR>
    map <C-d> Yp
    map <leader>f :grep -R '<C-R>=expand('<cword>')<CR>' .
    map <C-f> /<C-R>=expand('<cword>')<CR>
    "map <C-a> <esc>ggVG<CR>
    map <C-h> :%s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/g

    nnoremap <C-down> :m .+1<CR>==
    nnoremap <C-up> :m .-2<CR>==
    inoremap <C-down> <Esc>:m .+1<CR>==gi
    inoremap <C-up> <Esc>:m .-2<CR>==gi
    vnoremap <C-down> :m '>+1<CR>gv=gv
    vnoremap <C-up> :m '<-2<CR>gv=gv

    vmap <C-A-b> =

    nnoremap <Tab> >>_
    nnoremap <S-Tab> <<_
    inoremap <S-Tab> <C-D>
    vnoremap <Tab> >gv
    vnoremap <S-Tab> <gv

    " shift+arrow selection
    nmap <S-Up> v<Up>
    nmap <S-Down> v<Down>
    nmap <S-Left> v<Left>
    nmap <S-Right> v<Right>
    vmap <S-Up> <Up>
    vmap <S-Down> <Down>
    vmap <S-Left> <Left>
    vmap <S-Right> <Right>
    imap <S-Up> <Esc>v<Up>
    imap <S-Down> <Esc>v<Down>
    imap <S-Left> <Esc>v<Left>
    imap <S-Right> <Esc>v<Right>

    imap <C-BS> <C-W>
    imap <C-Delete> <C-O>dw

    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar

    " remember cursor position
    "au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    " remember buffers
    "set viminfo^=%

    " File type detection. Indent based on filetype. Recommended.
    filetype plugin indent on

    map <C-\> :NERDTreeToggle<CR>

    nmap <BS> i<BS>
    map <C-t> :TlistToggle<CR>

    let g:NERDCustomDelimiters = { 'nix': { 'left': '#' } }

    vmap <C-Insert> <leader>cc
    vmap <C-S-Insert> <leader>cu

    set splitright
    nnoremap <leader><right> <C-W><C-L>
    nnoremap <leader><left> <C-W><C-H>

    nnoremap <C-]> <C-W><C-L>
    nnoremap <C-[> <C-W><C-H>

    nnoremap <leader>c :vsp<CR>

    let g:syntastic_javascript_jshint_exec = '/home/matejc/.npm-packages/bin/jshint'
    let g:syntastic_jshint_exec = '/home/matejc/.npm-packages/bin/jshint'

    function! SessionId()
      return system("echo " . getcwd() . " | ${pkgs.coreutils}/bin/sha1sum - | ${pkgs.gawk}/bin/awk '{printf $1}'")
    endfunction

    function! MakeSession()
      let b:sessiondir = $HOME . "/.vim/sessions/" . SessionId()
      if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' b:sessiondir
        redraw!
      endif
      let b:filename = b:sessiondir . '/session.vim'
      exe "mksession! " . b:filename
    endfunction

    function! LoadSession()
      let b:sessiondir = $HOME . "/.vim/sessions/" . SessionId()
      let b:sessionfile = b:sessiondir . "/session.vim"
      if (filereadable(b:sessionfile))
        exe 'source ' b:sessionfile
      else
        echo "No session loaded."
      endif
    endfunction

    " Adding automatons for when entering or leaving Vim
    au VimEnter * nested :call LoadSession()
    au VimLeave * :call MakeSession()

    au FileType javascript setl sw=2 sts=2 et

    " indent: mixed indent within a line
    " long:   overlong lines
    " trailing: trailing whitespace
    " mixed-indent-file: different indentation in different lines
    let g:airline#extensions#whitespace#checks = [ 'trailing', 'mixed-indent-file' ]

    exec 'source '.fnameescape($HOME.'/.vimrc')
    '';
};
in
pkgs.vim_configurable.customize { name = "vim"; inherit vimrcConfig; }
