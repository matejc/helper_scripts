{ variables, config, pkgs, lib }:

let
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

  omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideDerivation (old: rec {
    name = "omnisharp-roslyn-1.34.9";
    src = pkgs.fetchurl {
      url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.34.9/omnisharp-mono.tar.gz";
      sha256 = "1b5jzc7dj9hhddrr73hhpq95h8vabkd6xac1bwq05lb24m0jsrp9";
    };
  });

  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/d98bdbff3ebdab408a12a9b7890d4cf400180839") {};
  hie = (all-hies.selection { selector = p: { inherit (p) ghc865; }; });

  sha1Vim = pkgs.fetchFromGitHub {
    owner = "vim-scripts";
    repo = "sha1.vim";
    rev = "40b3bb60d0bda010531422b948ff30bd4fa6b959";
    sha256 = "16d2wa81v4kk46cyhi10vnrpgvc0abgzi997bv3yncd5y55psxzm";
  };

  customRC = ''
    " if hidden is not set, TextEdit might fail.
    set hidden

    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    " Better display for messages
    " set cmdheight=1

    " You will have bad experience for diagnostic messages when it's default 4000.
    set updatetime=300

    " don't give |ins-completion-menu| messages.
    set shortmess+=c

    " always show signcolumns
    set signcolumn=yes
    set cursorline
    set number

    set guifont=${lib.escape [" "] "${variables.font.family}:h${variables.font.size}"}
    set termguicolors

    set background=light
    let g:gitgutter_override_sign_column_highlight = 0
    let g:neosolarized_contrast = "high"
    let g:neosolarized_visibility = "high"
    colorscheme NeoSolarized

    set title
    function! ProjectName()
      return substitute( getcwd(), '.*\/\([^\/]\+\)', '\1', ''' )
    endfunction
    set titlestring=%{ProjectName()}\:\ %t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)

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

    set ignorecase

    autocmd FileType * set spell spelllang=en_us

    hi clear SpellBad
    hi SpellBad cterm=underline gui=undercurl

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=1
    let g:strip_whitespace_confirm=0

    if has("persistent_undo")
      set undodir=~/.undodir/
      set undofile
    endif

    set autoindent
    " set smartindent
    set nocopyindent
    " set tabstop=2 shiftwidth=2 expandtab softtabstop=2
    set nowrap

    set virtualedit=onemore

    set encoding=utf-8

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

    inoremap <C-u> <esc>ui
    nnoremap <C-u> u
    "nno <C-r> <C-R>
    "ino <C-r> <esc><C-R>
    inoremap <C-z> <esc>ui
    nnoremap <C-z> u

    inoremap <A-u> <esc>ui
    nnoremap <A-u> u
    inoremap <A-r> <C-R>i
    nnoremap <A-r> <C-R>

    "nnoremap <C-U> <esc>:UndotreeToggle<CR>

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

    vmap <S-Right> l

    nmap <C-k> "_dd
    imap <C-k> <esc>"_ddi
    vmap <C-k> "_d

    nnoremap <C-x> dd
    inoremap <C-x> <esc>ddi
    vnoremap <C-x> d

    nmap <C-a> gg0vG$
    imap <C-a> <esc>gg0vG$

    imap <C-c> <C-o>yy
    nmap <C-c> yy
    vmap <C-c> y

    nnoremap <c-v> i<esc>p
    inoremap <c-v> <esc>pi<right>
    vnoremap <c-v> "_dhp

    " nmap <C-S-Up> :copy .-1<cr>
    " vmap <C-S-Up> :copy '>-1<cr>
    " imap <C-S-Up> <esc>:copy .-1<cr>i

    " nmap <C-S-Down> :copy .<cr>
    " vmap <C-S-Down> :copy '><cr>
    " imap <C-S-Down> <esc>:copy .<cr>i

    nmap <C-d> :copy .<cr>
    vmap <C-d> :copy '><cr>
    imap <C-d> <esc>:copy .<cr>i

    vmap <PageUp> 10<up>
    vmap <PageDown> 10<down>
    vmap <S-PageUp> 10<up>
    vmap <S-PageDown> 10<down>
    imap <S-PageUp> <esc>v10<up>
    imap <S-PageDown> <esc>lv10<down>
    nmap <S-PageUp> v10<up>
    nmap <S-PageDown> v10<down>

    vmap <Tab> >gv
    vmap <S-Tab> <gv
    nmap <Tab> >>
    nmap <S-Tab> <<
    inoremap <S-Tab> <C-d>

    nmap <C-S-Down> :m .+1<CR>==
    nmap <C-S-Up> :m .-2<CR>==
    imap <C-S-Down> <Esc>:m .+1<CR>==gi
    imap <C-S-Up> <Esc>:m .-2<CR>==gi
    vmap <C-S-Down> :m '>+1<CR>gv=gv
    vmap <C-S-Up> :m '<-2<CR>gv=gv

    " let g:bufferline_echo = 0
    " autocmd VimEnter *
    "   \ let &statusline='%{bufferline#refresh_status()}'
    "   \ .bufferline#get_status_string()

    function! s:get_visual_selection()
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        let lines = getline(line_start, line_end)
        if len(lines) == 0
            return ""
        endif
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
        return join(lines, "\n")
    endfunction

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
        call ctrlsf#StopSearch()
        call ctrlsf#Quit()
      else
        call inputsave()
        let text = input('Search: ', s:get_visual_selection())
        call inputrestore()
        if !empty(text)
          call ctrlsf#Search(text)
        endif
      endif
    endf

    map <C-f> <esc>:call CtrlSFIfOpen()<cr>

    vmap // :call feedkeys("/" . <SID>get_visual_selection())<cr>

    let g:ctrlp_cmd = 'CtrlPMixed'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'result',
      \ }
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_user_command = ['.git', 'cd %s && ${pkgs.git}/bin/git ls-files . -co --exclude-standard', '${pkgs.findutils}/bin/find %s -type f']

    imap <C-p> <esc>:CtrlPMixed<Return>

    let g:gitgutter_git_executable = '${pkgs.git}/bin/git'
    nnoremap <C-h> <leader>hu

    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 1
    let g:airline_theme='solarized'
    " let g:airline_solarized_bg='dark'

    function! IsNTOpen()
      return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
    endfunction
    function! NTFindAndRevealPath() abort
        let l:pathStr = expand('%:p')
        let l:revealOpts = {}

        if empty(l:pathStr)
            NERDTreeCWD
            return
        endif

        if !filereadable(l:pathStr)
            let l:pathStr = fnamemodify(l:pathStr, ':h')
            let l:revealOpts['open'] = 1
        endif

        try
            let l:pathStr = g:NERDTreePath.Resolve(l:pathStr)
            let l:pathObj = g:NERDTreePath.New(l:pathStr)
        catch /^NERDTree.InvalidArgumentsError/
            call nerdtree#echoWarning('invalid path')
            return
        endtry

        if !g:NERDTree.ExistsForTab()
            try
                let l:cwd = g:NERDTreePath.New(getcwd())
            catch /^NERDTree.InvalidArgumentsError/
                call nerdtree#echo('current directory does not exist.')
                let l:cwd = l:pathObj.getParent()
            endtry

            if l:pathObj.isUnder(l:cwd)
                call g:NERDTreeCreator.CreateTabTree(l:cwd.str())
            else
                call g:NERDTreeCreator.CreateTabTree(l:pathObj.getParent().str())
            endif
        else
            NERDTreeFocus

            if !l:pathObj.isUnder(b:NERDTree.root.path)
                call s:chRoot(g:NERDTreeDirNode.New(l:pathObj.getParent(), b:NERDTree))
            endif
        endif

        if l:pathObj.isHiddenUnder(b:NERDTree.root.path)
            call b:NERDTree.ui.setShowHidden(1)
        endif

        let l:node = b:NERDTree.root.reveal(l:pathObj, l:revealOpts)
        call b:NERDTree.render()
        call l:node.putCursorHere(1, 0)
    endfunction
    function! NTToggle()
      if IsNTOpen()
        NERDTreeClose
      else
        call NTFindAndRevealPath()
      endif
    endfunction
    nnoremap <C-o> :call NTToggle()<CR>

    autocmd VimLeave * NERDTreeClose

    let g:VM_mouse_mappings = 1
    let g:VM_maps = {}
    let g:VM_maps['Find Under']                  = '<C-n>'
    let g:VM_maps['Find Subword Under']          = '<C-n>'
    let g:VM_maps["Select All"]                  = '<leader>A'
    let g:VM_maps["Start Regex Search"]          = 'g/'
    let g:VM_maps["Add Cursor Down"]             = '<C-Down>'
    let g:VM_maps["Add Cursor Up"]               = '<C-Up>'
    let g:VM_maps["Add Cursor At Pos"]           = 'g<space>'
    let g:VM_maps["Visual Regex"]                = 'g/'
    let g:VM_maps["Visual All"]                  = '<leader>A'
    let g:VM_maps["Visual Add"]                  = '<A-a>'
    let g:VM_maps["Visual Find"]                 = '<A-f>'
    let g:VM_maps["Visual Cursors"]              = '<A-c>'
    let g:VM_maps["Select l"]              = '<A-Right>'
    let g:VM_maps["Select h"]              = '<A-Left>'

    set autoread
    " au FocusGained,BufEnter * :checktime
    autocmd VimEnter * AutoreadLoop

    nmap <c-_> <leader>c<space>
    imap <c-_> <esc><leader>c<space>
    vmap <c-_> <leader>c<space>

    nmap <c-/> <leader>c<space>
    imap <c-/> <esc><leader>c<space>
    vmap <c-/> <leader>c<space>

    let g:mpattern='[a-zA-Z0-9]\+\|^\|$'

    fu! <sid>MyMotionDir(mode, dir)
      let prefix=""
      if a:mode == 'i'
        let prefix='normal! '
      endif
      if a:dir
        let initialLine=line('.')
        let initialCol=col('.')
        if initialCol == col('$')
          call search('.', 'bW', initialLine)
        endif
        let initialCol=col('.')
        if initialCol == 1
          let newLine=search('$', 'bW', initialLine-1)
        else
          let newLine=search(g:mpattern, 'bW', initialLine-1)
        endif
        let scol=col('.')
        return prefix.":call MyMove('".a:mode."',".newLine.",".scol.")\<cr>"
      else
        let initialLine=line('.')
        let initialCol=col('.')
        if initialCol == col('$')
          let newLine=search('^', "W", initialLine+1)
        else
          let newLine=search(g:mpattern, "W", initialLine)
          if initialCol == col('.')
            call cursor([newLine, col('$')])
          endif
        endif
        let scol=col('.')
        return prefix.":call MyMove('".a:mode."',".newLine.",".scol.")\<cr>"
      endif
    endfu
    fu! MyMove(mode, line, column)
      if a:mode == 'v'
        execute "normal! gv"
      endif
      call cursor([a:line, a:column])
    endfu
    nnoremap <silent> <expr> <c-right> <sid>MyMotionDir('n', 0)
    nnoremap <silent> <expr> <c-left> <sid>MyMotionDir('n', 1)
    vnoremap <silent> <expr> <c-right> <sid>MyMotionDir('v', 0)
    vnoremap <silent> <expr> <c-left> <sid>MyMotionDir('v', 1)
    "inoremap <silent> <c-right> <esc>l:<c-u>execute(<sid>MyMotionDir('i', 0))<cr>i
    "inoremap <silent> <c-left> <esc>:<c-u>execute(<sid>MyMotionDir('i', 1))<cr>i

    " inoremap <silent> <expr> <s-right> <esc>:<c-u>execute(<sid>MyMotionDir('v', 0))<cr>

    inoremap <A-del> <esc>l"_dwi
    inoremap <C-del> <esc>l"_dwi
    inoremap <C-BS> <C-W>

    nnoremap d "_d
    nnoremap D "_D
    vnoremap d "_d

    nnoremap <del> "_dl
    vnoremap <del> "_d

lua << EOF
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd!
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

nvim_lsp["kotlin_language_server"].setup { on_attach = on_attach; cmd = {"${kotlin-language-server}/bin/kotlin-language-server"} }
nvim_lsp["rnix"].setup { on_attach = on_attach; cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"} }
nvim_lsp["pyls"].setup { on_attach = on_attach; cmd = {"${pkgs.python3Packages.python-language-server}/bin/pyls"} }
nvim_lsp["bashls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/bashls", "start"} }
nvim_lsp["dockerls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/docker-langserver", "--stdio"} }
nvim_lsp["yamlls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/yaml-language-server", "--stdio"} }
nvim_lsp["tsserver"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/typescript-language-server", "--stdio"} }
nvim_lsp["jsonls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/vscode-json-languageserver", "--stdio"} }
nvim_lsp["vimls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/vim-language-server", "--stdio"} }
nvim_lsp["html"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/html-languageserver", "--stdio"} }
nvim_lsp["cssls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/css-languageserver", "--stdio"} }
EOF


    " function! OpenCompletion()
    "     if !pumvisible() && ((v:char >= 'a' && v:char <= 'z') || (v:char >= 'A' && v:char <= 'Z'))
    "         call feedkeys("\<C-x>\<C-o>", "n")
    "     endif
    " endfunction
    " autocmd InsertCharPre * call OpenCompletion()
    " set completeopt+=menuone,noselect,noinsert

    " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
    " found' messages
    set shortmess+=c

    " CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
    inoremap <c-c> <ESC>

    "imap <expr> <Esc>      pumvisible() ? "\<C-y>" : "\<Esc>"
    "imap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
    "imap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    "imap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"

    "imap <expr> <C-Right>  pumvisible() ? "\<Right>" : "\<C-Right>"
    "imap <expr> <C-Left>   pumvisible() ? "\<Left>" : "\<C-Left>"
    "imap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
    "imap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

    " Use <TAB> to select the popup menu:
    "inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    "inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-d>"

    "autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

    let g:ale_completion_enabled = 0

    " Do not lint or fix minified files.
    let g:ale_pattern_options = {
      \ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
      \ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
      \ '\.cs$': {'ale_linters': [], 'ale_fixers': []},
      \ '\.py$': {'ale_linters': [], 'ale_fixers': []},
      \}
    " If you configure g:ale_pattern_options outside of vimrc, you need this.
    let g:ale_pattern_options_enabled = 1

    let g:OmniSharp_server_stdio = 1
    let g:OmniSharp_server_path = 'omnisharp'

    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    let g:airline#extensions#tabline#enabled = 1

    set sessionoptions-=options

    source ${sha1Vim}/plugin/sha1.vim

    function! SessionPath()
      return "${variables.homeDir}/.vim-sessions/" . ProjectName() . "-" . sha1#sha1( getcwd() ) . ".vim"
    endfunction

    autocmd VimLeave * nested if (!isdirectory("${variables.homeDir}/.vim-sessions")) |
        \ call mkdir("${variables.homeDir}/.vim-sessions") |
        \ endif |
        \ execute "mksession! " . SessionPath()

    autocmd VimEnter * nested if argc() == 0 && filereadable(SessionPath()) |
        \ execute "source " . SessionPath()

    let g:netrw_banner = 0
    let g:netrw_liststyle = 3
    " let g:netrw_browse_split = 4
    " let g:netrw_altv = 1
    " let g:netrw_winsize = 25
    let g:netrw_keepdir = 0

    " CtrlP auto cache clearing.
    " ----------------------------------------------------------------------------
    function! SetupCtrlP()
      if exists("g:loaded_ctrlp") && g:loaded_ctrlp
        augroup CtrlPExtension
          autocmd!
          autocmd FocusGained  * CtrlPClearCache
          autocmd BufWritePost * CtrlPClearCache
        augroup END
      endif
    endfunction
    if has("autocmd")
      autocmd VimEnter * :call SetupCtrlP()
    endif

    tab sball
    set switchbuf=usetab,newtab

    let g:NERDTreeDirArrowExpandable = '+'
    let g:NERDTreeDirArrowCollapsible = '-'
    " hide NERDTree on file open
    let g:NERDTreeQuitOnOpen = 1
    " do not display NERDTree help
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeGlyphReadOnly = "RO"

    augroup bufclosetrack
      au!
      autocmd BufLeave * let g:lastWinName = @%
    augroup END
    function! LastWindow()
      exe "edit " . g:lastWinName
    endfunction
    command -nargs=0 LastWindow call LastWindow()

    set list
    set listchars=tab:▸\ ,trail:×,nbsp:⎵

    augroup python
      au!
      au BufNewFile,BufRead *.py set tabstop=4
      au BufNewFile,BufRead *.py set softtabstop=4
      au BufNewFile,BufRead *.py set shiftwidth=4
      au BufNewFile,BufRead *.py set textwidth=79
      au BufNewFile,BufRead *.py set expandtab
      au BufNewFile,BufRead *.py set autoindent
      au BufNewFile,BufRead *.py set fileformat=unix
    augroup END

    augroup web
      au BufNewFile,BufRead *.js, *.html, *.css set tabstop=2
      au BufNewFile,BufRead *.js, *.html, *.css set softtabstop=2
      au BufNewFile,BufRead *.js, *.html, *.css set shiftwidth=2
    augroup END

    let g:pymode_lint_checkers = [ 'pylint', 'pyflakes', 'pep8', 'mccabe' ]
    let g:pymode_paths = [
      \'${pkgs.python3Packages.isort}/lib/${pkgs.python3Packages.python.libPrefix}/site-packages',
      \'${pkgs.python3Packages.lazy-object-proxy}/lib/${pkgs.python3Packages.python.libPrefix}/site-packages',
      \'${pkgs.python3Packages.wrapt}/lib/${pkgs.python3Packages.python.libPrefix}/site-packages',
      \'${pkgs.python3Packages.setuptools}/lib/${pkgs.python3Packages.python.libPrefix}/site-packages',
    \]
    let g:pymode_lint_cwindow = 0
    let g:pymode_lint_unmodified = 1

    let g:deoplete#enable_at_startup = 1
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
  '';

  kotlin-language-server = pkgs.stdenv.mkDerivation rec {
    pname = "kotlin-language-server";
    version = "0.7.0";

    src = pkgs.fetchzip {
      url = "https://github.com/fwcd/kotlin-language-server/releases/download/${version}/server.zip";
      sha256 = "1nsfird6mxzi2cx6k2dlvlsn3ipdf4l1grd4iwz42y3ihm8drgpa";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      install -D $src/bin/kotlin-language-server -t $out/bin
      cp -r $src/lib $out/lib
      wrapProgram $out/bin/kotlin-language-server \
        --prefix PATH : ${pkgs.jre}/bin
    '';
  };

  treeSitter = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tree-sitter";
    version = "0.18.0";

    src = pkgs.fetchFromGitHub {
      owner = "tree-sitter";
      repo = pname;
      rev = version;
      sha256 = "0q4lrsr5az5w06q1q0ndqs21v993bclpxv3bjxzlmv9i7zrj5hs1";
    };

    cargoSha256 = "08zr74yb1vaja4k5lyvhyj7fyhvhskx9z8ngg0cd4yg7fkzglp0s";

    doCheck = false;
  };

  neovim-unwrapped = pkgs.neovim-unwrapped.overrideDerivation (old: {
    name = "neovim-unwrapped-0.5.0";
    version = "0.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "94cf7bba008ff0c36828565a408b7ef79203e069";
      sha256 = "1pm50y68kxiqq2s1f4safpl579q0ff002bnpwslc8mfmbg70dsb6";
    };
    buildInputs = old.buildInputs ++ [ pkgs.utf8proc (pkgs.tree-sitter.override {webUISupport = false;}) ];
  });

  neovim = (pkgs.wrapNeovim neovim-unwrapped { }).override {
  #neovim = (pkgs.wrapNeovim pkgs.neovim-unwrapped { }).override {
    configure = {
      inherit customRC;
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          NeoSolarized
          #vim-gitgutter
          #undotree
          vim-better-whitespace
          vim-jsbeautify
          vim-visual-multi
          vim-pasta
          vimPlugins.ctrlsf-vim
          ctrlp
          vim-airline vim-airline-themes
          vim-nix
          nerdcommenter
          #ale
          #YouCompleteMe
          #vimPlugins.omnisharp-vim
          ctrlp-py-matcher
          #robotframework-vim
          sleuth
          vimPlugins.vim-hashicorp-tools
          Jenkinsfile-vim-syntax
          vimPlugins.neovim-gui-shim
          vim-vinegar
          vim-fugitive
          vimPlugins.nerdtree
          vimPlugins.nerdtree-git-plugin
          ansible-vim
          #vimPlugins.python-mode
          vim-polyglot
          #kotlin-vim
          vimPlugins.nvim-lspconfig
          deoplete-nvim
          deoplete-lsp
          vimPlugins.neovim-auto-autoread
          vim-rsi
          vim-signify
          vimPlugins.vim-perforce
        ];
        opt = [
        ];
      };
    };
  };

in [{
  target = "${variables.homeDir}/bin/nvim-lsp-install";
  source = pkgs.writeScript "nvim-lsp-install" ''
    #!${pkgs.stdenv.shell}

    export NPM_PACKAGES="${variables.homeDir}/.npm-packages"

    npm_global_install() {
      mkdir -p $NPM_PACKAGES
      ${pkgs.nodejs}/bin/npm install -g --prefix="$NPM_PACKAGES" "$@"
    }

    npm_global_install \
      bash-language-server \
      dockerfile-language-server-nodejs \
      typescript \
      typescript-language-server \
      yaml-language-server \
      vscode-json-languageserver \
      vim-language-server \
      vscode-html-languageserver-bin \
      vscode-css-languageserver-bin

    function ensure_lsp_link() {
      local name="$1"
      local path="$2"
      local cmdbasename="$(${pkgs.coreutils}/bin/basename $path)"
      local destination="${variables.homeDir}/.cache/nvim/nvim_lsp/$name/bin"
      mkdir -p "$destination"
      ln -svf "$path" "$destination/$cmdbasename"
    }

    #ensure_lsp_link "rnix" "${pkgs.rnix-lsp}/bin/rnix-lsp"
  '';
} {
  target = "${variables.homeDir}/bin/nvim";
  source = pkgs.writeScript "nvim" ''
    #!${pkgs.stdenv.shell}
    export PATH="${lib.makeBinPath [ pkgs.python3Packages.python
        /* omnisharp-roslyn hie */
        pkgs.nodejs pkgs.gnugrep pkgs.python3Packages.yamllint
    ]}:$PATH"
    ${neovim}/bin/nvim "$@"
  '';
} {
  target = "${variables.homeDir}/.config/nvim/after/ginit.vim";
  source = pkgs.writeText "ginit.vim" ''
    GuiPopupmenu 0
    GuiTabline 0
    call GuiClipboard()
  '';
}  {
  target = "${variables.homeDir}/bin/guinvim";
  source = pkgs.writeScript "guinvim.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    export PWDHASH="$(${pkgs.coreutils}/bin/pwd | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.gawk}/bin/awk '{printf $1}')"
    export NVIM_LISTEN="127.0.0.1:$(${pkgs.python3Packages.python}/bin/python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
    { ${pkgs.python3Packages.python}/bin/python3 -c 'import time; time.sleep(1);'; ''${NVIM_QT_PATH} --server "$NVIM_LISTEN"; } &
    ${neovim}/bin/nvim --listen "$NVIM_LISTEN" --headless "$@" &
  '';
} {
  target = "${variables.homeDir}/bin/q";
  source = pkgs.writeScript "open-nvim" ''
    #!${pkgs.stdenv.shell}
    function open_nvim_qt {
      export QT_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"
      ${pkgs.neovim-qt}/bin/nvim-qt --no-ext-tabline --nvim ${variables.homeDir}/bin/nvim "$@"
    }
    if [[ $@ == *" -g"* ]]
    then
      open_nvim_qt $(${pkgs.git}/bin/git diff --name-only HEAD)
    elif [ -d "$1" ]
    then
      cd "$1"
      open_nvim_qt "''${@:2}"
    else
      open_nvim_qt "$@"
    fi
  '';
}]
