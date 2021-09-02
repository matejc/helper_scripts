{ variables, config, pkgs, lib }:

let
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

  sha1Cmd = pkgs.writeScript "sha1.sh" ''
    #!${pkgs.stdenv.shell}
    echo -n "$@" | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.gawk}/bin/awk '{printf $1}'
   '';

  lemminx = import ../nixes/lemminx.nix { inherit pkgs; };

  python-lsp-server = pkgs.python3Packages.python-lsp-server.overrideDerivation (old: rec {
    pname = "python-lsp-server";
    version = "1.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "python-lsp";
      repo = pname;
      rev = "v${version}";
      sha256 = "028zaf6hrridjjam63i1n3x9cayiwq09xg8adnz2lcwpfyawl9ag";
    };
  });

  pyright = pkgs.pyright.overrideDerivation (old: rec {
    version = "1.1.161";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pyright/-/pyright-${version}.tgz";
      sha256 = "sha256-wmek3/DSJm9j7CsK/LVNdOG6zj3AP47funm8r8eDmSA=";
    };
  });

  ginitVim = pkgs.writeText "ginit.vim" ''
    if exists('g:fvim_loaded')
      " Font tweaks
      FVimFontAntialias v:true
      FVimFontAutohint v:true
      FVimFontHintLevel 'full'
      FVimFontLigature v:false
      " can be 'default', '14.0', '-1.0' etc.
      FVimFontLineHeight '+1.0'
      FVimFontSubpixel v:true

      " Try to snap the fonts to the pixels, reduces blur
      " in some situations (e.g. 100% DPI).
      FVimFontAutoSnap v:true

      " Font weight tuning, possible valuaes are 100..900
      FVimFontNormalWeight 400
      FVimFontBoldWeight 700

      FVimUIPopupMenu v:false
    endif

    if exists('g:GuiLoaded')
      GuiPopupmenu 0
      GuiTabline 0
      GuiFont ${lib.escape [" "] "${variables.font.family}:h${toString variables.font.size}"}
      " call GuiClipboard()
    endif

    if exists("g:neovide")
      let g:neovide_cursor_animation_length=0.1
      set guifont=${lib.escape [" "] "${variables.font.family}:h${toString (variables.font.size + 3)}"}
    endif
  '';

  customRC = ''
    let mapleader=","

    " if hidden is not set, TextEdit might fail.
    set hidden

    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    set cmdheight=1

    " You will have bad experience for diagnostic messages when it's default 4000.
    set updatetime=300

    " don't give |ins-completion-menu| messages.
    set shortmess+=c

    " always show signcolumns
    set signcolumn=yes
    set cursorline
    set number

    set guifont=${lib.escape [" "] "${variables.font.family}:h${toString variables.font.size}"}
    set termguicolors
    set background=dark

    let g:gitgutter_override_sign_column_highlight = 0

    " let g:gruvbox_original_background = 'medium'
    " colorscheme gruvbox-material
    colorscheme gruvbox

    " let g:neosolarized_contrast = "high"
    " let g:neosolarized_visibility = "high"
    " colorscheme NeoSolarized

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

    inoremap <C-A-s> <C-o>:setlocal spell! spelllang=en_us<CR>
    nnoremap <C-A-s> :setlocal spell! spelllang=en_us<CR>

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

    set formatoptions-=t

    set encoding=utf-8

    nnoremap <silent> <C-S-W> :bd!<cr>
    inoremap <silent> <C-S-W> <C-o>:bd!<cr>
    nnoremap <silent> <C-w> :bd<cr>
    inoremap <silent> <C-w> <C-o>:bd<cr>
    map <C-q> <esc>:qall
    inoremap <C-q> <esc>:qall
    nnoremap <silent> <c-s> :w<CR>
    inoremap <silent> <c-s> <C-o>:w<CR>
    nnoremap <silent> <c-PageUp> :BufferLineCyclePrev<CR>
    nnoremap <silent> <c-PageDown> :BufferLineCycleNext<CR>
    inoremap <silent> <c-PageUp> <C-o>:BufferLineCyclePrev<CR>
    inoremap <silent> <c-PageDown> <C-o>:BufferLineCycleNext<CR>

    nnoremap <silent><C-S-PageDown> :BufferLineMoveNext<CR>
    nnoremap <silent><C-S-PageUp> :BufferLineMovePrev<CR>
    inoremap <silent><C-S-PageDown> <C-o>:BufferLineMoveNext<CR>
    inoremap <silent><C-S-PageUp> <C-o>:BufferLineMovePrev<CR>

    nnoremap <silent> <cr> o
    nnoremap <silent> <c-cr> o
    inoremap <silent> <c-cr> <C-o>o

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

    function! PyBeautify()
      :silent exec "!${pkgs.python3Packages.black}/bin/black --line-length=79 '%:p'"
    endfunction

    autocmd FileType javascript nnoremap <buffer> <C-b> :call JsBeautify()<cr>
    autocmd FileType python nnoremap <buffer> <C-b> :call PyBeautify()<cr>

    nmap <PageUp> 10<up>
    nmap <PageDown> 10<down>
    inoremap <PageUp> <C-o>10<up>
    inoremap <PageDown> <C-o>10<down>
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

    inoremap <C-c> <C-o>yy
    nnoremap <C-c> yy
    vnoremap <C-c> y

    nnoremap <c-v> "+p
    inoremap <c-v> <C-R><C-O>+
    vnoremap <c-v> "_dhp

    " nmap <C-S-Up> :copy .-1<cr>
    " vmap <C-S-Up> :copy '>-1<cr>
    " imap <C-S-Up> <esc>:copy .-1<cr>i

    " nmap <C-S-Down> :copy .<cr>
    " vmap <C-S-Down> :copy '><cr>
    " imap <C-S-Down> <esc>:copy .<cr>i

    nnoremap <C-S-D> :copy .<cr>
    nnoremap <C-d> :copy .<cr>
    vnoremap <C-S-D> :copy '><cr>
    vnoremap <C-d> :copy '><cr>
    inoremap <C-S-D> <c-o>:copy .<cr>
    inoremap <C-d> <c-o>:copy .<cr>

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
    inoremap <C-S-Down> <C-o>:m .+1<CR>
    inoremap <C-S-Up> <C-o>:m .-2<CR>
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
    let g:ctrlsf_extra_backend_args = {
      \ 'ag': '--hidden',
      \ }
    func! CtrlSFIfOpen(defaultText)
      if ctrlsf#win#FindMainWindow() != -1
        call ctrlsf#StopSearch()
        call ctrlsf#Quit()
      else
        call inputsave()
        let text = input('Search: ', a:defaultText)
        call inputrestore()
        if !empty(text)
          call inputsave()
          let l:filePattern = input('File pattern: ', '\.' . expand('%:e') . '$')
          call inputrestore()
          if empty(l:filePattern)
            let l:filePattern = '.*'
          endif
          call ctrlsf#Search('-I -G "' . l:filePattern . '" ' . text)
        endif
      endif
    endf
    let g:ctrlsf_regex_pattern = 1

    vnoremap <silent> <C-f> :call CtrlSFIfOpen(<SID>get_visual_selection())<cr>
    nnoremap <silent> <C-f> :call CtrlSFIfOpen(expand("<cword>"))<cr>

    vnoremap // :call feedkeys("/" . <SID>get_visual_selection())<cr>
    nnoremap // :call feedkeys("/" . expand("<cword>"))<cr>

    let g:ctrlp_cmd = 'CtrlP'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'result',
      \ }
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_user_command = ['.git', 'cd %s && ${pkgs.git}/bin/git ls-files . -co --exclude-standard', '${pkgs.findutils}/bin/find %s -type f']

    let g:gitgutter_git_executable = '${pkgs.git}/bin/git'
    nnoremap <C-h> <leader>hu

    " let g:airline#extensions#tabline#enabled = 1
    " let g:airline_powerline_fonts = 0
    " if !exists('g:airline_symbols')
    "   let g:airline_symbols = {}
    " endif
    " let g:airline_symbols.branch = ''
    " let g:airline_symbols.readonly = ''

    " let g:airline_symbols.colnr = ' ℅:'
    " let g:airline_symbols.crypt = '🔒'
    " let g:airline_symbols.linenr = '¶'
    " let g:airline_symbols.maxlinenr = ""
    " let g:airline_symbols.paste = 'ρ'
    " let g:airline_symbols.spell = 'Ꞩ'
    " let g:airline_symbols.notexists = 'Ɇ'
    " let g:airline_symbols.whitespace = 'Ξ'

    " let g:airline_theme='gruvbox_material'
    " " let g:airline_solarized_bg='light'

    function! IsNTOpen()
      return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
    endfunction
    function! NTFindAndRevealPath() abort
        let l:pathStr = expand('%:p')
        let l:revealOpts = {}

        if empty(l:pathStr) || l:pathStr =~ '^term:'
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
    " nnoremap <C-o> :call NTToggle()<CR>
    " autocmd VimLeave * NERDTreeClose

    let g:VM_mouse_mappings = 1
    let g:VM_default_mappings = 0
    let g:VM_maps = {}
    let g:VM_maps['Find Under']                  = '<C-n>'
    let g:VM_maps['Find Subword Under']          = '<C-n>'
    let g:VM_maps["Select All"]                  = '<C-S-N>'
    " let g:VM_maps["Start Regex Search"]          = 'g/'
    let g:VM_maps["Add Cursor Down"]             = '<C-Down>'
    let g:VM_maps["Add Cursor Up"]               = '<C-Up>'
    let g:VM_maps["Add Cursor At Pos"]           = '<C-g>'
    " let g:VM_maps["Visual Regex"]                = 'g/'
    " let g:VM_maps["Visual All"]                  = '<leader>A'
    " let g:VM_maps["Visual Add"]                  = '<A-a>'
    " let g:VM_maps["Visual Find"]                 = '<A-f>'
    " let g:VM_maps["Visual Cursors"]              = '<A-c>'
    " let g:VM_maps["Select l"]              = '<A-Right>'
    " let g:VM_maps["Select h"]              = '<A-Left>'

    set autoread
    autocmd FocusGained,BufEnter * silent! checktime

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

    inoremap <silent> <A-del> <C-o>ce
    inoremap <silent> <C-del> <C-o>ce
    inoremap <silent> <C-BS> <C-W>

    nnoremap <silent> <C-del> "_dw

    nnoremap d "_d
    nnoremap D "_D
    vnoremap d "_d

    nnoremap <del> "_dl
    vnoremap <del> "_d

