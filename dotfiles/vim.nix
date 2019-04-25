{ variables, config, pkgs, lib }:

let
  nodeGlobalBinPath = "${variables.homeDir}/.npm-packages/bin";
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

  cocNeovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        call plug#begin('${variables.homeDir}/.local/share/nvim/plugged')
        Plug 'neoclide/coc.nvim', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-json', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-tsserver', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-html', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-css', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-yaml', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-python', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-highlight', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-emmet', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-snippets', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-pairs', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-lists', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-vimtex', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-yank', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-prettier', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-eslint', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-tslint-plugin', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'neoclide/coc-stylelint', {'do': '${pkgs.yarn}/bin/yarn install --frozen-lockfile'}
        Plug 'akiyosi/gonvim-fuzzy'
        Plug 'Shougo/dein.vim'
        call plug#end()

        let mapleader=","
        syntax enable
        set termguicolors
        set title
        function! ProjectName()
          return substitute( getcwd(), '.*\/\([^\/]\+\)', '\1', ''' )
        endfunction
        set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)\ \-\ %{ProjectName()}%(\ %a%)
        " colorscheme monokai_pro
        colorscheme gruvbox
        set background=dark

        set guifont=Source\ Code\ Pro:h12

        set shell=sh

        filetype plugin on
        if has ("autocmd")
          filetype plugin indent on
        endif

        set clipboard=unnamedplus

        set number
        set mouse=a

        set colorcolumn=80
        set scrolloff=5

        set fixendofline

        autocmd FileType markdown set spell spelllang=en_us

        set cursorline

        if has("persistent_undo")
          set undodir=~/.undodir/
          set undofile
        endif

        set ai
        "set smartindent
        set nocopyindent
        set tabstop=4 shiftwidth=4 expandtab softtabstop=4

        set virtualedit=onemore
        set updatetime=200

        let g:better_whitespace_enabled=1
        let g:strip_whitespace_on_save=1
        let g:strip_whitespace_confirm=0

        let g:gonvim_fuzzy_ag_cmd="${pkgs.ag}/bin/ag --nogroup --column --nocolor"

        nmap <PageUp> 10<up>
        imap <PageUp> <esc>10<up>li
        nmap <PageDown> 10<down>
        imap <PageDown> <esc>10<down>li

        vmap <PageUp> 10<up>
        vmap <PageDown> 10<down>
        vmap <S-PageUp> 10<up>
        vmap <S-PageDown> 10<down>
        imap <S-PageUp> <esc>v10<up>
        imap <S-PageDown> <esc>lv10<down>
        nmap <S-PageUp> v10<up>
        nmap <S-PageDown> v10<down>

        nmap <C-S-Right> vw
        nmap <C-S-Left> hvb
        imap <C-S-Right> <esc>vw
        imap <C-S-Left> <esc>hvb

        nmap <C-s> :w<CR>
        imap <C-s> <esc>:w<cr>i<right>

        map <C-z> u
        map! <C-z> <esc>u
        map <C-y> <C-R>
        map! <C-y> <esc><C-R>

        nmap <C-k> "_dd
        imap <C-k> <esc>"_ddi
        vmap <C-k> "_d

        nmap <C-x> dd
        imap <C-x> <esc>ddi
        vmap <C-x> d

        map <C-q> <ESC>:qall<Return>
        map! <C-q> <ESC>:qall<Return>

        map <C-w> <ESC>:bd<Return>
        map! <C-w> <ESC>:bd<Return>

        nmap <A-d> yyp
        nmap <C-d> yyp
        vmap <A-d> yp
        vmap <C-d> yp
        imap <A-d> <esc>yypi
        imap <C-d> <esc>yypi

        nmap <A-PageUp> :bprev<Return>
        imap <A-PageUp> <esc>:bprev<Return>
        nmap <A-PageDown> :bnext<Return>
        imap <A-PageDown> <esc>:bnext<Return>

        nmap <C-PageUp> :bprev<Return>
        imap <C-PageUp> <esc>:bprev<Return>
        nmap <C-PageDown> :bnext<Return>
        imap <C-PageDown> <esc>:bnext<Return>

        vmap <Tab> >gv
        vmap <S-Tab> <gv
        imap <S-Tab> <esc>v<i
        nmap <Tab> v><esc>
        nmap <S-Tab> v<<esc>

        nmap <C-Down> :m .+1<CR>==
        nmap <C-Up> :m .-2<CR>==
        imap <C-Down> <Esc>:m .+1<CR>==gi
        imap <C-Up> <Esc>:m .-2<CR>==gi
        vmap <C-Down> :m '>+1<CR>gv=gv
        vmap <C-Up> :m '<-2<CR>gv=gv

        imap <C-b> <esc>mzgg=G`zi
        nmap <C-b> mzgg=G`z

        nmap <A-/> <leader>c<space>j
        vmap <A-/> <leader>c<space>
        imap <A-/> <esc><leader>c<space>ji

        nmap <A-m> %
        imap <A-m> <esc>%i
        vmap <A-m> %

        nmap <C-Right> w
        vmap <C-Right> w
        nmap <C-Left> b
        vmap <C-Left> b

        nmap <A-BS> "_dvb
        imap <A-BS> <esc>"_dvbi
        nmap <A-Delete> "_daw
        imap <A-Delete> <C-o>"_daw

        imap <CR> <CR>

        nmap <C-g> :GV<cr>
        imap <C-g> <esc>:GV<cr>

        nmap <C-a> gg0vG$
        imap <C-a> <esc>gg0vG$

        nmap <A-v> v
        imap <A-v> <esc>v

        imap <C-v> <esc>lP`]li
        nmap <C-v> P`]
        vmap <C-v> P`]

        imap <C-c> <C-o>yy
        nmap <C-c> yy
        vmap <C-c> y

        nmap <S-Down> vj
        nmap <S-Up> vk
        nmap <S-Left> vh
        nmap <S-Right> vl

        imap <S-Down> <esc>vj
        imap <S-Up> <esc>vk
        imap <S-Left> <esc>vh
        imap <S-Right> <esc>lv

        vmap <S-Down> j
        vmap <S-Up> k
        vmap <S-Left> h
        vmap <S-Right> l

        nmap <C-Enter> o
        imap <C-Enter> <C-o>o

        nmap <A-Right> :wincmd l<cr>
        nmap <A-Left> :wincmd h<cr>
        nmap <C-=> :vsplit<cr>
        nmap <C--> :hide<cr>

        nmap <C-p> :GonvimFuzzyBuffers<cr>
        nmap <C-o> :GonvimFuzzyFiles<cr>
        nmap <C-f> :GonvimFuzzyBLines<cr>
        nmap <A-f> :call GonvimFuzzyAgOpen()<cr>

        map <C-u> <esc>:UndotreeToggle<CR>

        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd

        func! GonvimFuzzyAgOpen()
          call inputsave()
          let text = input('Search in CWD')
          call inputrestore()
          if !empty(text)
            call gonvim_fuzzy#ag(text)
          endif
        endf

        " if hidden is not set, TextEdit might fail.
        set hidden

        " Some server have issues with backup files, see #649
        set nobackup
        set nowritebackup

        " Better display for messages
        "set cmdheight=0

        " Smaller updatetime for CursorHold & CursorHoldI
        set updatetime=300

        " don't give |ins-completion-menu| messages.
        set shortmess+=c

        " always show signcolumns
        set signcolumn=yes

        " Use tab for trigger completion with characters ahead and navigate.
        " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> for trigger completion.
        inoremap <silent><expr> <c-space> coc#refresh()

        " Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
        " Coc only does snippet and additional edit on confirm.
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

        " Use `[c` and `]c` for navigate diagnostics
        nmap <silent> [c <Plug>(coc-diagnostic-prev)
        nmap <silent> ]c <Plug>(coc-diagnostic-next)

        " Remap keys for gotos
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K for show documentation in preview window
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if &filetype == 'vim'
            execute 'h '.expand('<cword>')
          else
            call CocAction('doHover')
          endif
        endfunction

        " Highlight symbol under cursor on CursorHold
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Remap for rename current word
        nmap <leader>rn <Plug>(coc-rename)

        " Remap for format selected region
        vmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
        vmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)

        " Remap for do codeAction of current line
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Fix autofix problem of current line
        nmap <leader>qf  <Plug>(coc-fix-current)

        " Use `:Format` for format current buffer
        command! -nargs=0 Format :call CocAction('format')

        " Use `:Fold` for fold current buffer
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)


        " Using CocList
        " Show all diagnostics
        nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
        " Manage extensions
        nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
        " Show commands
        nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document
        nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
        " Search workspace symbols
        nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
        " Do default action for next item.
        nnoremap <silent> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list
        nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
      '';
      packages.myVimPackage = with pkgs.vimPlugins; with vimPlugins; {
        start = [
          vim-plug gruvbox vim-nix vim-gitgutter undotree vim-better-whitespace
        ];
        opt = [ ];
      };
    };
  };

  gonvimToml = ''
    [Editor]
    # Editor minimum width (>= 800)
    Width = 800
    # Editor minimum height (>= 600)
    Height = 600
    # Editor font-family, font-size, linespace.
    FontFamily = "Monospace"
    FontSize = 14
    Linespace = 0
    # neovim extend feature
    ExtCmdline = true
    ExtWildmenu = true
    ExtPopupmenu = true
    ExtTabline  = true
    # Gonvim copy the yank text to clipboad
    Clipboard = true
    # Editor cursor blink
    CursorBlink = true
    # Disable IME in Normal mode
    DisableImeInNormal = false
    # load vimscript after setting of g:gonvim_running=1
    GinitVim = ''''
        set guifont=Source\ Code\ Pro:h13
    ''''
    # start fullscreen
    StartFullscreen = false

    [Statusline]
    Visible = true
    # textLabel / icon / background / none
    ModeIndicatorType = "textLabel"
    # Color setting per vim-modes, if you want to change
    NormalModeColor = "#3cabeb"
    CommandModeColor = "#5285b8"
    InsertModeColor = "#2abcb4"
    ReplaceModeColor = "#ff8c0a"
    VisualModeColor = "#9932cc"
    TerminalModeColor = "#778899"
    # Statusline component
    # Left = [ "mode", "filepath", "filename" ]
    # Right = [ "message", "git", "filetype", "fileformat", "fileencoding", "curpos", "lint" ]


    [Tabline]
    Visible = true

    [Lint]
    Visible = true

    [ScrollBar]
    Visible = false

    [ActivityBar]
    Visible = true
    DropShadow = false

    [MiniMap]
    Visible = true

    [SideBar]
    Visible = false
    DropShadow = false
    Width = 300
    AccentColor = "#5596ea"

    [Workspace]
    # name: directoryname
    # full: /path/to/directoryname
    # minimum: /p/t/directoryname
    PathStyle = "minimum"
    # Restore session-information that was ended without being saved
    RestoreSession = false
    # File open command in gonvim file explorer
    FileExplorerOpenCmd = ":tabnew"


    [Dein]
    # toml file path for dein.vim
    TomlFile = '/home/matejc/.config/nvim/dein.toml'
  '';

  myNeovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        let mapleader=","
        syntax enable
        set termguicolors
        set title
        function! ProjectName()
          return substitute( getcwd(), '.*\/\([^\/]\+\)', '\1', ''' )
        endfunction
        set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)\ \-\ %{ProjectName()}%(\ %a%)
        " colorscheme monokai_pro
        colorscheme gruvbox
        set background=dark

        set guifont=Source\ Code\ Pro\ for\ Powerline:h12

        set shell=sh

        filetype plugin on
        if has ("autocmd")
          filetype plugin indent on
        endif

        set clipboard=unnamedplus

        set number
        set mouse=a

        set colorcolumn=80
        set scrolloff=5

        function TrimEndLines()
          if !IsBinary()
            let save_cursor = getpos(".")
            :silent! %s#\($\n\s*\)\+\%$##
            call setpos('.', save_cursor)
          endif
        endfunction

        fun! IsBinary()
            return system('${pkgs.file}/bin/file -ib ' . shellescape(expand('%:p'))) !~# '^text/plain'
        endfun

        au BufWritePre * call TrimEndLines()
        set fixendofline

        autocmd FileType markdown set spell spelllang=en_us

        let NERDTreeIgnore=['node_modules']
        let NERDTreeShowHidden=1
        let g:NERDTreeDirArrowExpandable = '▸'
        let g:NERDTreeDirArrowCollapsible = '▾'

        nmap <C-\> :call NERDTreeIfOpen()<cr>
        imap <C-\> <esc>:call NERDTreeIfOpen()<cr>

        let g:ctrlp_cmd = 'CtrlPMixed'
        let g:ctrlp_custom_ignore = {
          \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
          \ 'file': '\v\.(exe|so|dll)$',
          \ 'link': 'result',
          \ }
        let g:ctrlp_show_hidden = 1

        let g:airline#extensions#tabline#enabled = 1
        let g:airline_powerline_fonts = 1
        " let g:airline_theme='base16_monokai'
        let g:airline_theme='wombat'

        " Add spaces after comment delimiters by default
        let g:NERDSpaceDelims = 1

        " Use compact syntax for prettified multi-line comments
        let g:NERDCompactSexyComs = 1

        " Align line-wise comment delimiters flush left instead of following code indentation
        let g:NERDDefaultAlign = 'left'

        " Allow commenting and inverting empty lines (useful when commenting a region)
        let g:NERDCommentEmptyLines = 0

        " Enable trimming of trailing whitespace when uncommenting
        let g:NERDTrimTrailingWhitespace = 1

        " Enable NERDCommenterToggle to check all selected lines is commented or not
        let g:NERDToggleCheckAllLines = 1

        let g:better_whitespace_enabled=1
        let g:strip_whitespace_on_save=1

        set cursorline

        if has("persistent_undo")
          set undodir=~/.undodir/
          set undofile
        endif

        set ai
        set smartindent
        set nocopyindent
        set tabstop=4 shiftwidth=4 expandtab softtabstop=4

        let loaded_matchit = 1

        let g:deoplete#enable_at_startup = 1
        let g:deoplete#sources#ternjs#tern_bin = '${nodeGlobalBinPath}/tern'

        set virtualedit=onemore

        let g:ctrlsf_ackprg='${pkgs.ag}/bin/ag'
        let g:ctrlsf_search_mode = 'async'
        let g:ctrlsf_default_view_mode = 'compact'
        let g:ctrlsf_auto_focus = {
          \ "at": "start"
          \ }
        let g:ctrlsf_auto_close = {
          \ "normal" : 0,
          \ "compact": 0
          \}
        func! CtrlSFIfOpen()
          if ctrlsf#win#FindMainWindow() != -1
            call ctrlsf#Quit()
          else
            call inputsave()
            let text = input('Search: ')
            call inputrestore()
            if !empty(text)
              call ctrlsf#Search(text)
            endif
          endif
        endf

        func! NERDTreeIfOpen()
          if exists("b:NERDTree") && b:NERDTree.isTabTree()
            :NERDTreeClose
          else
            :NERDTreeFind
          endif
        endf

        let g:VM_default_mappings = 0
        let g:VM_maps = {}
        let g:VM_maps['Find Under']                  = '<C-n>'
        let g:VM_maps['Find Subword Under']          = '<C-n>'
        let g:VM_maps["Select All"]                  = '<leader>A'
        let g:VM_maps["Start Regex Search"]          = 'g/'
        let g:VM_maps["Add Cursor Down"]             = '<A-Down>'
        let g:VM_maps["Add Cursor Up"]               = '<A-Up>'
        let g:VM_maps["Add Cursor At Pos"]           = 'g<space>'
        let g:VM_maps["Visual Regex"]                = 'g/'
        let g:VM_maps["Visual All"]                  = '<leader>A'
        let g:VM_maps["Visual Add"]                  = '<A-a>'
        let g:VM_maps["Visual Find"]                 = '<A-f>'
        let g:VM_maps["Visual Cursors"]              = '<A-c>'

        let g:vinarise_enable_auto_detect=1

        " SuperTab like snippets behavior.
        " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
        imap <expr><TAB>
          \ pumvisible() ? "\<C-n>" :
          \ neosnippet#expandable_or_jumpable() ?
          \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
          \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

        nmap <PageUp> 10<up>
        imap <PageUp> <esc>10<up>li
        nmap <PageDown> 10<down>
        imap <PageDown> <esc>10<down>li

        vmap <PageUp> 10<up>
        vmap <PageDown> 10<down>
        vmap <S-PageUp> 10<up>
        vmap <S-PageDown> 10<down>
        imap <S-PageUp> <esc>v10<up>
        imap <S-PageDown> <esc>lv10<down>
        nmap <S-PageUp> v10<up>
        nmap <S-PageDown> v10<down>

        nmap <C-S-Right> vw
        nmap <C-S-Left> hvb
        imap <C-S-Right> <esc>vw
        imap <C-S-Left> <esc>hvb

        nmap <C-s> :w<CR>
        imap <C-s> <esc>:w<cr>l:call deoplete#smart_close_popup()<cr>i

        map <C-z> u
        map! <C-z> <esc>u
        map <C-y> <C-R>
        map! <C-y> <esc><C-R>

        nmap <C-k> "_dd
        imap <C-k> <esc>"_ddi
        vmap <C-k> "_d

        nmap <C-x> dd
        imap <C-x> <esc>ddi
        vmap <C-x> d

        map <C-q> <ESC>:qall<Return>
        map! <C-q> <ESC>:qall<Return>

        map <C-w> <ESC>:bd<Return>
        map! <C-w> <ESC>:bd<Return>

        nmap <A-d> yyp
        nmap <C-d> yyp
        vmap <A-d> yp
        vmap <C-d> yp
        imap <A-d> <esc>yypi
        imap <C-d> <esc>yypi

        map <C-u> <esc>:UndotreeToggle<CR>

        nmap <A-PageUp> :bprev<Return>
        imap <A-PageUp> <esc>:bprev<Return>
        nmap <A-PageDown> :bnext<Return>
        imap <A-PageDown> <esc>:bnext<Return>

        nmap <C-PageUp> :bprev<Return>
        imap <C-PageUp> <esc>:bprev<Return>
        nmap <C-PageDown> :bnext<Return>
        imap <C-PageDown> <esc>:bnext<Return>

        imap <C-p> <esc>:CtrlPMixed<Return>

        vmap <Tab> >v
        vmap <S-Tab> <v
        imap <S-Tab> <esc>v<i
        nmap <Tab> v><esc>
        nmap <S-Tab> v<<esc>

        nmap <C-Down> :m .+1<CR>==
        nmap <C-Up> :m .-2<CR>==
        imap <C-Down> <Esc>:m .+1<CR>==gi
        imap <C-Up> <Esc>:m .-2<CR>==gi
        vmap <C-Down> :m '>+1<CR>gv=gv
        vmap <C-Up> :m '<-2<CR>gv=gv

        imap <C-b> <esc>mzgg=G`zi
        nmap <C-b> mzgg=G`z

        autocmd FileType javascript nmap <buffer> <C-b> :call JsBeautify()<cr>
        autocmd FileType javascript imap <buffer> <C-b> <esc>:call JsBeautify()<cr>i

        nmap <A-/> <leader>c<space>j
        vmap <A-/> <leader>c<space>
        imap <A-/> <esc><leader>c<space>ji

        nmap <A-m> %
        imap <A-m> <esc>%i
        vmap <A-m> %

        nmap <C-Right> w
        vmap <C-Right> w
        nmap <C-Left> b
        vmap <C-Left> b

        nmap <A-BS> "_dvb
        imap <A-BS> <esc>"_dvbi
        nmap <A-Delete> "_daw
        imap <A-Delete> <C-o>"_daw

        imap <CR> <CR>
        nmap <CR> o

        nmap <C-g> :GV<cr>
        imap <C-g> <esc>:GV<cr>

        nmap <C-a> gg0vG$
        imap <C-a> <esc>gg0vG$

        nmap <A-v> v
        imap <A-v> <esc>v

        map <C-f> <esc>:call CtrlSFIfOpen()<cr>

        imap <C-v> <esc>lP`]li
        nmap <C-v> P`]
        vmap <C-v> P`]

        imap <C-c> <C-o>yy
        nmap <C-c> yy
        vmap <C-c> y

        nmap <S-Down> vj
        nmap <S-Up> vk
        nmap <S-Left> vh
        nmap <S-Right> vl

        imap <S-Down> <esc>vj
        imap <S-Up> <esc>vk
        imap <S-Left> <esc>vh
        imap <S-Right> <esc>lv

        vmap <S-Down> j
        vmap <S-Up> k
        vmap <S-Left> h
        vmap <S-Right> l

        nmap <C-Enter> o
        imap <C-Enter> <C-o>o

        nmap <C-o> :edit<space>

        nmap <A-Right> :wincmd l<cr>
        nmap <A-Left> :wincmd h<cr>
        nmap <C-=> :vsplit<cr>
        nmap <C--> :hide<cr>

        nmap <C-b> :Vinarise<space>
      '';
      packages.myVimPackage = with pkgs.vimPlugins; with vimPlugins; {
        start = [
          vim-monokai-pro ale vim-nix The_NERD_tree
          ctrlp vim-airline vim-airline-themes The_NERD_Commenter
          vim-better-whitespace vim-expand-region undotree
          vim-jsbeautify nerdtree-git-plugin deoplete-nvim deoplete-jedi
          deoplete-ternjs deoplete-go vim-gitgutter fugitive
          vim-visual-multi gv-vim vim-pasta gruvbox
          yajs-vim es-next-syntax-vim neomake typescript-vim nvim-typescript
          neosnippet neosnippet-snippets auto-pairs ctrlsf-vim
          vinarise-vim
        ];
        opt = [ ];
      };
    };
  };
in [{
  target = "${variables.homeDir}/bin/nvim-my";
  source = "${myNeovim}/bin/nvim";
}{
  target = "${variables.homeDir}/bin/nvim";
  source = "${cocNeovim}/bin/nvim";
} {
  target = "${variables.homeDir}/.config/nvim/autoload/plug.vim";
  source = "${pkgs.vimPlugins.vim-plug}/share/vim-plugins/vim-plug/plug.vim";
} {
  target = "${variables.homeDir}/.gonvim/setting.toml";
  source = "${builtins.toFile "gonvim-setting.toml" gonvimToml}";
}]
