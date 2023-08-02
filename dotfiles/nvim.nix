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

  enabledNvimLsp = mkNvimLsp [
    #"kotlin_language_server"
    #"rnix"
    "nil"
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
    #"sumneko_lua"
    "lua_lsp"
    #"pwsh"
    "robotframework_ls"
    "lemminx"
    #"pylsp"
    "pyright"
    #"python_language_server"
    #"ansiblels"
    "solargraph"
    "groovyls"
    "rust_analyzer"
    "ltex"
    "terraform_lsp"
  ];

  mkNvimLsp = enabled:
    lib.concatMapStringsSep "\n" (name: nvimLsp."${name}") enabled;

  nvimLsp = {
    kotlin_language_server = ''
      setup_lsp("kotlin_language_server", {
        on_attach = on_attach;
        cmd = {"${kotlin-language-server}/bin/kotlin-language-server"};
        capabilities = capabilities;
      })
    '';
    nil = ''
      setup_lsp("nil_ls", {
        on_attach = on_attach;
        cmd = {"${pkgs.nil}/bin/nil"};
        capabilities = capabilities;
      })
    '';
    rnix = ''
      setup_lsp("rnix", {
        on_attach = on_attach;
        cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"};
        capabilities = capabilities;
      })
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
              ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/master-standalone-strict/all.json"] = "/*k8s*";
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
    robotframework_ls = ''
      nvim_lsp["robotframework_ls"].setup {
        on_attach = on_attach;
        cmd = {"robotframework_ls"};
        capabilities = capabilities;
        filetypes = {'robot'};
        settings = {
          robot = {
            python = {
              env = {
                PYTHONPATH = os.getenv('PYTHONPATH');
              };
            };
          };
        };
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
    ltex = ''
      nvim_lsp["ltex"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.ltex-ls}/bin/ltex-ls"};
        capabilities = capabilities;
        settings = {
          ltex = {
            enabled = true,
            language = "en-US",
          },
        },
      }
    '';
    terraformls = ''
      nvim_lsp["terraformls"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.terraform-ls}/bin/terraform-ls", "serve"};
        capabilities = capabilities;
      }
    '';
    terraform_lsp = ''
      nvim_lsp["terraform_lsp"].setup {
        on_attach = on_attach;
        cmd = {"${pkgs.terraform-lsp}/bin/terraform-lsp"};
        capabilities = capabilities;
      }
    '';
    lua_lsp = ''
      nvim_lsp_configs["lua_lsp"] = {
        default_config = {
          cmd = { '${pkgs.luaPackages.lua-lsp}/bin/lua-lsp' };
          capabilities = capabilities;
          filetypes = { 'lua' };
          root_dir = function(fname)
            return nvim_lsp.util.find_git_ancestor(fname) or vim.fn.getcwd()
          end,
          settings = {};
        };
      }
      nvim_lsp.lua_lsp.setup {
        on_attach = on_attach;
      }
    '';
  };

  execCommand = pkgs.writeScript "exec" ''
    #!${pkgs.stdenv.shell}
    exec "$@"
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
      let g:neovide_cursor_animation_length=0.05
      set guifont=${lib.escape [" "] "${variables.font.family}:h${toString variables.font.size}"}

      " Set transparency and background color (title bar color)
      let g:neovide_transparency=0.975
      let g:neovide_transparency_point=0.975
      let g:neovide_background_color = '#0f1117'.printf('%x', float2nr(255 * g:neovide_transparency_point))
    endif

lua << EOF
      vim.g.gui_font_default_size = ${toString variables.font.size}
      vim.g.gui_font_size = vim.g.gui_font_default_size
      vim.g.gui_font_face = "${variables.font.family}"

      RefreshGuiFont = function()
        vim.opt.guifont = string.format("%s:h%s",vim.g.gui_font_face, vim.g.gui_font_size)
      end

      ResizeGuiFont = function(delta)
        vim.g.gui_font_size = vim.g.gui_font_size + delta
        RefreshGuiFont()
      end

      ResetGuiFont = function()
        vim.g.gui_font_size = vim.g.gui_font_default_size
        RefreshGuiFont()
      end

      -- Call function on startup to set default value
      ResetGuiFont()

      -- Keymaps

      local opts = { noremap = true, silent = true }

      vim.keymap.set({'n', 'i'}, "<C-=>", function() ResizeGuiFont(1)  end, opts)
      vim.keymap.set({'n', 'i'}, "<C-->", function() ResizeGuiFont(-1) end, opts)
      vim.keymap.set({'n', 'i'}, "<C-0>", function() ResetGuiFont() end, opts)
EOF
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

    " set colorcolumn=80

    set scrolloff=5
    set sidescrolloff=5

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
    tnoremap <silent> <C-S-W> <C-\><C-N>:bd!<cr>
    inoremap <silent> <C-S-W> <C-o>:bd!<cr>
    " nnoremap <silent> <C-w> :bd<cr>
    " inoremap <silent> <C-w> <C-o>:bd<cr>
    " map <C-q> <esc>:qall
    " inoremap <C-q> <esc>:qall
    "nnoremap <silent> <c-s> :w<CR>
    "inoremap <silent> <c-s> <C-o>:w<CR>

    nnoremap <silent> <c-PageUp> :BufferLineCyclePrev<CR>
    nnoremap <silent> <c-PageDown> :BufferLineCycleNext<CR>
    inoremap <silent> <c-PageUp> <C-o>:BufferLineCyclePrev<CR>
    inoremap <silent> <c-PageDown> <C-o>:BufferLineCycleNext<CR>
    tnoremap <silent> <c-PageUp> <C-\><C-N>:BufferLineCyclePrev<CR>
    tnoremap <silent> <c-PageDown> <C-\><C-N>:BufferLineCycleNext<CR>

    nnoremap <silent> <S-PageUp> :BufferLineCyclePrev<CR>
    nnoremap <silent> <S-PageDown> :BufferLineCycleNext<CR>
    inoremap <silent> <S-PageUp> <C-o>:BufferLineCyclePrev<CR>
    inoremap <silent> <S-PageDown> <C-o>:BufferLineCycleNext<CR>
    tnoremap <silent> <S-PageUp> <C-\><C-N>:BufferLineCyclePrev<CR>
    tnoremap <silent> <S-PageDown> <C-\><C-N>:BufferLineCycleNext<CR>

    nnoremap <silent><C-S-PageDown> :BufferLineMoveNext<CR>
    nnoremap <silent><C-S-PageUp> :BufferLineMovePrev<CR>
    inoremap <silent><C-S-PageDown> <C-o>:BufferLineMoveNext<CR>
    inoremap <silent><C-S-PageUp> <C-o>:BufferLineMovePrev<CR>

    nnoremap <silent> <cr> o
    nnoremap <silent> <c-cr> o
    inoremap <silent> <c-cr> <C-o>o

    "inoremap <C-u> <esc>ui
    "nnoremap <C-u> u
    "nno <C-r> <C-R>
    "ino <C-r> <esc><C-R>
    inoremap <C-z> <C-O>u
    inoremap <C-S-Z> <C-O><C-R>
    nnoremap <C-z> u

    inoremap <A-u> <C-O>u
    nnoremap <A-u> u
    inoremap <A-r> <C-O><C-R>
    nnoremap <A-r> <C-R>

    inoremap <C-U> <Cmd>:UndotreeToggle<CR>

    let $PATH .= ':${lib.makeBinPath [
      pkgs.stdenv.cc
      pkgs.python3Packages.python
      pkgs.perl
      pkgs.nodejs
      pkgs.gnugrep
      pkgs.python3Packages.yamllint
      pkgs.ripgrep
      pkgs.sshpass
      pkgs.openssh
      pkgs.jdk11
      pkgs.graphviz
      pkgs.python3Packages.docutils
      pkgs.shellcheck
      pkgs.tree-sitter
      pkgs.coreutils-full
      pkgs.delta
    ]}:${variables.homeDir}/.npm-packages/bin:${variables.homeDir}/.py-packages/bin'
    let $CC = "${pkgs.stdenv.cc}/bin/cc"
    let $LIBRARY_PATH .= ":${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.stdenv.cc.libc}/lib"
    let $LD_LIBRARY_PATH .= ":${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.stdenv.cc.libc}/lib"
    let $LESS = "iMRS"

    function! NoOP()
    endf

    nnoremap <silent> <PageUp> 10<up>
    nnoremap <silent> <PageDown> 10<down>

    inoremap <expr> <silent> <PageUp> line('.')==1?'<C-o>:call NoOP()<CR>':'<C-o>10k'
    inoremap <expr> <silent> <PageDown> line('.')==line('$')?'<C-o>:call NoOP()<CR>':'<C-o>10j'

    vnoremap <silent> <PageUp> 10<up>
    vnoremap <silent> <PageDown> 10<down>

    "nnoremap <S-PageUp> v10<up>
    "nnoremap <S-PageDown> v10<down>
    nnoremap <S-Down> vj
    nnoremap <S-Up> vk
    nnoremap <S-Left> vh
    nnoremap <S-Right> vl

    "inoremap <S-PageUp> <C-o>v10<up>
    "inoremap <S-PageDown> <C-o>v10<down>
    inoremap <S-Down> <C-o>vj
    inoremap <S-Up> <C-o>vk
    inoremap <S-Left> <C-o>vh
    inoremap <S-Right> <C-o>vl
    inoremap <S-Home> <C-o>v<Home>
    inoremap <S-End> <C-o>v<End>

    "vnoremap <S-PageUp> 10<up>
    "vnoremap <S-PageDown> 10<down>
    vnoremap <S-Down> j
    vnoremap <S-Up> k
    vnoremap <S-Left> h
    vnoremap <S-Right> l

    nnoremap <C-k> "_dd
    inoremap <C-k> <C-o>"_dd
    vnoremap <C-k> "_d

    augroup MyCTRLX
      autocmd!
      autocmd VimEnter * iunmap <C-X><C-A>
    augroup END
    inoremap <C-x> <C-o>dd
    nnoremap <C-x> dd
    vnoremap <C-x> d

    " nnoremap <C-a> gg0vG$
    " inoremap <C-a> <C-o>gg0vG$

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

    function! MoveLineUp()
      call MoveLineOrVisualUp(".", "")
    endfunction

    function! MoveLineDown()
      call MoveLineOrVisualDown(".", "")
    endfunction

    function! MoveVisualUp()
      call MoveLineOrVisualUp("'<", "'<,'>")
      normal gv
    endfunction

    function! MoveVisualDown()
      call MoveLineOrVisualDown("'>", "'<,'>")
      normal gv
    endfunction

    function! MoveLineOrVisualUp(line_getter, range)
      let l_num = line(a:line_getter)
      if l_num - v:count1 - 1 < 0
        let move_arg = "0"
      else
        let move_arg = a:line_getter." -".(v:count1 + 1)
      endif
      call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
    endfunction

    function! MoveLineOrVisualDown(line_getter, range)
      let l_num = line(a:line_getter)
      if l_num + v:count1 > line("$")
        let move_arg = "$"
      else
        let move_arg = a:line_getter." +".v:count1
      endif
      call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
    endfunction

    function! MoveLineOrVisualUpOrDown(move_arg)
      let col_num = virtcol(".")
      execute "silent! ".a:move_arg
      execute "normal! ".col_num."|"
    endfunction

    vnoremap <silent> <C-Up> :<C-u>call MoveVisualUp()<CR>
    vnoremap <silent> <C-Down> :<C-u>call MoveVisualDown()<CR>

    nnoremap <C-S-d> :copy .<cr>
    vnoremap <C-S-d> :copy '><cr>
    inoremap <C-S-d> <c-o>:copy .<cr>

    vnoremap <Tab> >gv
    vnoremap <S-Tab> <gv
    nnoremap <Tab> >>
    nnoremap <S-Tab> <<
    inoremap <S-Tab> <C-d>

    "nmap <C-S-Down> :m .+1<CR>==
    "nmap <C-S-Up> :m .-2<CR>==
    "inoremap <C-S-Down> <C-o>:m .+1<CR>
    "inoremap <C-S-Up> <C-o>:m .-2<CR>
    "vmap <C-S-Down> :m '>+1<CR>gv=gv
    "vmap <C-S-Up> :m '<-2<CR>gv=gv

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

    inoremap <C-/> <C-o>/
    inoremap <C-n> <C-o>n
    inoremap <C-S-n> <C-o>N

    " vnoremap <C-f> :call feedkeys("/" . <SID>get_visual_selection())<cr>
    " inoremap <C-f> <Cmd>call feedkeys("/" . expand("<cword>"))<cr>

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

    let g:VM_mouse_mappings = 0
    let g:VM_default_mappings = 0
    let g:VM_quit_after_leaving_insert_mode = 1
    inoremap <silent> <C-S-Down> <esc>:call vm#commands#add_cursor_down(0, 1)<cr>
    inoremap <silent> <C-S-Up> <esc>:call vm#commands#add_cursor_up(0, 1)<cr>
    inoremap <silent> <C-S-a> <esc>:call vm#commands#add_cursor_at_pos(0)<cr>

    let g:VM_maps = {}
    let g:VM_maps["Select Cursor Down"] = '<C-S-Down>'      " start selecting down
    let g:VM_maps["Select Cursor Up"]   = '<C-S-Up>'        " start selecting up
    let g:VM_maps["Add Cursor At Pos"]   = '<C-S-a>'

    function! VM_Start()
      inoremap <buffer> <Esc> <Esc>
    endfunction
    function! VM_Exit()
      iunmap <buffer> <Esc>
    endfunction

    set autoread
    autocmd FocusGained,BufEnter * silent! checktime

    "nnoremap <c-_> <leader>c<space>
    "inoremap <c-_> <C-o><plug>NERDCommenterToggle
    "vnoremap <c-_> <plug>NERDCommenterToggle
    inoremap <c-\> <C-o><plug>NERDCommenterToggle
    vnoremap <c-\> <plug>NERDCommenterToggle

    "nnoremap <c-/> <leader>c<space>
    "inoremap <c-/> <C-o><leader>c<space>
    "vnoremap <c-/> <leader>c<space>

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


lua <<EOF

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
  if row > 0 and row <= vim.fn.line('$') then
    vim.api.nvim_win_set_cursor(0, { row, col-1 })
  end
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
vim.keymap.set("v", '<c-s-right>', function() wordMove("v", 1) end, { noremap = true, silent = true })
vim.keymap.set("v", '<c-s-left>', function() wordMove("v", 0) end, { noremap = true, silent = true })

vim.keymap.set("i", '<c-right>', function() wordMove("i", 1) end, { noremap = true, silent = true })
vim.keymap.set("i", '<c-left>', function() wordMove("i", 0) end, { noremap = true, silent = true })
vim.keymap.set("i", '<c-s-right>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('v',true,false,true),'x',false); wordMove("i", 1) end, { noremap = true, silent = true })
vim.keymap.set("i", '<c-s-left>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('v',true,false,true),'x',false); wordMove("i", 0) end, { noremap = true, silent = true })

EOF
    vnoremap <esc> <esc><esc>i

    inoremap <silent> <A-del> <C-o>"_dw
    inoremap <silent> <C-del> <C-o>"_dw
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
local nvim_lsp_configs = require('lspconfig.configs')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  -- buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  -- buf_set_keymap('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- buf_set_keymap('n', 'cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '{', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', '}', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  -- if client.resolved_capabilities.document_formatting then
  --   buf_set_keymap("i", "<c-g>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  -- elseif client.resolved_capabilities.document_range_formatting then
  --   buf_set_keymap("v", "<c-g>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  -- end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_exec([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  -- if client.resolved_capabilities.signature_help then
  --   vim.api.nvim_exec([[
  --     augroup lsp_signature_help
  --       autocmd!
  --       autocmd CursorHold <buffer> lua vim.lsp.buf.signature_help()
  --     augroup END
  --   ]], false)
  -- end
end

--cfg = {
--  bind = true, -- This is mandatory, otherwise border config won't get registered.
--  floating_window_above_cur_line = true,
--  toggle_key = '<M-l>',
--  hint_enable = false,
--}
--require'lsp_signature'.setup(cfg)

local cmp = require'cmp'
local lspkind = require('lspkind')

cmp.setup({
  window = {
    completion = {
      --winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      col_offset = -3,
      side_padding = 0,
    },
  },
  experimental = {
    ghost_text = true,
  },
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 40 })(entry, vim_item)
      local strings = vim.split(kind.kind, "%s", { trimempty = true })
      kind.kind = " " .. strings[1] .. " "
      --kind.menu = "    (" .. strings[2] .. ")"

      return kind
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<PageUp>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<PageDown>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-z>'] = cmp.config.disable,
    ['<C-n>'] = cmp.config.disable,
    ['<C-p>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Esc>'] = cmp.mapping({
      i = cmp.mapping.abort(),
    }),
    ['<Left>'] = function(fallback)
      local cmp = require('cmp')
      if cmp.visible() then
        cmp.close()
      end
      fallback()
    end,
    ['<Right>'] = function(fallback)
      local cmp = require('cmp')
      if cmp.visible() then
        cmp.close()
      end
      fallback()
    end,
    ['<Up>'] = function(fallback)
      local cmp = require('cmp')
      if cmp.visible() then
        if cmp.core.view:get_selected_entry() then
          cmp.select_prev_item()
        else
          cmp.close()
        end
      else
        fallback()
      end
    end,
    ['<Down>'] = function(fallback)
      local cmp = require('cmp')
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
    { name = 'path' },
    { name = 'buffer' },
    { name = 'treesitter' },
    -- { name = 'rg' },
  }, {
    { name = 'spell' },
  })
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  })
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  callback = function()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
    if ok and stats and (stats.size > 999999) then
      vim.b.large_buf = true
      vim.cmd("syntax off")
      vim.opt_local.spell = false
    else
      vim.b.large_buf = false
    end
  end,
  group = aug,
  pattern = "*",
})

local function setup_lsp(server, opts)
  local conf = nvim_lsp[server]
  conf.setup(opts)
  local try_add = conf.manager.try_add
  conf.manager.try_add = function (bufnr)
    if not vim.b.large_buf then
      return try_add(bufnr)
    end
  end
end

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

${enabledNvimLsp}
EOF

lua <<EOF
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
    hijack_netrw_behavior = "disabled",
                          -- "open_default", -- netrw disabled, opening a directory opens neo-tree
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
EOF

lua <<EOF
local gl = require('galaxyline')
local colors = {
  bg = "#32302f",
  fg = "#d4be98",
  fg_alt = "#ddc7a1",
  yellow = "#d8a657",
  cyan = "#89b482",
  green = "#a9b665",
  orange = "#e78a4e",
  magenta = "#d3869b",
  blue = "#7daea3",
  red = "#ea6962",
  violet = "#a9a1e1",
}
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
                          [''] = colors.blue,V=colors.blue,
                          c = colors.magenta,no = colors.red,s = colors.orange,
                          S=colors.orange,[''] = colors.orange,
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
    highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color,colors.bg},
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

-- gls.left[7] = {
--   PerCent = {
--     provider = 'LinePercent',
--     separator = ' ',
--     separator_highlight = {'NONE',colors.bg},
--     highlight = {colors.fg,colors.bg,'bold'},
--   }
-- }

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

vim.opt.termguicolors = true

require("themer").setup({
  colorscheme = "gruvbox",
  remaps = {
    highlights = {
      gruvbox = {
        base = {
          LineNr = {
            fg = "#555555",
          },
        },
      },
    },
  },
})

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
    indicator = { style = 'icon', icon = '▎' },
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = true,
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
EOF


lua <<EOF
local previewers = require('telescope.previewers')

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > 10000 then
      opts.use_ft_detect = false
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
end

require("telescope").setup {
  defaults = {
    layout_strategy = 'vertical',
    layout_config = { vertical = { width = 0.9, preview_height = 0.75 } },
    wrap_results = true,
    scroll_strategy = 'limit',
    mappings = {
      i = {
        ['<esc>'] = require('telescope.actions').close,
        ['<PageDown>'] = require('telescope.actions').preview_scrolling_down,
        ['<PageUp>'] = require('telescope.actions').preview_scrolling_up,
      }
    },
    buffer_previewer_maker = new_maker,
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
require("telescope").load_extension("live_grep_args")
EOF

lua <<EOF
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
-- require("themer").setup({
--   colorscheme = "gruvbox",
-- })

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
EOF

lua <<EOF
require('smart-splits').ignored_buftypes = { 'NvimTree' }
require('smart-splits').ignored_filetypes = {
  'nofile',
  'quickfix',
  'prompt',
}
EOF

lua <<EOF
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(parser_install_dir)

require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = "all",
  auto_install = true,
  parser_install_dir = parser_install_dir,

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  -- ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    disable = function()
      return vim.b.large_buf
    end,

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

  matchup = {
    enable = false,
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

-- require'treesitter-context'.setup{
--     enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--     max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
--     patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
--         -- For all filetypes
--         -- Note that setting an entry here replaces all other patterns for this entry.
--         -- By setting the 'default' entry below, you can control which nodes you want to
--         -- appear in the context window.
--         -- default = {
--         --     'class',
--         --     'function',
--         --     'method',
--         --     -- 'for', -- These won't appear in the context
--         --     -- 'while',
--         --     -- 'if',
--         --     -- 'switch',
--         --     -- 'case',
--         -- },
--         -- Example for a specific filetype.
--         -- If a pattern is missing, *open a PR* so everyone can benefit.
--         --   rust = {
--         --       'impl_item',
--         --   },
--     },
--     exact_patterns = {
--         -- Example for a specific filetype with Lua patterns
--         -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
--         -- exactly match "impl_item" only)
--         -- rust = true,
--     },
--     -- [!] The options below are exposed but shouldn't require your attention,
--     --     you can safely ignore them.
--     zindex = 20, -- The Z-index of the context window
-- }
EOF

lua <<EOF
require("lspsaga").setup({
  symbol_in_winbar = {
    enable = false,
  },
})

-- require('image').setup {
--   min_padding = 5,
--   show_label = true,
--   render_using_dither = true,
-- }


-- require("colorizer").setup {
--   filetypes = { "*" },
--   user_default_options = {
--     RGB = true, -- #RGB hex codes
--     RRGGBB = true, -- #RRGGBB hex codes
--     names = false, -- "Name" codes like Blue or blue
--     RRGGBBAA = true, -- #RRGGBBAA hex codes
--     AARRGGBB = true, -- 0xAARRGGBB hex codes
--     rgb_fn = true, -- CSS rgb() and rgba() functions
--     hsl_fn = true, -- CSS hsl() and hsla() functions
--     css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
--     css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
--     -- Available modes for `mode`: foreground, background,  virtualtext
--     mode = "background", -- Set the display mode.
--     virtualtext = "■",
--   },
--   -- all the sub-options of filetypes apply to buftypes
--   buftypes = {},
-- }

-- require("nvim-surround").setup({})

vim.diagnostic.config({ update_in_insert = true, })

-- local null_ls = require("null-ls")
-- null_ls.setup({
--     border = nil,
--     cmd = { "${variables.homeDir}/bin/nvim" },
--     debounce = 250,
--     debug = false,
--     default_timeout = 5000,
--     diagnostic_config = nil,
--     diagnostics_format = "#{m}",
--     fallback_severity = vim.diagnostic.severity.ERROR,
--     log_level = "warn",
--     notify_format = "[null-ls] %s",
--     on_attach = nil,
--     on_init = nil,
--     on_exit = nil,
--     root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".git"),
--     should_attach = nil,
--     temp_dir = nil,
--     update_in_insert = true,
--     sources = {
--       null_ls.builtins.diagnostics.deadnix.with({ command = "''${pkgs.deadnix}/bin/deadnix", }),
--       null_ls.builtins.diagnostics.statix.with({ command = "''${pkgs.statix}/bin/statix", }),
--     },
-- })

require("luasnip.loaders.from_vscode").lazy_load()


local previewers = require('telescope.previewers')
local builtin = require('telescope.builtin')

local delta = previewers.new_termopen_previewer {
  get_command = function(entry)
    return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!', '--', entry.current_file }
  end
}

my_git_bcommits = function(opts)
  opts = opts or {}
  opts.previewer = delta

  builtin.git_bcommits(opts)
end

my_git_commits = function(opts)
  opts = opts or {}
  opts.previewer = delta

  builtin.git_commits(opts)
end

vim.api.nvim_set_keymap("i", "<C-S-b>", "<cmd>:lua my_git_bcommits()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<C-S-c>", "<cmd>:lua my_git_commits()<CR>", {noremap = true, silent = true})

EOF

    highlight! CmpItemMenu guifg=pink gui=italic

    " gray
    highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
    " blue
    highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6 gui=bold
    highlight! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch
    " light blue
    highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
    highlight! link CmpItemKindInterface CmpItemKindVariable
    highlight! link CmpItemKindText CmpItemKindVariable
    " pink
    highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
    highlight! link CmpItemKindMethod CmpItemKindFunction
    " front
    highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
    highlight! link CmpItemKindProperty CmpItemKindKeyword
    highlight! link CmpItemKindUnit CmpItemKindKeyword


    " au VimEnter * lua _G.self_color_gruvbox_dark()

    " inoremap <silent> <c-g>h <Cmd>:Lspsaga lsp_finder<CR>
    inoremap <silent> <c-g>a <Cmd>:Lspsaga code_action<CR>
    inoremap <silent> <c-g>k <Cmd>:Lspsaga hover_doc<CR>
    inoremap <silent> <c-g>s <Cmd>:Lspsaga signature_help<CR>
    inoremap <silent> <c-g>r <Cmd>:Lspsaga rename<CR>
    "inoremap <silent> <c-g>d <Cmd>:Lspsaga preview_definition<CR>
    "inoremap <silent> <c-g>g <Cmd>:Lspsaga show_line_diagnostics<CR>
    "inoremap <silent> <c-g>] <Cmd>:Lspsaga diagnostic_jump_next<CR>
    "inoremap <silent> <c-g>[ <Cmd>:Lspsaga diagnostic_jump_prev<CR>
    "inoremap <silent> <c-`> <Cmd>:Lspsaga open_floaterm<CR>
    "tnoremap <silent> <c-`> <C-\><C-n>:Lspsaga close_floaterm<CR>

    inoremap <silent> <c-g>f <cmd>:lua vim.lsp.buf.format{ async = true }<CR>
    vnoremap <silent> <c-g>f <cmd>:lua vim.lsp.buf.format{ async = true }<CR>

    inoremap <c-g>d <Cmd>:lua require'telescope.builtin'.lsp_definitions{}<cr>
    inoremap <c-g>D <Cmd>:lua require'telescope.builtin'.lsp_implementations{}<cr>
    inoremap <c-g>g <Cmd>:lua require'telescope.builtin'.diagnostics{ bufnr = 0 }<cr>
    "nnoremap gr :lua require'telescope.builtin'.lsp_references{}<cr>
    "nnoremap ca :lua require'telescope.builtin'.lsp_code_actions{}<cr>
    "vnoremap ca :lua require'telescope.builtin'.lsp_range_code_actions{}<cr>

    inoremap <C-S-p> <Cmd>lua require'telescope.builtin'.keymaps{}<cr>

    nnoremap <C-S-f> <Cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>
    inoremap <C-S-f> <Cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>
    vnoremap <C-S-f> <Cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>

    nnoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>
    vnoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>
    inoremap <C-p> <Cmd>lua require('telescope').extensions.frecency.frecency()<cr>

    " nnoremap <C-g> :<C-u>call gitblame#echo()<CR>
    inoremap <C-S-g> <C-o>:call gitblame#echo()<CR>


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
    " inoremap <silent> <c-c> <C-o>:startinsert<cr>

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

    tnoremap <silent> <C-l> <C-\><C-n>
    tnoremap <C-v> <C-\><C-N>"+pi
    tnoremap <C-S-v> <C-\><C-N>"+pi
    tnoremap <silent> <a-left> <C-left>
    tnoremap <silent> <a-right> <C-right>

    nnoremap <silent> <C-S-T> :edit term://${variables.vimShell or "zsh"}<cr>
    inoremap <silent> <C-S-T> <C-o>:edit term://${variables.vimShell or "zsh"}<cr>
    tnoremap <silent> <C-S-T> <C-\><C-N>:edit term://${variables.vimShell or "zsh"}<cr>
    " let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

    cnoremap <C-v> <C-r>+

    let g:NERDDefaultAlign = 'left'

    nnoremap <C-o> :Neotree toggle reveal<CR>
    tnoremap <C-o> <C-\><C-N>:Neotree toggle reveal<CR>
    inoremap <C-o> <Cmd>Neotree toggle reveal<CR>
    " nnoremap <C-o> :NvimTreeToggle<CR>:NvimTreeRefresh<CR>
    " inoremap <C-o> <esc>:NvimTreeToggle<CR>:NvimTreeRefresh<CR>
    " nnoremap <leader>r :NvimTreeRefresh<CR>
    " nnoremap <leader>n :NvimTreeFindFile<CR>
    " NvimTreeOpen and NvimTreeClose are also available if you need them

    " let g:fakeclip_provide_clipboard_key_mappings = !empty($WAYLAND_DISPLAY)

    au BufNewFile,BufRead *.robot setlocal filetype=robot

    au BufNewFile,BufRead *Jenkinsfile* setlocal filetype=groovy

    " let g:gitblame_date_format = '%r'
    " let g:blamer_enabled = 1
    " let g:blamer_show_in_visual_modes = 0
    " let g:blamer_show_in_insert_modes = 0
    " let g:blamer_relative_time = 1
    " let g:blamer_template = '<committer> • <committer-time> • <summary>'

    set splitbelow
    set splitright
    inoremap <silent> <A-h> <Cmd>:sp<cr>
    inoremap <silent> <A-v> <Cmd>:vsp<cr>
    inoremap <silent> <A-w> <Cmd>:close<cr>
    " nnoremap <A-Down> <C-W><C-J>
    " nnoremap <A-Up> <C-W><C-K>
    " nnoremap <A-Right> <C-W><C-L>
    " nnoremap <A-Left> <C-W><C-H>

    inoremap <A-Left> <Cmd>:lua require('smart-splits').move_cursor_left()<CR>
    inoremap <A-Down> <Cmd>:lua require('smart-splits').move_cursor_down()<CR>
    inoremap <A-Up> <Cmd>:lua require('smart-splits').move_cursor_up()<CR>
    inoremap <A-Right> <Cmd>:lua require('smart-splits').move_cursor_right()<CR>

    set redrawtime=3000

    set re=0

    hi BlackBg guibg=black

    augroup term
      au!
      au TermOpen * :setlocal winhighlight=Normal:BlackBg
      au TermOpen * :setlocal nonumber
      au TermOpen * :setlocal nocursorline
      au TermOpen * :setlocal signcolumn=no
      au TermOpen * :nnoremap <buffer><cr> i
    augroup END

    function! TerminalOptions()
      silent! au BufEnter <buffer> startinsert!
      silent! au BufLeave <buffer> stopinsert!
    endfunction
    au TermOpen * call TerminalOptions()

    highlight CursorLine guibg=Grey22
    highlight GalaxyLineFillSection guibg=#32302f

    highlight SignifySignAdd    ctermfg=green  guifg=#00ff00 cterm=NONE gui=NONE
    highlight SignifySignDelete ctermfg=red    guifg=#ff0000 cterm=NONE gui=NONE
    highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE

    nnoremap <C-S-h> :SignifyHunkDiff<cr>
    inoremap <C-S-h> <C-o>:SignifyHunkDiff<cr>
    inoremap <C-S-u> <C-o>:SignifyHunkUndo<cr>

    inoremap <C-S-}> <cmd>:call sy#jump#next_hunk(1)<cr>
    inoremap <C-S-{> <cmd>:call sy#jump#prev_hunk(1)<cr>

    autocmd User SignifyHunk call s:show_current_hunk()

    function! s:show_current_hunk() abort
      let h = sy#util#get_hunk_stats()
      if !empty(h)
        echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
      endif
    endfunction

    nnoremap <silent> <C-L> :noh<cr>i

    let g:novim_mode_use_editor_fixes = 0
    let g:novim_mode_use_pane_controls = 0
    let g:novim_mode_use_general_app_shortcuts = 0
    let g:novim_mode_use_copypasting = 0
    let g:novim_mode_use_undoing = 0

    inoremap <silent> <M-Left>  <C-O><C-W><Left>
    snoremap <silent> <M-Left>  <Esc><C-W><Left>
    nnoremap <silent> <M-Left>  <C-W><Left>
    inoremap <silent> <M-Down>  <C-O><C-W><Down>
    snoremap <silent> <M-Down>  <Esc><C-W><Down>
    nnoremap <silent> <M-Down>  <C-W><Down>
    inoremap <silent> <M-Up>    <C-O><C-W><Up>
    snoremap <silent> <M-Up>    <Esc><C-W><Up>
    nnoremap <silent> <M-Up>    <C-W><Up>
    inoremap <silent> <M-Right> <C-O><C-W><Right>
    snoremap <silent> <M-Right> <Esc><C-W><Right>
    nnoremap <silent> <M-Right> <C-W><Right>

    inoremap <silent> <C-W> <C-O>:bd<CR>
    nnoremap <silent> <C-W> :bd<CR>

    inoremap <C-Q> <C-O>:qall
    snoremap <C-Q> <C-O>:qall
    nnoremap <C-Q> :qall
    tnoremap <C-Q> <C-\><C-N>:qall
    cnoremap <C-Q> <C-C><C-O>:qall

    inoremap <silent> <C-S> <C-o>:w<CR><C-o>:update<CR>
    nnoremap <silent> <C-S> :w<CR>:update<CR>i

    inoremap <M-;> <C-O>:
    snoremap <M-;> <C-O>:
    inoremap <M-c> <C-O>:
    snoremap <M-c> <C-O>:
    nnoremap <M-;> :
    nnoremap <M-c> :

    inoremap <M-o> <C-O>
    snoremap <M-o> <C-O>

    "inoremap <C-V> <C-O>:call novim_mode#Paste()<CR>
    " The odd <Space><Backspace> here is because one-off Normal Mode commands
    " don't seem to work as expected when some text is selected. Also just
    " using <Backspace> on its own seems to cause weird behaviour too.
    "snoremap <C-V> <Space><Backspace><C-O>:call novim_mode#Paste()<CR>
    "cnoremap <C-V> <C-R>"
    "snoremap <C-C> <C-O>"+ygv
    "snoremap <C-X> <C-O>"+xi

    " Use <M-o><C-Z> for native terminal backgrounding.
    " The <Esc>s used in the `snoremap` commands seem to prevent the selection
    " process itself being put in the undo history - so now the undo actually undoes
    " the last *text* activity.
    inoremap <silent> <C-Z> <C-O>u
    snoremap <silent> <C-Z> <Esc><C-O>u
    vnoremap <silent> <C-Z> <Esc><C-O>u
    " Redo
    inoremap <silent> <C-Y> <C-O><C-R>
    snoremap <silent> <C-Y> <Esc><C-O><C-R>
    vnoremap <silent> <C-Y> <Esc><C-O><C-R>

    " inoremap <silent> <S-Left> <C-O>:call novim_mode#EnterSelectionMode('left')<CR>
    " inoremap <silent> <S-Right> <C-O>:call novim_mode#EnterSelectionMode('right')<CR>
    " inoremap <silent> <S-Up> <C-O>:call novim_mode#EnterSelectionMode('up')<CR>
    " inoremap <silent> <S-Down> <C-O>:call novim_mode#EnterSelectionMode('down')<CR>
    " inoremap <silent> <S-Home> <C-O>:call novim_mode#EnterSelectionMode('home')<CR>
    " inoremap <silent> <S-End> <C-O>:call novim_mode#EnterSelectionMode('end')<CR>

    " CTRL-A for selecting all text
    " inoremap <silent> <C-a> <C-O>:call novim_mode#EnterSelectionMode('all')<CR>
    " snoremap <C-a> <C-O><C-C>gggH<C-O>G

    set wildcharm=<C-Z>
    cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
    cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
    cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

    inoremap <C-S-o> <Cmd>:Lexplore<cr>
    nnoremap <C-S-o> <Cmd>:Lexplore<cr>

    function! NetrwMapping()
        " noremap <buffer> <C-l> <C-W>l
        " noremap <buffer> <C-h> <C-W>h

        " let g:netrw_banner = 0 " remove the banner at the top
        let g:netrw_liststyle = 3  " default directory view. Cycle with i
        let g:netrw_browse_split = 4
        let g:netrw_altv = 1
        let g:netrw_sort_sequence = '[\/]$,*'

        let g:netrw_list_hide= '.*.swp$,
                \ *.pyc$,
                \ *.log$,
                \ *.o$,
                \ *.xmi$,
                \ *.swp$,
                \ *.bak$,
                \ *.pyc$,
                \ *.class$,
                \ *.jar$,
                \ *.war$,
                \ *__pycache__*'

    endfunction

    augroup netrw_mapping
        autocmd!
        autocmd filetype netrw call NetrwMapping()
    augroup END

    augroup AutoDeleteNetrwHiddenBuffers
      au!
      au FileType netrw setlocal bufhidden=wipe
    augroup end

    " let g:previm_custom_preview_base_dir = "${variables.homeDir}/.previm"
    au FileType plantuml let g:plantuml_previewer#plantuml_jar_path = "${pkgs.plantuml}/lib/plantuml.jar"
    let g:plantuml_previewer#viewer_path = "${variables.homeDir}/.plantuml-previewer-vim"
    let g:plantuml_previewer#debug_mode = 1

    " augroup matchup_matchparen_highlight
    "   autocmd!
    "   autocmd ColorScheme * hi MatchParen guifg=Gray40
    "   autocmd ColorScheme * hi MatchWord cterm=underline gui=underline
    " augroup END
    " inoremap <C-S-m> <C-o><plug>(matchup-g%)
    " let g:matchup_matchparen_deferred = 1
    " let g:matchup_matchparen_deferred_show_delay = 200
    " let g:matchup_matchparen_deferred_hide_delay = 600

    " augroup large_file_support
    "   autocmd!
    "   autocmd CursorHoldI if getfsize(expand(@%)) > 1000000 | setlocal syntax=off | endif
    "   autocmd CursorHoldI if getfsize(expand(@%)) > 1000000 | lua require'cmp'.setup.buffer { enabled = false } | endif
    " augroup END

    autocmd BufRead xml setlocal syntax=on

    " highlight LineTooLongMarker guibg=Gray26
    " call matchadd('LineTooLongMarker', '\%81v', 100)

    autocmd UIEnter * source ${ginitVim}

    function! SetColumnToStart()
lua << EOF
local r, c = unpack(vim.api.nvim_win_get_cursor(0))
vim.api.nvim_win_set_cursor(0, {r, 0})
EOF
    endfunction

    " autocmd SessionLoadPost * call SetColumnToStart()
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
          # vim-jsbeautify
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
          #vimPlugins.vim-hashicorp-tools
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
          #vimPlugins.lsp_signature-nvim
          vimPlugins.git-blame-vim
          vimPlugins.nvim-web-devicons
          #nvim-tree-lua
          vimPlugins.vim-fakeclip
          #vim-matchup
          #vimPlugins.nvim-surround
          #nvim-compe
          plenary-nvim
          telescope-nvim
          vimPlugins.bufferline-nvim
          vimPlugins.galaxyline-nvim
          vimPlugins.lush-nvim
          #vimPlugins.gruvbox-nvim
          #vim-mundo
          undotree
          telescope-fzy-native-nvim
          vimPlugins.nvim-cmp
          vimPlugins.cmp-buffer
          vimPlugins.cmp-nvim-lsp
          #vimPlugins.cmp-vsnip
          vimPlugins.cmp_luasnip
          vimPlugins.cmp-path
          vimPlugins.cmp-cmdline
          vimPlugins.cmp-spell
          vimPlugins.cmp-nvim-lsp-signature-help
          vimPlugins.cmp-rg
          vimPlugins.cmp-treesitter
          vimPlugins.nvim-hlslens
          vimPlugins.nvim-scrollbar
          vimPlugins.themer-lua
          #vimPlugins.vim-vsnip
          vimPlugins.friendly-snippets
          nui-nvim
          #vimPlugins.nvim-regexplainer
          vimPlugins.smart-splits-nvim
          vimPlugins.neo-tree-nvim
          vimPlugins.nvim-treesitter
          vimPlugins.nvim-treesitter-textobjects
          vimPlugins.neovim-session-manager
          telescope-frecency-nvim
          #vimPlugins.nvim-treesitter-context
          vimPlugins.novim-mode
          vimPlugins.lspsaga-nvim
          #vimPlugins.previm
          plantuml-syntax
          vimPlugins.plantuml-previewer-vim
          open-browser-vim
          #vimPlugins.nvim-colorizer-lua
          #vimPlugins.noice-nvim
          #vimPlugins.nvim-notify
          #vimPlugins.null-ls-nvim
          vimPlugins.LuaSnip
          vimPlugins.lspkind-nvim
          telescope-live-grep-args-nvim
          vimPlugins.vim-jinja2-syntax
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
  '';
} {
  target = "${variables.homeDir}/bin/nvim";
  source = "${neovim}/bin/nvim";
  #source = pkgs.writeScript "nvim" ''
  #  #!${pkgs.stdenv.shell}
  #  export PATH="${lib.makeBinPath [
  #    pkgs.stdenv.cc
  #    pkgs.python3Packages.python
  #    pkgs.perl
  #    pkgs.nodejs
  #    pkgs.gnugrep
  #    pkgs.python3Packages.yamllint
  #    pkgs.ripgrep
  #    pkgs.sshpass
  #    pkgs.openssh
  #    pkgs.jdk11
  #    pkgs.graphviz
  #    pkgs.python3Packages.docutils
  #    pkgs.shellcheck
  #  ]}:$PATH"
  #  export CC="${pkgs.stdenv.cc}/bin/cc"
  #  export LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.stdenv.cc.libc}/lib:$LIBRARY_PATH"
  #  ${neovim}/bin/nvim "$@"
  #'';
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
