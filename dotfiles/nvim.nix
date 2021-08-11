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
    " set background=light

    let g:gitgutter_override_sign_column_highlight = 0

    " The configuration options should be placed before `colorscheme sonokai`.
    let g:gruvbox_original_background = 'medium'
    colorscheme gruvbox-material

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
    nnoremap <silent> <C-w> :bd<cr>
    map <C-q> <esc>:qall
    nno <silent> <c-s> :w<CR>
    ino <silent> <c-s> <esc>:w<CR>
    nnoremap <silent> <c-PageUp> :bprev<cr>
    nnoremap <silent> <c-PageDown> :bnext<cr>
    inoremap <silent> <c-PageUp> <esc>:bprev<cr>
    inoremap <silent> <c-PageDown> <esc>:bnext<cr>

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

    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 0
    if !exists('g:airline_symbols')
      let g:airline_symbols = {}
    endif
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''

    let g:airline_symbols.colnr = ' ℅:'
    let g:airline_symbols.crypt = '🔒'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.maxlinenr = ""
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.spell = 'Ꞩ'
    let g:airline_symbols.notexists = 'Ɇ'
    let g:airline_symbols.whitespace = 'Ξ'

    let g:airline_theme='gruvbox_material'
    " let g:airline_solarized_bg='light'

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
    " autocmd VimEnter * AutoreadLoop
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

    inoremap <A-del> <space><esc>ce
    inoremap <C-del> <space><esc>ce
    inoremap <C-BS> <C-W>

    nnoremap <C-del> "_dw

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

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  -- buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
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

  cfg = {
    bind = true, -- This is mandatory, otherwise border config won't get registered.
                 -- If you want to hook lspsaga or other signature handler, pls set to false
    doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
                   -- set to 0 if you DO NOT want any API comments be shown
                   -- This setting only take effect in insert mode, it does not affect signature help in normal
                   -- mode, 10 by default

    floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    hint_enable = true, -- virtual hint enable
    hint_prefix = "",  -- Panda for parameter
    hint_scheme = "String",
    use_lspsaga = true,  -- set to true if you want to use lspsaga popup
    hi_parameter = "Search", -- how your parameter will be highlight
    max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
                     -- to view the hiding contents
    max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
    handler_opts = {
      border = "shadow"   -- double, single, shadow, none
    },
    extra_trigger_chars = {} -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  }
  require'lsp_signature'.on_attach(cfg)

end

nvim_lsp["kotlin_language_server"].setup { on_attach = on_attach; cmd = {"${kotlin-language-server}/bin/kotlin-language-server"} }
nvim_lsp["rnix"].setup { on_attach = on_attach; cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"} }
nvim_lsp["pyright"].setup { on_attach = on_attach; cmd = {"${pkgs.pyright}/bin/pyright-langserver", "--stdio"} }
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
nvim_lsp["hls"].setup { on_attach = on_attach; cmd = {"${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper", "--lsp"} }

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

if not nvim_lsp["ansiblels"] then
  nvim_lsp_configs.ansiblels = {
    default_config = {
      cmd = { '${variables.homeDir}/.npm-packages/bin/ansible-language-server', '--stdio' },
      settings = {
        ansible = {
          python = {
            interpreterPath = '${pkgs.python3Packages.python}/bin/python',
          },
          ansibleLint = {
            path = '${pkgs.python3Packages.ansible-lint}/bin/ansible-lint',
            enabled = true,
          },
          ansible = {
            path = '${pkgs.python3Packages.ansible}/bin/ansible',
          },
        },
      },
      filetypes = { 'yaml' },
      root_dir = function(fname)
        return util.root_pattern { '*.yml', '*.yaml' }(fname)
      end,
    };
  }
end
nvim_lsp["ansiblels"].setup { on_attach = on_attach; }

local saga = require 'lspsaga'
saga.init_lsp_saga()

EOF
    nnoremap <silent> gh :Lspsaga lsp_finder<CR>
    nnoremap <silent> ca :Lspsaga code_action<CR>
    vnoremap <silent> ca :<C-U>Lspsaga range_code_action<CR>
    nnoremap <silent> K :Lspsaga hover_doc<CR>
    nnoremap <silent> gs :Lspsaga signature_help<CR>
    nnoremap <silent> gr :Lspsaga rename<CR>
    nnoremap <silent> gd :Lspsaga preview_definition<CR>
    nnoremap <silent> cd :Lspsaga show_line_diagnostics<CR>
    nnoremap <silent> } :Lspsaga diagnostic_jump_next<CR>
    nnoremap <silent> { :Lspsaga diagnostic_jump_prev<CR>
    nnoremap <silent> <A-d> :Lspsaga open_floaterm<CR>
    tnoremap <silent> <A-d> <C-\><C-n>:Lspsaga close_floaterm<CR>

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
    let g:airline#extensions#tabline#enabled = 1

    set sessionoptions-=options

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
      au BufNewFile,BufRead *.js,*.html,*.css set tabstop=2
      au BufNewFile,BufRead *.js,*.html,*.css set softtabstop=2
      au BufNewFile,BufRead *.js,*.html,*.css set shiftwidth=2
    augroup END

    augroup markdown
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
    let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

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
    nnoremap <C-o> :NvimTreeToggle<CR>
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
      rev = "a5ac2f45ff84a688a09479f357a9909d5b914294";
      sha256 = "sha256-0aXo8f1YGEI8PkLDOSgxqQy7qK031R+eapCppUFy61E=";
    };
    buildInputs = old.buildInputs ++ [ pkgs.utf8proc (pkgs.tree-sitter.override {webUISupport = false;}) ];
  });

  neovim = (pkgs.wrapNeovim pkgs.neovim-unwrapped { }).override {
  #neovim = (pkgs.wrapNeovim pkgs.neovim-unwrapped { }).override {
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
          vim-airline vim-airline-themes
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
          deoplete-nvim
          deoplete-lsp
          #vimPlugins.neovim-auto-autoread
          vim-rsi
          vim-signify
          vimPlugins.vim-perforce
          vimPlugins.lsp_signature-nvim
          vimPlugins.git-blame-nvim
          #vimPlugins.nvim-web-devicons
          vimPlugins.nvim-tree-lua
          vimPlugins.gruvbox-material
          vimPlugins.lspsaga-nvim
          vimPlugins.vim-fakeclip
          vim-matchup
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
      coc-powershell \
      ansible-language-server

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
