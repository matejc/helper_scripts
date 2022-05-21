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

  enabledNvimLsp = mkNvimLsp [
    #"kotlin_language_server"
    "rnix"
    "bashls"
    "dockerls"
    "yamlls"
    "tsserver"
    "jsonls"
    "vimls"
    "html"
    "cssls"
    "ccls"
    #"omnisharp"
    "gopls"
    #"hls"
    "sumneko_lua"
    #"pwsh"
    "robotframeworklsp"
    "lemminx"
    "pylsp"
    #"pyright"
    #"python_language_server"
    "ansiblels"
    "solargraph"
    "groovyls"
    "rust_analyzer"
  ];

  mkNvimLsp = enabled:
    lib.concatMapStringsSep "\n" (name: nvimLsp."${name}") enabled;

  nvimLsp = {
    kotlin_language_server = ''
      nvim_lsp["kotlin_language_server"].setup {
        on_attach = on_attach;
        cmd = {"${kotlin-language-server}/bin/kotlin-language-server"};
        capabilities = capabilities;
      }
    '';
    rnix = ''
      nvim_lsp["rnix"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"};
        capabilities = capabilities;
      }
    '';
    bashls = ''
      nvim_lsp["bashls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/bash-language-server", "start"};
        capabilities = capabilities;
      }
    '';
    dockerls = ''
      nvim_lsp["dockerls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/docker-langserver", "--stdio"};
        capabilities = capabilities;
      }
    '';
    yamlls = ''
      nvim_lsp["yamlls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/yaml-language-server", "--stdio"};
        capabilities = capabilities;
        filetypes = { 'yaml', 'yaml.docker-compose' };
        root_dir = function(fname)
          return nvim_lsp.util.find_git_ancestor(fname);
        end;
        settings = {
          -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
          redhat = { telemetry = { enabled = false } };
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*";
              ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/master-standalone-strict/all.json"] = "/*.k8s.yaml";
            };
          };
        };
      }
    '';
    tsserver = ''
      nvim_lsp["tsserver"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/typescript-language-server", "--stdio"};
        capabilities = capabilities;
      }
    '';
    jsonls = ''
      nvim_lsp["jsonls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/vscode-json-languageserver", "--stdio"};
        capabilities = capabilities;
      }
    '';
    vimls = ''
      nvim_lsp["vimls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/vim-language-server", "--stdio"};
        capabilities = capabilities;
      }
    '';
    html = ''
      nvim_lsp["html"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/html-languageserver", "--stdio"};
        capabilities = capabilities;
      }
    '';
    cssls = ''
      nvim_lsp["cssls"].setup {
        on_attach = on_attach;
        cmd = {"${variables.homeDir}/.npm-packages/bin/css-languageserver", "--stdio"};
        capabilities = capabilities;
      }
    '';
    ccls = ''
      nvim_lsp["ccls"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.ccls}/bin/ccls"};
        capabilities = capabilities;
      }
    '';
    omnisharp = ''
      nvim_lsp["omnisharp"].setup {
        on_attach = on_attach;
        cmd = { "${pkgs.omnisharp-roslyn}/bin/omnisharp", "--languageserver" , "--hostPID", tostring(pid) };
        capabilities = capabilities;
      }
    '';
    gopls = ''
      nvim_lsp["gopls"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.gopls}/bin/gopls"};
        capabilities = capabilities;
      }
    '';
    hls = ''
      nvim_lsp["hls"].setup {
        on_attach = on_attach; cmd = {"${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper", "--lsp"};
        capabilities = capabilities;
      }
    '';
    sumneko_lua = ''
      nvim_lsp["sumneko_lua"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.sumneko-lua-language-server}/bin/lsp-language-server", "-E", "${pkgs.sumneko-lua-language-server}/extras/main.lua"};
        capabilities = capabilities;
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
    '';
    pwsh = ''
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
      nvim_lsp["pwsh"].setup {
        on_attach = on_attach;
        capabilities = capabilities;
      }
    '';
    robotframeworklsp = ''
      if not nvim_lsp["robotframework_ls"] then
        nvim_lsp_configs.robotframework_ls = {
          default_config = {
            cmd = {"robotframework_ls"};
            filetypes = {'robot'};
            root_dir = function(fname)
              return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
            end;
            settings = {};
          };
        }
      end
      nvim_lsp["robotframework_ls"].setup {
        on_attach = on_attach;
        capabilities = capabilities;
      }
    '';
    lemminx = ''
      nvim_lsp["lemminx"].setup {
        on_attach = on_attach;
        cmd = {"${lemminx}/bin/lemminx"};
        capabilities = capabilities;
        filetypes = {'xml'};
        root_dir = function(fname)
          return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
        end;
        settings = {};
      }
    '';
    pylsp = ''
      nvim_lsp["pylsp"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.python3Packages.python-lsp-server}/bin/pylsp"};
        capabilities = capabilities;
        filetypes = { 'python' };
        single_file_support = true;
      }
    '';
    pyright = ''
      nvim_lsp["pyright"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.pyright}/bin/pyright-langserver", "--stdio"};
        capabilities = capabilities;
        filetypes = { 'python' };
      }
    '';
    python_language_server = ''
      if not nvim_lsp["python_language_server"] then
        nvim_lsp_configs.python_language_server = {
          default_config = {
            cmd = { '${pkgs.python-language-server}/bin/python-language-server' };
            capabilities = capabilities;
            filetypes = { 'python' };
            root_dir = function(fname)
              local root_files = {
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
              }
              return nvim_lsp.util.root_pattern(unpack(root_files))(fname) or nvim_lsp.util.find_git_ancestor(fname) or nvim_lsp.util.path.dirname(fname)
            end;
          };
        }
      end
      nvim_lsp["python_language_server"].setup { on_attach = on_attach; }
    '';
    ansiblels = ''
      nvim_lsp["ansiblels"].setup {
        on_attach = on_attach;
        cmd = { '${variables.homeDir}/.npm-packages/bin/ansible-language-server', '--stdio' };
        capabilities = capabilities;
        settings = {
          ansible = {
            python = {
              interpreterPath = '${execCommand}';
            };
            ansibleLint = {
              path = '${pkgs.python3Packages.ansible-lint}/bin/ansible-lint';
              enabled = true;
              arguments = "";
            },
            ansible = {
              path = '${pkgs.python3Packages.ansible}/bin/ansible';
            };
            executionEnvironment = {
              enabled = false;
            };
          };
        };
        filetypes = { 'yaml.ansible', 'yaml' };
        root_dir = nvim_lsp.util.root_pattern('ansible.cfg', '.ansible-lint');
      }
    '';
    solargraph = ''
      nvim_lsp["solargraph"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.solargraph}/bin/solargraph", "stdio"};
        capabilities = capabilities;
      }
    '';
    groovyls = ''
      nvim_lsp["groovyls"].setup {
        on_attach = on_attach;
        cmd = {"${import ../nixes/groovy-language-server.nix { inherit pkgs; }}/bin/groovy-language-server"};
        capabilities = capabilities;
      }
    '';
    rust_analyzer = ''
      nvim_lsp["rust_analyzer"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.rust-analyzer}/bin/rust-analyzer"};
        capabilities = capabilities;
      }
    '';
  };

  execCommand = pkgs.writeScript "exec" ''
    #!${pkgs.stdenv.shell}
    exec "$@"
  '';

  ansibleLintPy = pkgs.writeScript "ansible-lint.py" ''
    import sys
    from subprocess import run, PIPE

    run(
      [ '${pkgs.python3Packages.ansible-lint}/bin/ansible-lint' ] + sys.argv[1:],
      shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    '';

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
      GuiFont! ${lib.escape [" "] "${variables.font.family}:h${toString variables.font.size}"}
      " call GuiClipboard()
    endif

    if exists("g:neovide")
      let g:neovide_cursor_animation_length=0.1
      set guifont=${lib.escape [" "] "${variables.font.family}:h${toString variables.font.size}"}
    endif
  '';

  customRC = ''
    let mapleader=","

    " if hidden is not set, TextEdit might fail.
    set hidden

    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    set cmdheight=2

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

    " colorscheme monokai

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
    set nosmartindent
    set nocopyindent
    set tabstop=2 shiftwidth=2 expandtab softtabstop=2
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

    nnoremap <silent> <PageUp> 10<up>
    nnoremap <silent> <PageDown> 10<down>
    inoremap <silent> <PageUp> <C-o>10<up>
    inoremap <silent> <PageDown> <C-o>10<down>
    vnoremap <silent> <PageUp> 10<up>
    vnoremap <silent> <PageDown> 10<down>
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
    vnoremap <C-S-c> y

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
    " nnoremap <C-d> :copy .<cr>
    vnoremap <C-S-D> :copy '><cr>
    " vnoremap <C-d> :copy '><cr>
    inoremap <C-S-D> <c-o>:copy .<cr>
    " inoremap <C-d> <c-o>:copy .<cr>

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

    let g:ctrlsf_ackprg='${pkgs.silver-searcher}/bin/ag'
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

          let l:fileExt = expand('%:e')
          if empty(l:fileExt)
            let l:filePattern = input('File pattern: ', '.*')
          else
            let l:filePattern = input('File pattern: ', '\.' . l:fileExt . '$')
          endif

          call inputrestore()
          if empty(l:filePattern)
            let l:filePattern = '.*'
          endif
          call ctrlsf#Search('-I -G "' . l:filePattern . '" ' . text)
        endif
      endif
    endf
    let g:ctrlsf_regex_pattern = 1

    " vnoremap <silent> <C-f> :call CtrlSFIfOpen(<SID>get_visual_selection())<cr>
    " nnoremap <silent> <C-f> :call CtrlSFIfOpen(expand("<cword>"))<cr>

    " nnoremap <C-f> <cmd>lua require('searchbox').incsearch()<CR>

    " vnoremap // :call feedkeys("/" . <SID>get_visual_selection())<cr>
    " nnoremap // :call feedkeys("/" . expand("<cword>"))<cr>

    let g:ctrlp_cmd = 'CtrlP'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'result',
      \ }
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_user_command = ['.git', 'cd %s && ${pkgs.git}/bin/git ls-files . -co --exclude-standard', '${pkgs.findutils}/bin/find %s -type f']
    " inoremap <silent> <c-p> <c-o>:CtrlP<cr>

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
    let g:VM_maps["Add Cursor At Pos"]           = '<C-t>'
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
    fu! <sid>WordMove(mode, forward)
      let initialLine=line('.')
      let initialCol=col('.')
      if a:mode == 'i'
        if a:forward
        else
        endif
      else
        if a:forward
          if initialCol == col('$')
            let newLine = search('^', "W", initialLine+1)
            let newCol = col('.')
          else
            let newLine = search('.', "W", initialLine)
            if initialCol == col('.')
              let newCol = col('$')
            else
              let newCol = col('.')
              echo newLine.",".newCol
            endif
          endif
        else
        endif
      endif
      call cursor(["".newLine, "".newCol])
    endfu


lua << EOF

function myMove(pattern, forward)
  flags = 'W'
  if forward == 0 then
    flags = flags .. 'b'
  end
  local initialrow, initialcol = unpack(vim.api.nvim_win_get_cursor(0))
  local row, col
  if forward == 1 then
    if initialcol+1 == vim.fn.col('$') then
      row = initialrow+1
      col = 1
    else
      row, col = unpack(vim.fn.searchpos(pattern, flags, initialrow))
      if col == 0 then
        row = initialrow
        col = vim.fn.col('$')
      end
    end
  else
    if initialcol == 0 then
      row = initialrow-1
      col = vim.fn.strlen(vim.fn.getline(row))+1
    else
      row, col = unpack(vim.fn.searchpos(pattern, flags, initialrow))
      if col == 0 then
        row = initialrow
        col = 1
      end
    end
  end
  vim.api.nvim_win_set_cursor(0, { row, col-1 })
end

function wordMove(mode, forward)
  local wpattern='[a-zA-Z0-9]\\+\\|^\\|$'
  if mode == 'i' then
    myMove(wpattern, forward)
  else
    myMove(wpattern, forward)
  end
end

vim.keymap.set("n", '<c-right>', function() wordMove("n", 1) end, { noremap = true, silent = true })
vim.keymap.set("n", '<c-left>', function() wordMove("n", 0) end, { noremap = true, silent = true })

vim.keymap.set("v", '<c-right>', function() wordMove("v", 1) end, { noremap = true, silent = true })
vim.keymap.set("v", '<c-left>', function() wordMove("v", 0) end, { noremap = true, silent = true })

vim.keymap.set("i", '<c-right>', function() wordMove("i", 1) end, { noremap = true, silent = true })
vim.keymap.set("i", '<c-left>', function() wordMove("i", 0) end, { noremap = true, silent = true })

EOF

    inoremap <silent> <A-del> <C-o>ce
    inoremap <silent> <C-del> <C-o>ce
    inoremap <silent> <C-BS> <C-W>

    nnoremap <silent> <C-del> "_dw

    nnoremap d "_d
    nnoremap D "_D
    vnoremap d "_d

    nnoremap <del> "_dl
    vnoremap <del> "_d

    set completeopt=menu,menuone,noselect

    let g:nvim_tree_quit_on_open = 1 "0 by default, closes the tree when you open a file
    " let g:nvim_tree_follow = 1 "0 by default, this option allows the cursor to be updated when entering a buffer
    let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
    let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
    let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
    let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
    " let g:nvim_tree_tab_open = 1 "0 by default, will open the tree when entering a new tab and the tree was previously open
    let g:nvim_tree_width_allow_resize  = 1 "0 by default, will not resize the tree when opening a file
    let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
    let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
    " let g:nvim_tree_lsp_diagnostics = 1 "0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
    " Dictionary of buffer option names mapped to a list of option values that
    " indicates to the window picker that the buffer's window should not be
    " selectable.
    let g:nvim_tree_show_icons = {
        \ 'git': 0,
        \ 'folders': 0,
        \ 'files': 0,
        \ 'folder_arrows': 0,
        \ }
    " let g:nvim_tree_disable_netrw = 0

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
  -- buf_set_keymap('n', 'cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '{', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', '}', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
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
  --     hi LspReferenceRead cterm=bold ctermbg=red guibg=Grey50
  --     hi LspReferenceText cterm=bold ctermbg=red guibg=Grey50
  --     hi LspReferenceWrite cterm=bold ctermbg=red guibg=Grey50
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
end

cfg = {
  bind = true, -- This is mandatory, otherwise border config won't get registered.
}
require'lsp_signature'.setup(cfg)

local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = function(entry, vim_item)
      local item = entry:get_completion_item()
      vim_item.menu = item.detail
      return vim_item
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<PageUp>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<PageDown>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Left>'] = cmp.mapping.close(),
    ['<Right>'] = cmp.mapping.close(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'vsnip' }, -- For vsnip users.
    { name = 'treesitter' },
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
    { name = 'buffer' },
    { name = 'path' },
    { name = 'rg' },
  }, {
    { name = 'spell' },
  })
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

${enabledNvimLsp}

require("neo-tree").setup({
  close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "ﰊ",
      default = "*",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "✚",
        deleted   = "✖",
        modified  = "",
        renamed   = "",
        -- Status type
        untracked = "",
        ignored   = "",
        unstaged  = "",
        staged    = "",
        conflict  = "",
      }
    },
  },
  window = {
    position = "left",
    width = 40,
    mappings = {
      ["<cr>"] = "open",
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      ["C"] = "close_node",
      ["<bs>"] = "navigate_up",
      ["."] = "set_root",
      ["H"] = "toggle_hidden",
      ["R"] = "refresh",
      ["/"] = "fuzzy_finder",
      ["f"] = "filter_on_submit",
      ["<c-x>"] = "clear_filter",
      ["a"] = "add",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy", -- takes text input for destination
      ["m"] = "move", -- takes text input for destination
      ["q"] = "close_window",
    }
  },
  nesting_rules = {},
  filesystem = {
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db"
        --"node_modules"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        --".DS_Store",
        --"thumbs.db"
      },
    },
    follow_current_file = true, -- This will find and focus the file in the active buffer every
                                 -- time the current file is changed while the tree is open.
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                                            -- in whatever position is specified in window.position
                          -- "open_current",  -- netrw disabled, opening a directory opens within the
                                            -- window like netrw would, regardless of window.position
                          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                                    -- instead of relying on nvim autocmd events.
  },
  buffers = {
    show_unloaded = true,
    window = {
      mappings = {
        ["bd"] = "buffer_delete",
      }
    },
  },
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["A"]  = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      }
    }
  },
  event_handlers = {
    {
      event = "file_opened",
      handler = function(arg)
        require("neo-tree").close_all()
      end,
    }
  }
})

-- require'nvim-tree'.setup {
--   -- disables netrw completely
--   disable_netrw       = true,
--   -- hijack netrw window on startup
--   hijack_netrw        = true,
--   -- open the tree when running this setup function
--   open_on_setup       = false,
--   -- will not open on setup if the filetype is in this list
--   ignore_ft_on_setup  = {},
--   -- closes neovim automatically when the tree is the last **WINDOW** in the view
--   auto_close          = false,
--   -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
--   open_on_tab         = false,
--   -- hijacks new directory buffers when they are opened.
--   update_to_buf_dir   = {
--     -- enable the feature
--     enable = true,
--     -- allow to open the tree if it was previously closed
--     auto_open = true,
--   },
--   -- hijack the cursor in the tree to put it at the start of the filename
--   hijack_cursor       = false,
--   -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
--   update_cwd          = false,
--   -- show lsp diagnostics in the signcolumn
--   diagnostics = {
--     enable = true,
--     icons = {
--       hint = "",
--       info = "",
--       warning = "",
--       error = "",
--     }
--   },
--   -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
--   update_focused_file = {
--     -- enables the feature
--     enable      = true,
--     -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
--     -- only relevant when `update_focused_file.enable` is true
--     update_cwd  = false,
--     -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
--     -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
--     ignore_list = {}
--   },
--   -- configuration options for the system open command (`s` in the tree by default)
--   system_open = {
--     -- the command to run this, leaving nil should work in most cases
--     cmd  = nil,
--     -- the command arguments as a list
--     args = {}
--   },
--
--   view = {
--     -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
--     width = 30,
--     -- height of the window, can be either a number (columns) or a string in `%`, for top or bottom side placement
--     height = 30,
--     -- Hide the root path of the current folder on top of the tree
--     hide_root_folder = true,
--     -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
--     side = 'left',
--     -- if true the tree will resize itself after opening a file
--     auto_resize = true,
--     mappings = {
--       -- custom only false will merge the list with the default mappings
--       -- if true, it will only use your list to set the mappings
--       custom_only = false,
--       -- list of mappings to set on the tree manually
--       list = {}
--     }
--   }
-- }

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = true,
    signs = true,
    update_in_insert = true
  }
)

local fileinfo = require("galaxyline.providers.fileinfo")
local lspclient = require("galaxyline.providers.lsp")
local gl = require('galaxyline')
local colors = require('galaxyline.themes.colors').gruvbox
local condition = require('galaxyline.condition')
local gls = gl.section
gl.short_line_list = {'NvimTree','vista','dbui','packer'}

gls.left[1] = {
  RainbowRed = {
    provider = function() return '▊ ' end,
    highlight = {colors.blue,colors.bg}
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {n = colors.red, i = colors.green,v=colors.blue,
                          [""] = colors.blue,V=colors.blue,
                          c = colors.magenta,no = colors.red,s = colors.orange,
                          S=colors.orange,[""] = colors.orange,
                          ic = colors.yellow,R = colors.violet,Rv = colors.violet,
                          cv = colors.red,ce=colors.red, r = colors.cyan,
                          rm = colors.cyan, ['r?'] = colors.cyan,
                          ['!']  = colors.red,t = colors.red}
      vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color[vim.fn.mode()])
      return '  '
    end,
    highlight = {colors.red,colors.bg,'bold'},
  },
}
gls.left[3] = {
  FileSize = {
    provider = 'FileSize',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg,colors.bg}
  }
}
gls.left[4] ={
  FileIcon = {
    provider = 'FileIcon',
    condition = condition.buffer_not_empty,
    highlight = {require('galaxyline.providers.fileinfo').get_file_icon_color,colors.bg},
  },
}

gls.left[5] = {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.magenta,colors.bg,'bold'}
  }
}

gls.left[6] = {
  LineInfo = {
    provider = 'LineColumn',
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.fg,colors.bg},
  },
}

gls.left[7] = {
  PerCent = {
    provider = 'LinePercent',
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.fg,colors.bg,'bold'},
  }
}

gls.left[8] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.bg}
  }
}
gls.left[9] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow,colors.bg},
  }
}

gls.left[10] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.cyan,colors.bg},
  }
}

gls.left[11] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue,colors.bg},
  }
}

gls.mid[1] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function ()
      local tbl = {['dashboard'] = true,[""]=true}
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = ' LSP:',
    highlight = {colors.cyan,colors.bg,'bold'}
  }
}

gls.right[1] = {
  FileEncode = {
    provider = 'FileEncode',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.green,colors.bg,'bold'}
  }
}

gls.right[2] = {
  FileFormat = {
    provider = 'FileFormat',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.green,colors.bg,'bold'}
  }
}

gls.right[3] = {
  GitIcon = {
    provider = function() return '  ' end,
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.violet,colors.bg,'bold'},
  }
}

gls.right[4] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = condition.check_git_workspace,
    highlight = {colors.violet,colors.bg,'bold'},
  }
}

gls.right[5] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = condition.hide_in_width,
    icon = '  ',
    highlight = {colors.green,colors.bg},
  }
}
gls.right[6] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = condition.hide_in_width,
    icon = ' 柳',
    highlight = {colors.orange,colors.bg},
  }
}
gls.right[7] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = condition.hide_in_width,
    icon = '  ',
    highlight = {colors.red,colors.bg},
  }
}

gls.right[8] = {
  RainbowBlue = {
    provider = function() return ' ▊' end,
    highlight = {colors.blue,colors.bg}
  },
}

gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.blue,colors.bg,'bold'}
  }
}

gls.short_line_left[2] = {
  SFileName = {
    provider =  'SFileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg,colors.bg,'bold'}
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    highlight = {colors.fg,colors.bg}
  }
}

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
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
    indicator_icon = '▎',
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local s = " "
      for err_type, count in pairs(diagnostics_dict) do
        if err_type == "error" then
          s = s .. count .. " "
        elseif err_type == "warning" then
          s = s .. count .. " "
        else
          s = s .. count .. " "
        end
      end
      return s
    end,
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center"}},
    separator_style = { "", "" },
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    always_show_bufferline = true,
  }
}

require("telescope").setup {
  defaults = {
    layout_strategy = 'vertical',
    layout_config = { vertical = { width = 0.9, preview_height = 0.7 } },
    wrap_results = true,
    vimgrep_arguments = {
      "${pkgs.ripgrep}/bin/rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    }
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    frecency = {
      default_workspace = 'CWD',
      show_scores = false,
      show_unindexed = true,
      ignore_patterns = {"*.git/*", "*/tmp/*"},
      disable_devicons = true,
      workspaces = {}
    }
  }
}
require('telescope').load_extension('fzy_native')
require"telescope".load_extension("frecency")

require("scrollbar").setup({
    handle = {
        text = " ",
        color = "#5c5856",
    },
    marks = {
        Search = { text = { "-", "=" }, priority = 0, color = "orange" },
        Error = { text = { "-", "=" }, priority = 1, color = "red" },
        Warn = { text = { "-", "=" }, priority = 2, color = "yellow" },
        Info = { text = { "-", "=" }, priority = 3, color = "blue" },
        Hint = { text = { "-", "=" }, priority = 4, color = "green" },
        Misc = { text = { "-", "=" }, priority = 5, color = "purple" },
    },
    excluded_filetypes = {
        "",
        "prompt",
        "TelescopePrompt",
        "NvimTree",
    },
    autocmd = {
        render = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
        },
    },
    handlers = {
        diagnostic = true,
        search = true,
    },
})
-- require("hlslens").setup()
-- require("scrollbar.handlers.search").setup()
require("themer").setup({
  colorscheme = "gruvbox",
})

-- require("regexplainer").setup({
--   mode = "narrative",
--   auto = false,
--   debug = false,
--   display = "popup",
--   mappings = {
--     show = "cr",
--   },
--   narrative = {
--     separator = "\n",
--   },
-- })

require('smart-splits').ignored_buftypes = { 'NvimTree' }
require('smart-splits').ignored_filetypes = {
  'nofile',
  'quickfix',
  'prompt',
}


require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = "all",

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  -- ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "jsonc" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

local Path = require('plenary.path')
require('session_manager').setup({
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
  autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autosave_last_session = true, -- Automatically save last session on exit and on session switch.
  autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
    'gitcommit',
  },
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})
EOF
    " au VimEnter * lua _G.self_color_gruvbox_dark()
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

    nnoremap gd :lua require'telescope.builtin'.lsp_definitions{}<cr>
    nnoremap gD :lua require'telescope.builtin'.lsp_implementations{}<cr>
    nnoremap gr :lua require'telescope.builtin'.lsp_references{}<cr>
    nnoremap ca :lua require'telescope.builtin'.lsp_code_actions{}<cr>
    vnoremap ca :lua require'telescope.builtin'.lsp_range_code_actions{}<cr>

    nnoremap km :lua require'telescope.builtin'.keymaps{}<cr>

    nnoremap <C-S-f> :lua require'telescope.builtin'.live_grep{ disable_devicons = true }<cr>
    vnoremap <C-S-f> <esc>:lua require'telescope.builtin'.live_grep{ disable_devicons = true }<cr>

    nnoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>
    vnoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>
    inoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>

    nnoremap <C-d> :lua require'telescope.builtin'.diagnostics{ bufnr=0, disable_devicons = true }<cr>

    nnoremap <C-g> :<C-u>call gitblame#echo()<CR>


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

    " set sessionoptions-=options
    " set sessionoptions+=globals

    " function! Sha1(text)
    "   let hash = system('${sha1Cmd} "' . a:text . '"')
    "   return hash
    " endfunction

    " function! SessionPath()
    "   return "${variables.homeDir}/.vim-sessions/" . ProjectName() . "-" . Sha1( getcwd() ) . ".vim"
    " endfunction

    " function! WipeAll()
    "     let i = 0
    "     let n = bufnr("$")
    "     while i < n
    "         let i = i + 1
    "         if bufexists(i)
    "             execute("bw " . i)
    "         endif
    "     endwhile
    " endfunction

    " autocmd VimLeavePre * nested if (!isdirectory("${variables.homeDir}/.vim-sessions")) |
    "     \ call mkdir("${variables.homeDir}/.vim-sessions") |
    "     \ endif |
    "     \ execute "mksession! " . SessionPath()

    " function! MySessionLoad()
    "   let l:sessionPath = SessionPath()
    "   if argc() == 0 && filereadable(l:sessionPath)
    "     " call WipeAll()
    "     execute "source " . l:sessionPath
    "   endif
    " endfunction

    " autocmd VimEnter * nested call MySessionLoad()

    "augroup CtrlPExtension
    "  autocmd!
    "  autocmd FocusGained  * CtrlPClearCache
    "  autocmd BufWritePost * CtrlPClearCache
    "augroup END

    " tab sball
    " set switchbuf=usetab,newtab
    " au BufAdd,BufNewFile,BufRead * nested tab sball

    "augroup bufclosetrack
    "  au!
    "  autocmd BufLeave * let g:lastWinName = @%
    "augroup END
    "function! LastWindow()
    "  exe "edit " . g:lastWinName
    "endfunction
    "command -nargs=0 LastWindow call LastWindow()

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

    tnoremap <silent> <esc><esc> <C-\><C-n>
    tnoremap <C-v> <C-\><C-N>"+pi
    tnoremap <C-S-v> <C-\><C-N>"+pi

    tnoremap <silent> <c-PageUp> <C-\><C-N>:bprev<cr>
    tnoremap <silent> <c-PageDown> <C-\><C-N>:bnext<cr>

    tnoremap <silent> <a-left> <C-left>
    tnoremap <silent> <a-right> <C-right>

    nnoremap <silent> <C-S-T> :edit term://${variables.vimShell or "zsh"}<cr>
    " let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

    cnoremap <C-v> <C-r>+

    let g:NERDDefaultAlign = 'left'

    nnoremap <C-o> :Neotree toggle reveal<CR>
    inoremap <C-o> <esc>:Neotree toggle reveal<CR>
    " nnoremap <C-o> :NvimTreeToggle<CR>:NvimTreeRefresh<CR>
    " inoremap <C-o> <esc>:NvimTreeToggle<CR>:NvimTreeRefresh<CR>
    " nnoremap <leader>r :NvimTreeRefresh<CR>
    " nnoremap <leader>n :NvimTreeFindFile<CR>
    " NvimTreeOpen and NvimTreeClose are also available if you need them

    " let g:fakeclip_provide_clipboard_key_mappings = !empty($WAYLAND_DISPLAY)

    au BufNewFile,BufRead *.robot setlocal filetype=robot

    au BufNewFile,BufRead Jenkinsfile setlocal filetype=groovy

    " let g:gitblame_date_format = '%r'
    " let g:blamer_enabled = 1
    " let g:blamer_show_in_visual_modes = 0
    " let g:blamer_show_in_insert_modes = 0
    " let g:blamer_relative_time = 1
    " let g:blamer_template = '<committer> • <committer-time> • <summary>'

    nnoremap <C-S-P> <C-o>
    inoremap <C-S-P> <esc><C-o>
    nnoremap <C-S-N> <C-i>
    inoremap <C-S-N> <esc><C-i>

    set splitbelow
    set splitright
    nnoremap <silent> <A-h> :sp<cr>
    nnoremap <silent> <A-v> :vsp<cr>
    nnoremap <silent> <A-c> :close<cr>
    " nnoremap <A-Down> <C-W><C-J>
    " nnoremap <A-Up> <C-W><C-K>
    " nnoremap <A-Right> <C-W><C-L>
    " nnoremap <A-Left> <C-W><C-H>

    nnoremap <A-Left> :lua require('smart-splits').move_cursor_left()<CR>
    nnoremap <A-Down> :lua require('smart-splits').move_cursor_down()<CR>
    nnoremap <A-Up> :lua require('smart-splits').move_cursor_up()<CR>
    nnoremap <A-Right> :lua require('smart-splits').move_cursor_right()<CR>

    nnoremap <C-U> :MundoToggle<CR>

    set redrawtime=3000

    set re=2

    hi BlackBg guibg=black

    augroup term
      au!
      au TermOpen * :setlocal winhighlight=Normal:BlackBg
      au TermOpen * :setlocal nonumber
      au TermOpen * :setlocal nocursorline
      au TermOpen * :setlocal signcolumn=no
      au TermOpen * :nnoremap <buffer><cr> i
    augroup END

    highlight CursorLine guibg=Grey22
    highlight MatchParen guibg=Grey40
    highlight GalaxyLineFillSection guibg=#32302f

    highlight SignifySignAdd    ctermfg=green  guifg=#00ff00 cterm=NONE gui=NONE
    highlight SignifySignDelete ctermfg=red    guifg=#ff0000 cterm=NONE gui=NONE
    highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE

    nnoremap <C-H> :SignifyHunkDiff<cr>
    inoremap <C-H> <esc>:SignifyHunkDiff<cr>

    nnoremap <silent> <C-L> :noh<cr>

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
          #vim-pasta
          #vimPlugins.ctrlsf-vim
          #ctrlp
          #ctrlp-py-matcher
          #vim-airline vim-airline-themes
          #vim-nix
          nerdcommenter
          #ale
          #YouCompleteMe
          #vimPlugins.omnisharp-vim
          robotframework-vim
          sleuth
          vimPlugins.vim-hashicorp-tools
          #Jenkinsfile-vim-syntax
          vimPlugins.neovim-gui-shim
          #vim-vinegar
          #vim-fugitive
          #vimPlugins.nerdtree
          #vimPlugins.nerdtree-git-plugin
          #ansible-vim
          #vimPlugins.python-mode
          #vim-polyglot
          #kotlin-vim
          vimPlugins.nvim-lspconfig
          #deoplete-nvim
          #deoplete-lsp
          #vimPlugins.neovim-auto-autoread
          vim-rsi
          vim-signify
          #vimPlugins.vim-perforce
          vimPlugins.lsp_signature-nvim
          vimPlugins.git-blame-vim
          vimPlugins.nvim-web-devicons
          #nvim-tree-lua
          #vimPlugins.lspsaga-nvim
          vimPlugins.vim-fakeclip
          vim-matchup
          #nvim-compe
          plenary-nvim
          telescope-nvim
          vimPlugins.bufferline-nvim
          vimPlugins.galaxyline-nvim
          vimPlugins.lush-nvim
          #vimPlugins.gruvbox-nvim
          vim-mundo
          telescope-fzy-native-nvim
          vimPlugins.nvim-cmp
          vimPlugins.cmp-buffer
          vimPlugins.cmp-nvim-lsp
          vimPlugins.cmp-vsnip
          vimPlugins.cmp-path
          vimPlugins.cmp-cmdline
          vimPlugins.cmp-spell
          vimPlugins.cmp-nvim-lsp-signature-help
          vimPlugins.cmp-rg
          vimPlugins.cmp-treesitter
          #vimPlugins.searchbox-nvim
          vimPlugins.nvim-hlslens
          vimPlugins.nvim-scrollbar
          vimPlugins.themer-lua
          vimPlugins.vim-vsnip
          vimPlugins.friendly-snippets
          nui-nvim
          #vimPlugins.nvim-regexplainer
          vimPlugins.smart-splits-nvim
          vimPlugins.neo-tree-nvim
          (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
          vimPlugins.neovim-session-manager
          telescope-frecency-nvim
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

    if [[ "$1" == "clean" ]]
    then
      rm -vrf ${variables.homeDir}/.npm-packages/*
      rm -vrf ${variables.homeDir}/.py-packages/*
      exit 0
    fi

    export NPM_PACKAGES="${variables.homeDir}/.npm-packages"
    export PY_PACKAGES="${variables.homeDir}/.py-packages"

    npm_global_install() {
      mkdir -p $NPM_PACKAGES
      ${pkgs.nodejs}/bin/npm install -g --prefix="$NPM_PACKAGES" "$@"
    }

    pip_install() {
      ${pkgs.python3Packages.python}/bin/python -m venv "$PY_PACKAGES"
      $PY_PACKAGES/bin/python -m pip install --upgrade pip
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
      pkgs.stdenv.cc
      pkgs.python3Packages.python
      pkgs.perl
      pkgs.nodejs
      pkgs.gnugrep
      pkgs.python3Packages.yamllint
      pkgs.ripgrep
    ]}:$PATH"
    export CC="${pkgs.stdenv.cc}/bin/cc"
    export LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.stdenv.cc.libc}/lib:$LIBRARY_PATH"
    ${neovim}/bin/nvim "$@"
  '';
} {
  target = "${variables.homeDir}/bin/guinvim";
  source = pkgs.writeScript "guinvim.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    trap "kill 0" EXIT
    export NVIM_LISTEN="127.0.0.1:$(${pkgs.python3Packages.python}/bin/python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
    { ${pkgs.python3Packages.python}/bin/python3 -c 'import time; time.sleep(0.4);'; ''${NVIM_FRONTEND_PATH} ''${NVIM_FRONTEND_ARGS:-"--server"} "$NVIM_LISTEN"; } &
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