lua << EOF
local nvim_lsp = require('lspconfig')
local nvim_lsp_configs = require('lspconfig/configs')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  -- buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '{', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '}', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  -- if client.resolved_capabilities.document_highlight then
  --   vim.api.nvim_exec([[
  --     hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
  --     hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
  --     hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
  --     augroup lsp_document_highlight
  --       autocmd!
  --       autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
  --       autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
  --     augroup END
  --   ]], false)
  -- end

  -- if client.resolved_capabilities.signature_help then
  --   vim.api.nvim_exec([[
  --     augroup lsp_signature_help
  --       autocmd!
  --       autocmd CursorHold <buffer> lua vim.lsp.buf.signature_help()
  --     augroup END
  --   ]], false)
  -- end

  cfg = {
    bind = true, -- This is mandatory, otherwise border config won't get registered.
                 -- If you want to hook lspsaga or other signature handler, pls set to false
    doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
                   -- set to 0 if you DO NOT want any API comments be shown
                   -- This setting only take effect in insert mode, it does not affect signature help in normal
                   -- mode, 10 by default

    floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
    hint_enable = false, -- virtual hint enable
    hint_prefix = "🐼 ",  -- Panda for parameter
    hint_scheme = "String",
    use_lspsaga = false,  -- set to true if you want to use lspsaga popup
    hi_parameter = "Search", -- how your parameter will be highlight
    max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
                     -- to view the hiding contents
    max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
    handler_opts = {
      border = "single"   -- double, single, shadow, none
    },

    trigger_on_newline = false, -- sometime show signature on new line can be confusing, set it to false for #58
    extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    -- deprecate !!
    -- decorator = {"`", "`"}  -- this is no longer needed as nvim give me a handler and it allow me to highlight active parameter in floating_window
    zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
    debug = false, -- set to true to enable debug logging
    log_path = "debug_log_file_path", -- debug log path

    padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc

    shadow_blend = 36, -- if you using shadow as border use this set the opacity
    shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    toggle_key = nil -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
  }
  require'lsp_signature'.on_attach(cfg)

end

