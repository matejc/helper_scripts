{ variables, config, pkgs, lib }:

let
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

  customRC = ''
    " if hidden is not set, TextEdit might fail.
    set hidden

    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    " Better display for messages
    set cmdheight=1

    " You will have bad experience for diagnostic messages when it's default 4000.
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

    " Use <c-space> to trigger completion.
    inoremap <silent><expr> <c-space> coc#refresh()

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
    " Coc only does snippet and additional edit on confirm.
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
    " Or use `complete_info` if your vim support it, like:
    " inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

    " Use `[g` and `]g` to navigate diagnostics
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
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
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s).
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap for do codeAction of current line
    nmap <leader>ac  <Plug>(coc-codeaction)
    " Fix autofix problem of current line
    nmap <leader>qf  <Plug>(coc-fix-current)

    " Create mappings for function text object, requires document symbols feature of languageserver.
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)

    " Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
    nmap <silent> <C-d> <Plug>(coc-range-select)
    xmap <silent> <C-d> <Plug>(coc-range-select)

    " Use `:Format` to format current buffer
    command! -nargs=0 Format :call CocAction('format')

    " Use `:Fold` to fold current buffer
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " use `:OR` for organize import of current buffer
    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

    " Add status line support, for integration with other plugin, checkout `:h coc-status`
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function',''')}

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

    set guifont = "${variables.font}"
    set termguicolors
    set cursorline
    set number

    colorscheme gruvbox
    set background=dark

    set title
    function! ProjectName()
      return substitute( getcwd(), '.*\/\([^\/]\+\)', '\1', ''' )
    endfunction
    set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)\ \-\ %{ProjectName()}%(\ %a%)

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

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=1
    let g:strip_whitespace_confirm=0

    if has("persistent_undo")
      set undodir=~/.undodir/
      set undofile
    endif

    set ai
    set smartindent
    set nocopyindent
    set tabstop=4 shiftwidth=4 expandtab softtabstop=4

    set virtualedit=onemore

    nno <silent> <c-m> :messages<cr>
    nno <silent> <c-w> :bd<cr>
    map <c-q> <esc>:qall
    nno <silent> <c-s> :w<CR>
    ino <silent> <c-s> <esc>:w<CR>
    nno <silent> <c-PageUp> :bprev<cr>
    nno <silent> <c-PageDown> :bnext<cr>
    nno <silent> <cr> o
    nno <silent> <c-cr> o
    imap <silent> <c-cr> <esc>o

    nno <a-u> u
    ino <a-u> <esc>u
    nno <a-r> <C-R>
    ino <a-r> <esc><C-R>
    imap <c-z> <esc>ui
    nmap <c-z> u

    map <C-u> <esc>:UndotreeToggle<CR>

    imap <C-b> <esc>mzgg=G`zi
    nmap <C-b> mzgg=G`z

    autocmd FileType javascript nmap <buffer> <C-b> :call JsBeautify()<cr>
    autocmd FileType javascript imap <buffer> <C-b> <esc>:call JsBeautify()<cr>i

    nmap <PageUp> 10<up>
    nmap <PageDown> 10<down>
    imap <PageUp> <esc>10<up>i
    imap <PageDown> <esc>10<down>i
    vmap <PageUp> 10<up>
    vmap <PageDown> 10<down>
    vmap <S-PageUp> 10<up>
    vmap <S-PageDown> 10<down>
    nmap <S-PageUp> v10<up>
    nmap <S-PageDown> v10<down>
    nmap <S-Down> vj
    nmap <S-Up> vk
    nmap <S-Left> vh
    nmap <S-Right> vl
    vmap <S-Down> j
    vmap <S-Up> k
    vmap <S-Left> h
    vmap <S-Right> l
    nmap <C-S-Right> vw
    nmap <C-S-Left> hvb

    nmap <C-k> "_dd
    imap <C-k> <esc>"_ddi
    vmap <C-k> "_d

    nmap <C-x> dd
    imap <C-x> <esc>ddi
    vmap <C-x> d

    nmap <C-a> gg0vG$
    imap <C-a> <esc>gg0vG$

    imap <C-c> <C-o>yy
    nmap <C-c> yy
    vmap <C-c> y

    nmap <c-v> p
    imap <c-v> <esc>p
    vmap <c-v> <esc>p

    nmap <C-S-Down> :copy .<cr>
    vmap <C-S-Down> :copy '><cr>
    imap <C-S-Down> <esc>:copy .<cr>i

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

    " let g:bufferline_echo = 0
    " autocmd VimEnter *
    "   \ let &statusline='%{bufferline#refresh_status()}'
    "   \ .bufferline#get_status_string()

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

    map <C-f> <esc>:call CtrlSFIfOpen()<cr>

    let g:ctrlp_cmd = 'CtrlPMixed'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'result',
      \ }
    let g:ctrlp_show_hidden = 1

    imap <C-p> <esc>:CtrlPMixed<Return>

    " autocmd VimEnter * nested coc#session.load()

    let g:coc_node_path = '${pkgs.nodejs}/bin/node'

    let g:gitgutter_git_executable = '${pkgs.git}/bin/git'

    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 1
    " let g:airline_theme='base16_monokai'
    let g:airline_theme='wombat'

    map <C-o> <esc>:Explore<cr>

    let g:VM_mouse_mappings = 1
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

    set autoread
    au FocusGained,BufEnter * :checktime

    nmap <c-_> <leader>c<space>
    imap <c-_> <esc><leader>c<space>
    vmap <c-_> <leader>c<space>


    " Override w motion
    function! MyWMotion()
        " Save the initial position
        let initialLine=line('.')

        " Execute the builtin word motion and get the new position
        normal! w
        let newLine=line('.')

        " If the line as changed go back to the previous line
        if initialLine != newLine
            normal k$l
        endif
    endfunction

    " Override b motion
    function! MyBMotion()
        " Save the initial position
        let initialLine=line('.')

        " Execute the builtin word motion and get the new position
        normal! b
        let newLine=line('.')

        " If the line as changed go back to the previous line
        if initialLine != newLine
            normal j

            let newCol=virtcol('.')
            if newCol != 1
                normal 0
            else
                normal ^
            endif
        endif

    endfunction

    nmap <silent> <c-right> :call MyWMotion()<CR>
    nmap <silent> <c-left> :call MyBMotion()<CR>

    imap <silent> <c-right> <esc>l:call MyWMotion()<CR>i
    imap <silent> <c-left> <esc>:call MyBMotion()<CR>i

    let g:OmniSharp_server_stdio = 1
    let g:OmniSharp_server_path = '${pkgs.omnisharp-roslyn}/bin/omnisharp'

    let g:ale_linters = {
    \ 'cs': ['OmniSharp']
    \}

    augroup omnisharp_commands
      autocmd!

      " The following commands are contextual, based on the cursor position.
      autocmd FileType cs nmap <buffer> <c-[> :OmniSharpGotoDefinition<CR>
      autocmd FileType cs nmap <buffer> <c-]> :OmniSharpDocumentation<CR>
    augroup END
  '';


  neovim = pkgs.neovim.override {
    configure = {
      inherit customRC;
      packages.myVimPackage = with pkgs.vimPlugins; with vimPlugins; {
        start = [
          vim-plug
          gruvbox
          vim-gitgutter
          undotree
          vim-better-whitespace
          vim-jsbeautify
          vim-visual-multi
          vim-pasta
          ctrlsf-vim
          ctrlp
          vim-airline vim-airline-themes
          vim-nix
          robotframework-vim
          nerdcommenter

          coc-nvim
          coc-neco
          coc-vimtex
          coc-json
          coc-tsserver
          coc-html
          coc-css
          coc-yaml
          coc-python
          coc-highlight
          coc-emmet
          coc-lists
          coc-git
          coc-yank
          coc-tabnine

          omnisharp-vim
          ale
        ];
        opt = [ ];
      };
    };
  };

  vimrcConfig = {
    vam.knownPlugins = pkgs.vimPlugins // vimPlugins;
    vam.pluginDictionaries = [
      {
        names = [
          "vim-plug"
          "gruvbox"
          "vim-gitgutter"
          "undotree"
          "vim-better-whitespace"
          "vim-jsbeautify"
          "vim-visual-multi"
          "vim-pasta"
          "ctrlsf-vim"
          "ctrlp"
          "vim-airline"
          "vim-airline-themes"
          "vim-addon-nix"
          "coc-nvim"
          "coc-neco"
          "coc-vimtex"
          "coc-json"
          "coc-tsserver"
          "coc-html"
          "coc-css"
          "coc-yaml"
          "coc-python"
          "coc-highlight"
          "coc-emmet"
          "coc-lists"
          "coc-git"
          "coc-yank"
          "coc-tabnine"
        ];
      }
    ];
    inherit customRC;
  };
  my_vim = pkgs.vim_configurable.customize { name = "nvim"; inherit vimrcConfig; };
  vimEnv = pkgs.buildEnv {
    name = "nvim-env";
    ignoreCollisions = true;
    paths = [
      my_vim
    ];
  };

in [{
  target = "${variables.homeDir}/bin/nvim";
  source = "${neovim}/bin/nvim";
} {
  target = "${variables.homeDir}/bin/nvim-qt";
  source = pkgs.writeScript "open-nvim" ''
    #!${pkgs.stdenv.shell}
    function open_nvim_qt {
      ${pkgs.neovim-qt}/bin/nvim-qt --no-ext-tabline --nvim ${variables.homeDir}/bin/nvim "$@"
    }
    if [ -z "$@" ]
    then
      open_nvim_qt $(${pkgs.git}/bin/git ls-files -m --exclude-standard)
    else
      open_nvim_qt "$@"
    fi
  '';
}]
