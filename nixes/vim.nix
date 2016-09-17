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
    set guifont=Source\ Code\ Pro\ for\ Powerline\ Regular\ 9

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





    set background=dark
    highlight clear
    set t_Co=256
    let g:colors_name = "monokai"
    hi Cursor ctermfg=235 ctermbg=231 cterm=NONE guifg=#272822 guibg=#f8f8f0 gui=NONE
    hi Visual ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#49483e gui=NONE
    hi CursorLine ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
    hi CursorColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
    hi ColorColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
    hi LineNr ctermfg=102 ctermbg=237 cterm=NONE guifg=#90908a guibg=#3c3d37 gui=NONE
    hi VertSplit ctermfg=241 ctermbg=241 cterm=NONE guifg=#64645e guibg=#64645e gui=NONE
    hi MatchParen ctermfg=197 ctermbg=NONE cterm=underline guifg=#f92672 guibg=NONE gui=underline
    hi StatusLine ctermfg=231 ctermbg=241 cterm=bold guifg=#f8f8f2 guibg=#64645e gui=bold
    hi StatusLineNC ctermfg=231 ctermbg=241 cterm=NONE guifg=#f8f8f2 guibg=#64645e gui=NONE
    hi Pmenu ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi PmenuSel ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#49483e gui=NONE
    hi IncSearch ctermfg=235 ctermbg=186 cterm=NONE guifg=#272822 guibg=#e6db74 gui=NONE
    hi Search ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
    hi Directory ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi Folded ctermfg=242 ctermbg=235 cterm=NONE guifg=#75715e guibg=#272822 gui=NONE
    hi SignColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
    hi Normal ctermfg=231 ctermbg=235 cterm=NONE guifg=#f8f8f2 guibg=#272822 gui=NONE
    hi Boolean ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi Character ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi Comment ctermfg=242 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
    hi Conditional ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi Constant ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi Define ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi DiffAdd ctermfg=231 ctermbg=64 cterm=bold guifg=#f8f8f2 guibg=#46830c gui=bold
    hi DiffDelete ctermfg=88 ctermbg=NONE cterm=NONE guifg=#8b0807 guibg=NONE gui=NONE
    hi DiffChange ctermfg=NONE ctermbg=NONE cterm=NONE guifg=#f8f8f2 guibg=#243955 gui=NONE
    hi DiffText ctermfg=231 ctermbg=24 cterm=bold guifg=#f8f8f2 guibg=#204a87 gui=bold
    hi ErrorMsg ctermfg=231 ctermbg=197 cterm=NONE guifg=#f8f8f0 guibg=#f92672 gui=NONE
    hi WarningMsg ctermfg=231 ctermbg=197 cterm=NONE guifg=#f8f8f0 guibg=#f92672 gui=NONE
    hi Float ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi Function ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi Identifier ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
    hi Keyword ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi Label ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi NonText ctermfg=59 ctermbg=236 cterm=NONE guifg=#49483e guibg=#31322c gui=NONE
    hi Number ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi Operator ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi PreProc ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi Special ctermfg=231 ctermbg=NONE cterm=NONE guifg=#f8f8f2 guibg=NONE gui=NONE
    hi SpecialComment ctermfg=242 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
    hi SpecialKey ctermfg=59 ctermbg=237 cterm=NONE guifg=#49483e guibg=#3c3d37 gui=NONE
    hi Statement ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi StorageClass ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
    hi String ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi Tag ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi Title ctermfg=231 ctermbg=NONE cterm=bold guifg=#f8f8f2 guibg=NONE gui=bold
    hi Todo ctermfg=95 ctermbg=NONE cterm=inverse,bold guifg=#75715e guibg=NONE gui=inverse,bold
    hi Type ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
    hi rubyClass ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi rubyFunction ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi rubyInterpolationDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi rubySymbol ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi rubyConstant ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
    hi rubyStringDelimiter ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi rubyBlockParameter ctermfg=208 ctermbg=NONE cterm=NONE guifg=#fd971f guibg=NONE gui=italic
    hi rubyInstanceVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi rubyInclude ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi rubyGlobalVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi rubyRegexp ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi rubyRegexpDelimiter ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi rubyEscape ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi rubyControl ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi rubyClassVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi rubyOperator ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi rubyException ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi rubyPseudoVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi rubyRailsUserClass ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
    hi rubyRailsARAssociationMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi rubyRailsARMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi rubyRailsRenderMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi rubyRailsMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi erubyDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi erubyComment ctermfg=95 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
    hi erubyRailsMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi htmlTag ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi htmlEndTag ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi htmlTagName ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi htmlArg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi htmlSpecialChar ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi javaScriptFunction ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
    hi javaScriptRailsFunction ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi javaScriptBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi yamlKey ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
    hi yamlAnchor ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi yamlAlias ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
    hi yamlDocumentHeader ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
    hi cssURL ctermfg=208 ctermbg=NONE cterm=NONE guifg=#fd971f guibg=NONE gui=italic
    hi cssFunctionName ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi cssColor ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi cssPseudoClassId ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi cssClassName ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
    hi cssValueLength ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
    hi cssCommonAttr ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
    hi cssBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE

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
    map <C-q> :q<Return>

    map <left> h
    map <right> l
    map <up> k
    map <down> j

    vmap <C-c> "+yi
    vmap <C-x> "+c
    vmap <C-v> c<ESC>"+p
    imap <C-v> <C-r><C-o>+

    map <C-z> u
    map! <C-z> <esc>u
    map <C-y> <C-R>
    map! <C-y> <esc><C-R>
    map <C-Enter> o
    map <C-k> dd
    map <C-s> :w<Return>
    map! <C-s> <esc>:w<Return>
    "map <C-d> /\<<C-R>=expand('<cword>')<CR>\><CR>
    map <C-d> Yp
    map <C-f> /
    map <C-a> <esc>ggVG<CR>

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
    vmap <C-Delete> <leader>cu

    function! FindProjectName()
      let s:name = getcwd()
      if !isdirectory(".git")
        let s:name = substitute(finddir(".git", ".;"), "/.git", "", "")
      end
      if s:name != ""
        let s:name = matchstr(s:name, ".*", strridx(s:name, "/") + 1)
      end
      return s:name
    endfunction

    " Sessions only restored if we start Vim without args.
    function! RestoreSession(name)
      if a:name != ""
        if filereadable($HOME . "/.vim/sessions/" . a:name)
          execute 'source ' . $HOME . "/.vim/sessions/" . a:name
        end
      end
    endfunction

    " Sessions only saved if we start Vim without args.
    function! SaveSession(name)
      if a:name != ""
        execute 'mksession! ' . $HOME . '/.vim/sessions/' . a:name
      end
    endfunction

    " Restore and save sessions.
    if argc() == 0
      autocmd VimEnter * call RestoreSession(FindProjectName())
      autocmd VimLeave * call SaveSession(FindProjectName())
    end

    exec 'source '.fnameescape($HOME.'/.vimrc')
    '';
};
in
pkgs.vim_configurable.customize { name = "vim"; inherit vimrcConfig; }