nvim_lsp["kotlin_language_server"].setup { on_attach = on_attach; cmd = {"${kotlin-language-server}/bin/kotlin-language-server"} }
nvim_lsp["rnix"].setup { on_attach = on_attach; cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"} }
nvim_lsp["bashls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/bash-language-server", "start"} }
nvim_lsp["dockerls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/docker-langserver", "--stdio"} }
nvim_lsp["yamlls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/yaml-language-server", "--stdio"} }
nvim_lsp["tsserver"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/typescript-language-server", "--stdio"} }
nvim_lsp["jsonls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/vscode-json-languageserver", "--stdio"} }
nvim_lsp["vimls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/vim-language-server", "--stdio"} }
nvim_lsp["html"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/html-languageserver", "--stdio"} }
nvim_lsp["cssls"].setup { on_attach = on_attach; cmd = {"${variables.homeDir}/.npm-packages/bin/css-languageserver", "--stdio"} }
nvim_lsp["ccls"].setup { on_attach = on_attach; cmd = {"${pkgs.ccls}/bin/ccls"} }
nvim_lsp["omnisharp"].setup { on_attach = on_attach; cmd = { "${pkgs.omnisharp-roslyn}/bin/omnisharp", "--languageserver" , "--hostPID", tostring(pid) } }
nvim_lsp["gopls"].setup { on_attach = on_attach; cmd = {"${pkgs.gopls}/bin/gopls"} }
-- nvim_lsp["hls"].setup { on_attach = on_attach; cmd = {"{pkgs.haskell-language-server}/bin/haskell-language-server-wrapper", "--lsp"} }

nvim_lsp["sumneko_lua"].setup {
  on_attach = on_attach;
  cmd = {"${pkgs.sumneko-lua-language-server}/bin/lsp-language-server", "-E", "${pkgs.sumneko-lua-language-server}/extras/main.lua"};
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
}

if not nvim_lsp["pwsh"] then
  nvim_lsp_configs.pwsh = {
    default_config = {
      cmd = {"${pkgs.powershell}/bin/pwsh", "-NoLogo", "-NoProfile", "-Command", "${variables.homeDir}/.npm-packages/lib/node_modules/coc-powershell/PowerShellEditorServices/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath ${variables.homeDir}/.npm-packages/lib/node_modules/coc-powershell/PowerShellEditorServices -LogPath ${variables.homeDir}/.pwsh-logs.log -SessionDetailsPath ${variables.homeDir}/.pwsh-session.json -FeatureFlags @() -AdditionalModules @() -HostName 'My Client' -HostProfileId 'myclient' -HostVersion 1.0.0 -Stdio -LogLevel Normal"};
      filetypes = {'ps1'};
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      settings = {};
    };
  }
end
nvim_lsp["pwsh"].setup { on_attach = on_attach; }

if not nvim_lsp["robotframeworklsp"] then
  nvim_lsp_configs.robotframeworklsp = {
    default_config = {
      cmd = {"${variables.homeDir}/.py-packages/bin/robotframework_ls"};
      filetypes = {'robot'};
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      settings = {};
    };
  }
end
nvim_lsp["robotframeworklsp"].setup { on_attach = on_attach; }

if not nvim_lsp["lemminx"] then
  nvim_lsp_configs.lemminx = {
    default_config = {
      cmd = {"${lemminx}/bin/lemminx"};
      filetypes = {'xml'};
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      settings = {};
    };
  }
end
nvim_lsp["lemminx"].setup { on_attach = on_attach; }

nvim_lsp["pylsp"].setup {
  on_attach = on_attach;
  cmd = {"${python-lsp-server}/bin/pylsp"};
  filetypes = { 'python' };
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true;
        };
        pyflakes = {
          enabled = false;
        };
        jedi_completion = {
          enabled = false;
        };
        jedi_definition = {
          enabled = false;
        };
        pylint = {
          enabled = true;
          args = { "--disable=all", "--enable=wrong-import-order" };
          executable = "${pkgs.python3Packages.pylint}/bin/pylint";
        };
      };
    };
  };
}
nvim_lsp["pyright"].setup {
  on_attach = on_attach;
  cmd = {"${pyright}/bin/pyright-langserver", "--stdio"};
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'basic',
        diagnosticSeverityOverrides = {
          reportMissingTypeStubs = 'none',
          reportPrivateUsage = 'none',
          reportUnknownParameterType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownVariableType = "none",
          reportUnknownMemberType = "none",
        },
      },
    },
  };
}
-- if not nvim_lsp["python_language_server"] then
--   nvim_lsp_configs.python_language_server = {
--     default_config = {
--       cmd = { '{pkgs.python-language-server}/bin/python-language-server' };
--       filetypes = { 'python' };
--       root_dir = function(fname)
--         local root_files = {
--           'pyproject.toml',
--           'setup.py',
--           'setup.cfg',
--           'requirements.txt',
--           'Pipfile',
--         }
--         return nvim_lsp.util.root_pattern(unpack(root_files))(fname) or nvim_lsp.util.find_git_ancestor(fname) or nvim_lsp.util.path.dirname(fname)
--       end;
--     };
--   }
-- end
-- nvim_lsp["python_language_server"].setup { on_attach = on_attach; }

-- if not nvim_lsp["ansiblels"] then
--   nvim_lsp_configs.ansiblels = {
--     default_config = {
--       cmd = { '{variables.homeDir}/.npm-packages/bin/ansible-language-server', '--stdio' },
--       settings = {
--         ansible = {
--           python = {
--             interpreterPath = '{pkgs.python3Packages.python}/bin/python',
--           },
--           ansibleLint = {
--             path = '{pkgs.python3Packages.ansible-lint}/bin/ansible-lint',
--             enabled = true,
--           },
--           ansible = {
--             path = '{pkgs.python3Packages.ansible}/bin/ansible',
--           },
--         },
--       },
--       filetypes = { 'yaml' },
--       root_dir = function(fname)
--         return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
--       end,
--     };
--   }
-- end
-- nvim_lsp["ansiblels"].setup { on_attach = on_attach; }

-- local saga = require 'lspsaga'
-- saga.init_lsp_saga()


require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { ''', ''' ,''', ' ', ''', ''', ''', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 60,
    min_width = 30,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    buffer = true;
    path = true;
    tags = true;
    spell = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    omni = false;
    -- vsnip = true;
    -- ultisnips = true;
    -- luasnip = true;
  };
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = true,
    signs = true,
    update_in_insert = true
  }
)

