{ variables, config, pkgs, lib }:
let
  nodeGlobalBinPath = "${variables.homeDir}/.npm-packages/bin";
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

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

in {
  target = "${variables.homeDir}/bin/nvim";
  source = "${myNeovim}/bin/nvim";
}