function _G.self_color_gruvbox_dark()
  -- vim.g.gruvbox_invert_selection = 0
  -- vim.g.gruvbox_italic = 1
  -- vim.g.gruvbox_sign_column = 'bg0'

  -- vim.cmd('set background=dark')
  -- vim.cmd('colorscheme gruvbox')

  vim.cmd('highlight StatusLine                                                                                                guifg=#3c3836')

  vim.cmd('highlight GalaxyLeftGitDiffAddActive                                                                  guibg=#3c3836 guifg=#27b31a')
  vim.cmd('highlight GalaxyLeftGitDiffInactive                                                                   guibg=#3c3836 guifg=#ebdbb2')
  vim.cmd('highlight GalaxyLeftGitDiffModifiedActive                                                             guibg=#3c3836 guifg=#fe811b')
  vim.cmd('highlight GalaxyLeftGitDiffRemoveActive                                                               guibg=#3c3836 guifg=#fb4632')
  vim.cmd('highlight GalaxyLeftLspInactive                                                                       guibg=#3c3836 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyMapperCommon1                                                                         guibg=#3c3836 guifg=#504945')
  vim.cmd('highlight GalaxyMapperCommon2                                                                         guibg=#bdae93 guifg=#504945')
  vim.cmd('highlight GalaxyMapperCommon3                                                                         guibg=#3c3836 guifg=#ebdbb2')
  vim.cmd('highlight GalaxyMapperCommon4                                                                         guibg=#504945 guifg=#ebdbb2')
  vim.cmd('highlight GalaxyMapperCommon5                                                                         guibg=#3c3836 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyMapperCommon6                                                                         guibg=#504945 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyMapperCommon7                                                                         guibg=#504945 guifg=#bdae93')
  vim.cmd('highlight GalaxyMapperCommon8                                                                         guibg=#504945 guifg=#91a6ba')
  vim.cmd('highlight GalaxyMidFileStatusModified                                                                 guibg=#3c3836 guifg=#8ec07c')
  vim.cmd('highlight GalaxyMidFileStatusReadonly                                                                 guibg=#3c3836 guifg=#fe811b')
  vim.cmd('highlight GalaxyMidFileStatusRestricted                                                               guibg=#3c3836 guifg=#fb4632')
  vim.cmd('highlight GalaxyMidFileStatusUnmodified                                                               guibg=#3c3836 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyRightLspErrorActive                                                                   guibg=#3c3836 guifg=#fb4632')
  vim.cmd('highlight GalaxyRightLspHintActive                                                                    guibg=#3c3836 guifg=#27b31a')
  vim.cmd('highlight GalaxyRightLspInformationActive                                                             guibg=#3c3836 guifg=#127fff')
  vim.cmd('highlight GalaxyRightLspWarningActive                                                                 guibg=#3c3836 guifg=#fe811b')
  vim.cmd('highlight GalaxyViModeCommandInverted                                                                 guibg=#504945 guifg=#fabd2f')
  vim.cmd('highlight GalaxyViModeCommandUnturned                                                                 guibg=#fabd2f guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeCommonVisualInverted                                                            guibg=#504945 guifg=#fe811b')
  vim.cmd('highlight GalaxyViModeCommonVisualUnturned                                                            guibg=#fe811b guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeEmptyInverted                                                                   guibg=#504945 guifg=#bdae93')
  vim.cmd('highlight GalaxyViModeEmptyUnturned                                                                   guibg=#bdae93 guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeInsertInverted                                                                  guibg=#504945 guifg=#83a598')
  vim.cmd('highlight GalaxyViModeInsertUnturned                                                                  guibg=#83a598 guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeNormalInverted                                                                  guibg=#504945 guifg=#bdae93')
  vim.cmd('highlight GalaxyViModeNormalUnturned                                                                  guibg=#bdae93 guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeReplaceInverted                                                                 guibg=#504945 guifg=#8ec07c')
  vim.cmd('highlight GalaxyViModeReplaceUnturned                                                                 guibg=#8ec07c guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeShellInverted                                                                   guibg=#504945 guifg=#d3869b')
  vim.cmd('highlight GalaxyViModeShellUnturned                                                                   guibg=#d3869b guifg=#3c3836')
  vim.cmd('highlight GalaxyViModeTerminalInverted                                                                guibg=#504945 guifg=#d3869b')
  vim.cmd('highlight GalaxyViModeTerminalUnturned                                                                guibg=#d3869b guifg=#3c3836')
end

function _G.self_color_gruvbox_light()
  -- vim.g.gruvbox_contrast_light = 'medium'
  -- vim.g.gruvbox_invert_selection = 0
  -- vim.g.gruvbox_italic = 1
  -- vim.g.gruvbox_sign_column = 'bg0'

  -- vim.cmd('set background=light')
  -- vim.cmd('colorscheme gruvbox')

  vim.cmd('highlight StatusLine                                                                                                guifg=#ebdbb2')

  vim.cmd('highlight GalaxyLeftGitDiffAddActive                                                                  guibg=#ebdbb2 guifg=#27b31a')
  vim.cmd('highlight GalaxyLeftGitDiffInactive                                                                   guibg=#ebdbb2 guifg=#7c6f64')
  vim.cmd('highlight GalaxyLeftGitDiffModifiedActive                                                             guibg=#ebdbb2 guifg=#dc7f27')
  vim.cmd('highlight GalaxyLeftGitDiffRemoveActive                                                               guibg=#ebdbb2 guifg=#d83a03')
  vim.cmd('highlight GalaxyLeftLspInactive                                                                       guibg=#ebdbb2 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon1                                                                         guibg=#ebdbb2 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyMapperCommon2                                                                         guibg=#bdae93 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon3                                                                         guibg=#ebdbb2 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon4                                                                         guibg=#d5c4a1 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon5                                                                         guibg=#ebdbb2 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon6                                                                         guibg=#d5c4a1 guifg=#7c6f64')
  vim.cmd('highlight GalaxyMapperCommon7                                                                         guibg=#d5c4a1 guifg=#bdae93')
  vim.cmd('highlight GalaxyMapperCommon8                                                                         guibg=#d5c4a1 guifg=#fbf0c9')
  vim.cmd('highlight GalaxyMidFileStatusModified                                                                 guibg=#ebdbb2 guifg=#27b31a')
  vim.cmd('highlight GalaxyMidFileStatusReadonly                                                                 guibg=#ebdbb2 guifg=#dc7f27')
  vim.cmd('highlight GalaxyMidFileStatusRestricted                                                               guibg=#ebdbb2 guifg=#d83a03')
  vim.cmd('highlight GalaxyMidFileStatusUnmodified                                                               guibg=#ebdbb2 guifg=#7c6f64')
  vim.cmd('highlight GalaxyRightLspErrorActive                                                                   guibg=#ebdbb2 guifg=#d83a03')
  vim.cmd('highlight GalaxyRightLspHintActive                                                                    guibg=#ebdbb2 guifg=#27b31a')
  vim.cmd('highlight GalaxyRightLspInformationActive                                                             guibg=#ebdbb2 guifg=#127efc')
  vim.cmd('highlight GalaxyRightLspWarningActive                                                                 guibg=#ebdbb2 guifg=#dc7f27')
  vim.cmd('highlight GalaxyViModeCommandInverted                                                                 guibg=#d5c4a1 guifg=#dc7f27')
  vim.cmd('highlight GalaxyViModeCommandUnturned                                                                 guibg=#dc7f27 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeCommonVisualInverted                                                            guibg=#d5c4a1 guifg=#ad3b14')
  vim.cmd('highlight GalaxyViModeCommonVisualUnturned                                                            guibg=#ad3b14 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeEmptyInverted                                                                   guibg=#d5c4a1 guifg=#bdae93')
  vim.cmd('highlight GalaxyViModeEmptyUnturned                                                                   guibg=#bdae93 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeInsertInverted                                                                  guibg=#d5c4a1 guifg=#076678')
  vim.cmd('highlight GalaxyViModeInsertUnturned                                                                  guibg=#076678 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeNormalInverted                                                                  guibg=#d5c4a1 guifg=#bdae93')
  vim.cmd('highlight GalaxyViModeNormalUnturned                                                                  guibg=#bdae93 guifg=#7c6f64')
  vim.cmd('highlight GalaxyViModeReplaceInverted                                                                 guibg=#d5c4a1 guifg=#447a59')
  vim.cmd('highlight GalaxyViModeReplaceUnturned                                                                 guibg=#447a59 guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeShellInverted                                                                   guibg=#d5c4a1 guifg=#d3869b')
  vim.cmd('highlight GalaxyViModeShellUnturned                                                                   guibg=#d3869b guifg=#d5c4a1')
  vim.cmd('highlight GalaxyViModeTerminalInverted                                                                guibg=#d5c4a1 guifg=#d3869b')
  vim.cmd('highlight GalaxyViModeTerminalUnturned                                                                guibg=#d3869b guifg=#d5c4a1')
end

require("bufferline").setup{
  options = {
    numbers = "none",
    close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil,          -- can be a string | function, see "Mouse actions"
    -- NOTE: this plugin is designed with this icon in mind,
    -- and so changing this is NOT recommended, this is intended
    -- as an escape hatch for people who cannot bear it for whatever reason
    indicator_icon = "",
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center"}},
    separator_style = { "", "" },
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    always_show_bufferline = true,
  }
}

require ('galaxyline').short_line_list = {
  'Mundo',
  'MundoDiff',
  'NvimTree',
  'fugitive',
  'fugitiveblame',
  'help',
  'minimap',
  'qf',
  'tabman',
  'tagbar',
  'toggleterm'
}

local vi_mode_mapping = {
  [""]   = {'Empty',        '-'},
  ['!']  = {'Shell',        '-'},
  ['^V'] = {'CommonVisual', 'B'}, -- NOTE: You'll have to remove '^V' and input a 'real' '^V' sequence. You can do that with the following key sequence: <SHIFT-i> + <CTRL-v> + <CTRL-v> (don't be slow with the double <CTRL-v>)
  ['R']  = {'Replace',      'R'},
  ['Rv'] = {'Normal',       '-'},
  ['S']  = {'Normal',       '-'},
  ['V']  = {'CommonVisual', 'L'},
  ['c']  = {'Command',      'C'},
  ['ce'] = {'Normal',       '-'},
  ['cv'] = {'Normal',       '-'},
  ['i']  = {'Insert',       'I'},
  ['ic'] = {'Normal',       '-'},
  ['n']  = {'Normal',       'N'},
  ['no'] = {'Normal',       '-'},
  ['r']  = {'Normal',       '-'},
  ['r?'] = {'Normal',       '-'},
  ['rm'] = {'Normal',       '-'},
  ['s']  = {'Normal',       '-'},
  ['t']  = {'Terminal',     'T'},
  ['v']  = {'CommonVisual', 'V'}
}

require ('galaxyline').section.left = {
  {
    LeftViModeColourSet = {
      provider = function()
        if vi_mode_mapping[vim.fn.mode()] == nil then
          vim.api.nvim_command("highlight link GalaxyViModeColourUnturned GalaxyViModeEmptyUnturned")
          vim.api.nvim_command("highlight link GalaxyViModeColourInverted GalaxyViModeEmptyInverted")
        else
          vim.api.nvim_command("highlight link GalaxyViModeColourUnturned GalaxyViMode" .. vi_mode_mapping[vim.fn.mode()][1] .. "Unturned")
          vim.api.nvim_command("highlight link GalaxyViModeColourInverted GalaxyViMode" .. vi_mode_mapping[vim.fn.mode()][1] .. "Inverted")
        end
      end
    }
  },
  {
    LeftViModeSeparator = {
      highlight = 'GalaxyViModeColourUnturned',
      provider = function()
        return ' '
      end
    }
  },
  {
    LeftViMode = {
      highlight = 'GalaxyViModeColourUnturned',
      provider = function()
        if vi_mode_mapping[vim.fn.mode()] == nil then
          return ' -'
        else
          return ' ' .. string.format('%s', vi_mode_mapping[vim.fn.mode()][2])
        end
      end,
      separator = ' ',
      separator_highlight = 'GalaxyViModeColourUnturned'
    }
  },
  -- {
  --   LeftWindowNumberSeparator = {
  --     highlight = 'GalaxyViModeColourUnturned',
  --     provider = function()
  --       return ''
  --     end,
  --     separator = ' ',
  --     separator_highlight = 'GalaxyViModeColourUnturned'
  --   }
  -- },
  -- {
  --   LeftWindowNumber = {
  --     highlight = 'GalaxyViModeColourUnturned',
  --     provider = function()
  --       return '  ' .. vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
  --     end,
  --     separator = ' ',
  --     separator_highlight = 'GalaxyViModeColourUnturned'
  --   }
  -- },
  {
    LeftStatusSeparator = {
      highlight = 'GalaxyViModeColourInverted',
      provider = function()
        return ''
      end,
      separator = ' ',
      separator_highlight = 'GalaxyViModeColourInverted'
    }
  },
  {
    LeftStatusPaste = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        if vim.o.paste then
          return ''
        else
          return ""
        end
      end,
      separator = "",
      separator_highlight = 'GalaxyMapperCommon6',
    }
  },
  {
    LeftStatusSpell = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        if vim.wo.spell then
          return '暈'
        else
          return ""
        end
      end,
      separator = "",
      separator_highlight = 'GalaxyMapperCommon6'
    }
  },
  {
    LeftStatusMixedIndentWhiteSpace = {
      provider = function()
        vim.cmd('match none /\t/')

        if vim.fn.search([[\v(^\t+)]], 'nw') ~= 0 and vim.fn.search([[\v(^ +)]], 'nw') ~= 0 then
          vim.cmd('highlight link GalaxyLeftStatusMixedIndentWhiteSpace GalaxyMapperCommon6')
          vim.cmd('match ErrorMsg /\t/')
          return ''
        end

        if vim.fn.search('\\s$', 'nw') ~= 0 then
          vim.cmd('highlight link GalaxyLeftStatusMixedIndentWhiteSpace GalaxyMapperCommon6')
          return 'ﲕ'
        end

        if vim.fn.search([[\v(^\t+)]], 'nw') ~= 0 then
          vim.cmd('highlight link GalaxyLeftStatusMixedIndentWhiteSpace GalaxyMapperCommon8')
        else
          vim.cmd('highlight link GalaxyLeftStatusMixedIndentWhiteSpace GalaxyMapperCommon6')
        end

        return ""
      end,
      separator = "",
      separator_highlight = 'GalaxyMapperCommon6'
    }
  },
  {
    LeftGitSeparator = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        return ''
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon6'
    }
  },
  {
    LeftGitBranch = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        if require('galaxyline.condition').check_git_workspace() then
          return ' ' .. require('galaxyline.provider_vcs').get_git_branch()
        else
          return ' '
        end
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon6'
    }
  },
  {
    LeftGitDiffSeparator = {
      highlight = 'GalaxyMapperCommon1',
      provider = function()
        return ''
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon1',
    }
  },
  {
    LeftGitDiffAdd = {
      condition = require("galaxyline.condition").check_git_workspace,
      provider = function()
        if require('galaxyline.provider_vcs').diff_add() then
          vim.cmd('highlight link GalaxyLeftGitDiffAdd GalaxyLeftGitDiffAddActive')
          return '+' .. require('galaxyline.provider_vcs').diff_add()
        else
          vim.cmd('highlight link GalaxyLeftGitDiffAdd GalaxyLeftGitDiffInactive')
          return '+0 '
        end
      end
    }
  },
  {
    LeftGitDiffModified= {
      condition = require("galaxyline.condition").check_git_workspace,
      provider = function()
        if require('galaxyline.provider_vcs').diff_modified() then
          vim.cmd('highlight link GalaxyLeftGitDiffModified GalaxyLeftGitDiffModifiedActive')
          return '~' .. require('galaxyline.provider_vcs').diff_modified()
        else
          vim.cmd('highlight link GalaxyLeftGitDiffModified GalaxyLeftGitDiffInactive')
          return '~0 '
        end
      end
    }
  },
  {
    LeftGitDiffRemove = {
      condition = require("galaxyline.condition").check_git_workspace,
      provider = function()
        if require('galaxyline.provider_vcs').diff_remove() then
          vim.cmd('highlight link GalaxyLeftGitDiffRemove GalaxyLeftGitDiffRemoveActive')
          return '-' .. require('galaxyline.provider_vcs').diff_remove()
        else
          vim.cmd('highlight link GalaxyLeftGitDiffRemove GalaxyLeftGitDiffInactive')
          return '-0 '
        end
      end
    }
  },
}

-- require ('galaxyline').section.mid = {
--   {
--     MidFileStatus = {
--       provider = function()
--         if vim.bo.modified then
--           vim.cmd('highlight link GalaxyMidFileStatus GalaxyMidFileStatusModified')
--         elseif not vim.bo.modifiable then
--           vim.cmd('highlight link GalaxyMidFileStatus GalaxyMidFileStatusRestricted')
--         elseif vim.bo.readonly then
--           vim.cmd('highlight link GalaxyMidFileStatus GalaxyMidFileStatusReadonly')
--         elseif not vim.bo.modified then
--           vim.cmd('highlight link GalaxyMidFileStatus GalaxyMidFileStatusUnmodified')
--         end
--         if require('nvim-web-devicons').get_icon(vim.fn.expand('%:e')) then
--           return require('nvim-web-devicons').get_icon(vim.fn.expand('%:e')) .. ' '
--         elseif not vim.bo.modified then
--           return ' '
--         end
--       end,
--       separator = ' ',
--       separator_highlight = 'GalaxyMapperCommon5'
--     }
--   },
--   {
--     MidFileName = {
--       highlight = 'GalaxyMapperCommon5',
--       provider = function()
--         if #vim.fn.expand '%:p' == 0 then
--           return '-'
--         end
--         if vim.fn.winwidth(0) > 150 then
--           return vim.fn.expand '%:~'
--         else
--           return vim.fn.expand '%:t'
--         end
--       end
--     }
--   }
-- }

require ('galaxyline').section.right = {
  {
    RightLspError = {
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients()) <= 0 then
           return
        end

        if vim.lsp.diagnostic.get_count(0, 'Error') == 0 then
          vim.cmd('highlight link GalaxyRightLspError GalaxyLeftLspInactive')
        else
          vim.cmd('highlight link GalaxyRightLspError GalaxyRightLspErrorActive')
        end

        return '' .. vim.lsp.diagnostic.get_count(0, 'Error') .. ' '
      end
    }
  },
  {
    RightLspWarning = {
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients()) <= 0 then
           return
        end

        if vim.lsp.diagnostic.get_count(0, 'Warning') == 0 then
          vim.cmd('highlight link GalaxyRightLspWarning GalaxyLeftLspInactive')
        else
          vim.cmd('highlight link GalaxyRightLspWarning GalaxyRightLspWarningActive')
        end

        return '' .. vim.lsp.diagnostic.get_count(0, 'Warning') .. ' '
      end
    }
  },
  {
    RightLspInformation = {
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients()) <= 0 then
           return
        end

        if vim.lsp.diagnostic.get_count(0, 'Information') == 0 then
          vim.cmd('highlight link GalaxyRightLspInformation GalaxyLeftLspInactive')
        else
          vim.cmd('highlight link GalaxyRightLspInformation GalaxyRightLspInformationActive')
        end

        return '' .. vim.lsp.diagnostic.get_count(0, 'Information') .. ' '
      end
    }
  },
  {
    RightLspHint = {
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients()) <= 0 then
           return
        end

        if vim.lsp.diagnostic.get_count(0, 'Hint') == 0 then
          vim.cmd('highlight link GalaxyRightLspHint GalaxyLeftLspInactive')
        else
          vim.cmd('highlight link GalaxyRightLspHint GalaxyRightLspHintActive')
        end

        return '' .. vim.lsp.diagnostic.get_count(0, 'Hint') .. ' '
      end
    }
  },
  {
    RightLspHintSeparator = {
      highlight = 'GalaxyMapperCommon1',
      provider = function()
        return ''
      end,
    }
  },
  {
    RightLspClient = {
      highlight = 'GalaxyMapperCommon4',
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients()) >= 1 then
          local lsp_client_name_first = vim.lsp.get_client_by_id(tonumber(vim.inspect(vim.tbl_keys(vim.lsp.buf_get_clients())):match('%d+'))).name:match('%l+')

          if lsp_client_name_first == nil then
            return #vim.tbl_keys(vim.lsp.buf_get_clients()) .. ': '
          else
            return #vim.tbl_keys(vim.lsp.buf_get_clients()) .. ':' .. lsp_client_name_first .. ' '
          end
        else
          return ' '
        end
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon4'
    }
  },
  {
    RightLspClientSeparator = {
      highlight = 'GalaxyMapperCommon4',
      provider = function()
        return ''
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon4'
    }
  },
  {
    RightFileSize = {
      highlight = 'GalaxyMapperCommon4',
      provider = 'FileSize',
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon4'
    }
  },
  {
    RightTabStop = {
      highlight = 'GalaxyMapperCommon4',
      provider = function()
        return string.format('%s', vim.bo.tabstop) .. ':'
      end,
    }
  },
  {
    RightFileType = {
      provider = function()
        if vim.bo.fileencoding == 'utf-8' then
          vim.cmd('highlight link GalaxyRightFileType GalaxyMapperCommon4')
        else
          vim.cmd('highlight link GalaxyRightFileType GalaxyMapperCommon8')
        end

        return string.format('%s', vim.bo.filetype)
      end,
    }
  },
  {
    RightFileEncoding = {
      highlight = 'GalaxyMapperCommon4',
      provider = function()
        local icons = {
          dos = '',
          mac  = '',
          unix = ''
        }
        if icons[vim.bo.fileformat] then
          return icons[vim.bo.fileformat]
        else
          return ''
        end
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon4'
    }
  },
  {
    RightFileEncodingSeparator = {
      highlight = 'GalaxyMapperCommon7',
      provider = function()
        return ''
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon7'
    }
  },
  {
    RightPositionNumerical = {
      highlight = 'GalaxyMapperCommon2',
      provider = function()
        return string.format('%s:%s  ', vim.fn.line('.'), vim.fn.col('.'))
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon2'
    }
  },
  {
    RightPositionPercentage = {
      highlight = 'GalaxyMapperCommon2',
      provider = function ()
        local percent = math.floor(100 * vim.fn.line('.') / vim.fn.line('$'))
        return string.format('%s%s ☰', percent, '%')
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon2'
    }
  },
  {
    RightPositionSeparator = {
      highlight = 'GalaxyMapperCommon2',
      provider = function()
        return '  '
      end
    }
  }
}

require ('galaxyline').section.short_line_left = {
  {
    ShortLineLeftBufferType = {
      highlight = 'GalaxyMapperCommon2',
      provider = function ()
        local BufferTypeMap = {
          ['Mundo'] = 'Mundo History',
          ['MundoDiff'] = 'Mundo Diff',
          ['NvimTree'] = 'Nvim Tree',
          ['fugitive'] = 'Fugitive',
          ['fugitiveblame'] = 'Fugitive Blame',
          ['help'] = 'Help',
          ['minimap'] = 'Minimap',
          ['qf'] = 'Quick Fix',
          ['tabman'] = 'Tab Manager',
          ['tagbar'] = 'Tagbar',
          ['toggleterm'] = 'Terminal'
        }
        local name = BufferTypeMap[vim.bo.filetype] or 'Editor'
        return string.format('  %s ', name)
      end,
      separator = ' ',
      separator_highlight = 'GalaxyMapperCommon7'
    }
  },
  {
    ShortLineLeftWindowNumber = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        return '  ' .. vim.api.nvim_win_get_number(vim.api.nvim_get_current_win()) .. ' '
      end,
      separator = '',
      separator_highlight = 'GalaxyMapperCommon1'
    }
  }
}

require ('galaxyline').section.short_line_right = {
  {
    ShortLineRightBlank = {
      highlight = 'GalaxyMapperCommon6',
      provider = function()
        if vim.bo.filetype == 'toggleterm' then
          return ' ' .. vim.api.nvim_buf_get_var(0, 'toggle_number') .. ' '
        else
          return '  '
        end
      end,
      separator = '',
      separator_highlight = 'GalaxyMapperCommon1'
    }
  },
  {
    ShortLineRightInformational = {
      highlight = 'GalaxyMapperCommon2',
      provider = function()
        return ' Neovim '
      end,
      separator = '',
      separator_highlight = 'GalaxyMapperCommon7'
    }
  }
}
EOF
    au VimEnter * lua _G.self_color_gruvbox_dark()
    " nnoremap <silent> gh :Lspsaga lsp_finder<CR>
    " nnoremap <silent> ca :Lspsaga code_action<CR>
    " vnoremap <silent> ca :<C-U>Lspsaga range_code_action<CR>
    " nnoremap <silent> K :Lspsaga hover_doc<CR>
    " nnoremap <silent> gs :Lspsaga signature_help<CR>
    " nnoremap <silent> rn :Lspsaga rename<CR>
    " nnoremap <silent> gd :Lspsaga preview_definition<CR>
    " nnoremap <silent> cd :Lspsaga show_line_diagnostics<CR>
    " nnoremap <silent> } :Lspsaga diagnostic_jump_next<CR>
    " nnoremap <silent> { :Lspsaga diagnostic_jump_prev<CR>
    " nnoremap <silent> <A-d> :Lspsaga open_floaterm<CR>
    " tnoremap <silent> <A-d> <C-\><C-n>:Lspsaga close_floaterm<CR>

    set completeopt=menuone,noselect
    inoremap <silent><expr> <C-Space> compe#complete()
    inoremap <silent><expr> <CR>      compe#confirm('<CR>')
    inoremap <silent><expr> <C-e>     compe#close('<C-e>')

    nnoremap gd :lua require'telescope.builtin'.lsp_definitions{}<cr>
    nnoremap gr :lua require'telescope.builtin'.lsp_references{}<cr>
    nnoremap ca :lua require'telescope.builtin'.lsp_code_actions{}<cr>
    vnoremap ca :lua require'telescope.builtin'.lsp_range_code_actions{}<cr>

    " function! OpenCompletion()
    "     if !pumvisible() && ((v:char >= 'a' && v:char <= 'z') || (v:char >= 'A' && v:char <= 'Z'))
    "         call feedkeys("\<C-x>\<C-o>", "n")
    "     endif
    " endfunction
    " autocmd InsertCharPre * call OpenCompletion()
    " set completeopt+=menuone,noselect,noinsert

    " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
    " found' messages
    " set shortmess+=c

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

    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    " let g:airline#extensions#tabline#enabled = 1

    set sessionoptions-=options
    set sessionoptions+=globals

    function! Sha1(text)
      let hash = system('${sha1Cmd} "' . a:text . '"')
      return hash
    endfunction

    function! SessionPath()
      return "${variables.homeDir}/.vim-sessions/" . ProjectName() . "-" . Sha1( getcwd() ) . ".vim"
    endfunction

    function! WipeAll()
        let i = 0
        let n = bufnr("$")
        while i < n
            let i = i + 1
            if bufexists(i)
                execute("bw " . i)
            endif
        endwhile
    endfunction

    autocmd VimLeavePre * nested if (!isdirectory("${variables.homeDir}/.vim-sessions")) |
        \ call mkdir("${variables.homeDir}/.vim-sessions") |
        \ endif |
        \ execute "mksession! " . SessionPath()

    function! MySessionLoad()
      let l:sessionPath = SessionPath()
      if argc() == 0 && filereadable(l:sessionPath)
        " call WipeAll()
        execute "source " . l:sessionPath
      endif
    endfunction

    autocmd VimEnter * nested call MySessionLoad()

    augroup CtrlPExtension
      autocmd!
      autocmd FocusGained  * CtrlPClearCache
      autocmd BufWritePost * CtrlPClearCache
    augroup END

    " tab sball
    " set switchbuf=usetab,newtab
    " au BufAdd,BufNewFile,BufRead * nested tab sball

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
      au BufNewFile,BufRead *.py setlocal tabstop=4
      au BufNewFile,BufRead *.py setlocal softtabstop=4
      au BufNewFile,BufRead *.py setlocal shiftwidth=4
      au BufNewFile,BufRead *.py setlocal textwidth=79
      au BufNewFile,BufRead *.py setlocal expandtab
      au BufNewFile,BufRead *.py setlocal autoindent
      au BufNewFile,BufRead *.py setlocal fileformat=unix
    augroup END

    augroup web
      au!
      au BufNewFile,BufRead *.js,*.html,*.css setlocal tabstop=2
      au BufNewFile,BufRead *.js,*.html,*.css setlocal softtabstop=2
      au BufNewFile,BufRead *.js,*.html,*.css setlocal shiftwidth=2
    augroup END

    augroup markdown
      au!
      au FileType markdown,textile,text setlocal spell spelllang=en_us
      au FileType markdown,textile,text setlocal formatoptions+=t
    augroup END

    let g:deoplete#enable_at_startup = 1
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

    tnoremap <silent> <C-[><C-[> <C-\><C-n>
    tnoremap <C-v> <C-\><C-N>"+pi

    tnoremap <silent> <c-PageUp> <C-\><C-N>:bprev<cr>
    tnoremap <silent> <c-PageDown> <C-\><C-N>:bnext<cr>

    tnoremap <silent> <a-left> <C-left>
    tnoremap <silent> <a-right> <C-right>

    nnoremap <silent> <C-S-T> :edit term://${variables.vimShell or "zsh"}<cr>
    " let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

    cnoremap <C-v> <C-r>+

    let g:NERDDefaultAlign = 'left'

    let g:nvim_tree_quit_on_open = 1 "0 by default, closes the tree when you open a file
    let g:nvim_tree_follow = 1 "0 by default, this option allows the cursor to be updated when entering a buffer
    let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
    let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
    let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
    let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
    let g:nvim_tree_tab_open = 1 "0 by default, will open the tree when entering a new tab and the tree was previously open
    let g:nvim_tree_width_allow_resize  = 1 "0 by default, will not resize the tree when opening a file
    let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
    let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
    let g:nvim_tree_lsp_diagnostics = 1 "0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
    " Dictionary of buffer option names mapped to a list of option values that
    " indicates to the window picker that the buffer's window should not be
    " selectable.
    let g:nvim_tree_show_icons = {
        \ 'git': 0,
        \ 'folders': 0,
        \ 'files': 0,
        \ 'folder_arrows': 0,
        \ }
    let g:nvim_tree_disable_netrw = 0
    nnoremap <C-o> :NvimTreeToggle<CR>
    inoremap <C-o> <esc>:NvimTreeToggle<CR>
    nnoremap <leader>r :NvimTreeRefresh<CR>
    nnoremap <leader>n :NvimTreeFindFile<CR>
    " NvimTreeOpen and NvimTreeClose are also available if you need them

    " let g:fakeclip_provide_clipboard_key_mappings = !empty($WAYLAND_DISPLAY)

    au BufNewFile,BufRead *.robot setlocal filetype=robot

    let g:gitblame_date_format = '%r'

    nnoremap <C-S-P> <C-o>
    inoremap <C-S-P> <esc><C-o>
    nnoremap <C-S-N> <C-i>
    inoremap <C-S-N> <esc><C-i>

    set splitbelow
    set splitright
    nnoremap <A-h> :sp<cr>
    nnoremap <A-v> :vsp<cr>
    nnoremap <A-c> :close<cr>
    nnoremap <silent> <A-c> :close<cr>
    nnoremap <A-Down> <C-W><C-J>
    nnoremap <A-Up> <C-W><C-K>
    nnoremap <A-Right> <C-W><C-L>
    nnoremap <A-Left> <C-W><C-H>

    nnoremap <C-U> :MundoToggle<CR>

    autocmd UIEnter * source ${ginitVim}
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
      rev = "a373ca1d826b1386f1fa291de70ee5d6bb81ec9b";
      sha256 = "1llaszrgfxkp9d53mwsrxhi898yg5vcnq1sxasbavc0hzdjn8rwr";
    };
    #buildInputs = old.buildInputs ++ [ pkgs.utf8proc (pkgs.tree-sitter.override {webUISupport = false;}) ];
  });

  neovim = (pkgs.wrapNeovim pkgs.neovim-unwrapped { }).override {
    configure = {
      inherit customRC;
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          #NeoSolarized
          #vim-gitgutter
          #undotree
          vim-better-whitespace
          vim-jsbeautify
          vim-visual-multi
          vim-pasta
          vimPlugins.ctrlsf-vim
          ctrlp
          #vim-airline vim-airline-themes
          #vim-nix
          nerdcommenter
          #ale
          #YouCompleteMe
          #vimPlugins.omnisharp-vim
          ctrlp-py-matcher
          robotframework-vim
          sleuth
          vimPlugins.vim-hashicorp-tools
          Jenkinsfile-vim-syntax
          vimPlugins.neovim-gui-shim
          vim-vinegar
          vim-fugitive
          #vimPlugins.nerdtree
          #vimPlugins.nerdtree-git-plugin
          #ansible-vim
          #vimPlugins.python-mode
          vim-polyglot
          #kotlin-vim
          vimPlugins.nvim-lspconfig
          #deoplete-nvim
          #deoplete-lsp
          #vimPlugins.neovim-auto-autoread
          vim-rsi
          vim-signify
          vimPlugins.vim-perforce
          vimPlugins.lsp_signature-nvim
          vimPlugins.git-blame-nvim
          #vimPlugins.nvim-web-devicons
          vimPlugins.nvim-tree-lua
          vimPlugins.gruvbox-material
          #vimPlugins.lspsaga-nvim
          vimPlugins.vim-fakeclip
          vim-matchup
          nvim-compe
          plenary-nvim
          telescope-nvim
          vimPlugins.bufferline-nvim
          vimPlugins.galaxyline-nvim
          vimPlugins.nvim-web-devicons
          vimPlugins.lush-nvim
          vimPlugins.gruvbox-nvim
          vim-mundo
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
    export PY_PACKAGES="${variables.homeDir}/.py-packages"

    npm_global_install() {
      mkdir -p $NPM_PACKAGES
      ${pkgs.nodejs}/bin/npm install -g --prefix="$NPM_PACKAGES" "$@"
    }

    pip_install() {
      if [ ! -d "$PY_PACKAGES" ]
      then
        ${pkgs.python3Packages.python}/bin/python -m venv "$PY_PACKAGES"
      fi
      $PY_PACKAGES/bin/pip install "$@"
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
      vscode-css-languageserver-bin \
      coc-powershell

    pip_install \
      robotframework-lsp

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
    export PATH="${lib.makeBinPath [
      pkgs.python3Packages.python
      pkgs.perl
      pkgs.nodejs
      pkgs.gnugrep
      pkgs.python3Packages.yamllint
    ]}:$PATH"
    ${neovim}/bin/nvim "$@"
  '';
} {
  target = "${variables.homeDir}/bin/guinvim";
  source = pkgs.writeScript "guinvim.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    trap "kill 0" EXIT
    export NVIM_LISTEN="127.0.0.1:$(${pkgs.python3Packages.python}/bin/python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
    { ${pkgs.python3Packages.python}/bin/python3 -c 'import time; time.sleep(1);'; ''${NVIM_FRONTEND_PATH} ''${NVIM_FRONTEND_ARGS:-"--server"} "$NVIM_LISTEN"; } &
    ${neovim}/bin/nvim --listen "$NVIM_LISTEN" --headless "$@" &
    wait
  '';
}] ++ (lib.mapAttrsToList (name: value: {
  target = "${variables.homeDir}/bin/${name}";
  source = pkgs.writeScript "open-nvim" ''
    #!${pkgs.stdenv.shell}
    function open_nvim {
      ${value} "$@"
    }
    if [[ $1 == "-g" ]]
    then
      open_nvim $(${pkgs.git}/bin/git diff --name-only HEAD)
    elif [ -d "$1" ]
    then
      cd "$1"
      open_nvim "''${@:2}"
    else
      open_nvim "$@"
    fi
  '';
}) (variables.vims or {}))
