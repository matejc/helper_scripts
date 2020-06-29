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

    "if exists('g:GuiLoaded')
      au VimEnter * GuiPopupmenu 0
      "au VimEnter * call GuiClipboard()
      set guifont=${lib.escape [" "] "${variables.font.family}:h${variables.font.size}"}
      set termguicolors
    "endif

    colorscheme solarized8_high
    set background=light

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

    autocmd FileType * set spell spelllang=en_us

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=1
    let g:strip_whitespace_confirm=0

    if has("persistent_undo")
      set undodir=~/.undodir/
      set undofile
    endif

    set ai
    " set smartindent
    set nocopyindent
    set tabstop=4 shiftwidth=4 expandtab softtabstop=4
    set nowrap

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

    nmap <C-S-Up> :copy .-1<cr>
    vmap <C-S-Up> :copy '>-1<cr>
    imap <C-S-Up> <esc>:copy .-1<cr>i

    nmap <C-S-Down> :copy .<cr>
    vmap <C-S-Down> :copy '><cr>
    imap <C-S-Down> <esc>:copy .<cr>i
    nmap <C-S-d> :copy .<cr>
    vmap <C-S-d> :copy '><cr>
    imap <C-S-d> <esc>:copy .<cr>i
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

    nmap <DEL> "_x

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
        call ctrlsf#StopSearch()
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
    let g:ctrlp_user_command = ['.git', 'cd %s && ${pkgs.git}/bin/git ls-files . -co --exclude-standard', '${pkgs.findutils}/bin/find %s -type f']

    imap <C-p> <esc>:CtrlPMixed<Return>

    let g:gitgutter_git_executable = '${pkgs.git}/bin/git'

    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 0
    let g:airline_theme='solarized'

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

    nmap <c-/> <leader>c<space>
    imap <c-/> <esc><leader>c<space>
    vmap <c-/> <leader>c<space>

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

lua << EOF
package.path = '${vimPlugins.nvim-lsp.rtp}/lua/?.lua;' .. package.path

vim.cmd('packadd nvim-lsp')
local nvim_lsp = require'nvim_lsp'

nvim_lsp.pyls.setup{}
nvim_lsp.tsserver.setup{}

local configs = require'nvim_lsp/configs'
-- Check if it's already defined for when I reload this file.
-- if not nvim_lsp.omnisharp then
--   configs.omnisharp = {
--     default_config = {
--       cmd = {'omnisharp', '-lsp'};
--       filetypes = {'cs'};
--       root_dir = function(fname)
--         return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
--       end;
--       log_level = vim.lsp.protocol.MessageType.Warning;
--       settings = {};
--     };
--   }
-- end
-- nvim_lsp.omnisharp.setup{}
if not nvim_lsp.hie then
  configs.hie = {
    default_config = {
      cmd = {'hie-wrapper', '--lsp'};
      filetypes = {'haskell'};
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      log_level = vim.lsp.protocol.MessageType.Warning;
      settings = {};
    };
  }
end
nvim_lsp.hie.setup{}
-- if not nvim_lsp.robot then
--   configs.robot = {
--     default_config = {
--       cmd = {'robotframework_ls'};
--       filetypes = {'robot'};
--       root_dir = function(fname)
--         return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
--       end;
--       log_level = vim.lsp.protocol.MessageType.Warning;
--       settings = { };
--     };
--   }
-- end
-- nvim_lsp.robot.setup{}
EOF

    autocmd BufEnter * setlocal omnifunc=v:lua.vim.lsp.omnifunc

    " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
    " found' messages
    set shortmess+=c

    " CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
    inoremap <c-c> <ESC>

    imap <expr> <Esc>      pumvisible() ? "\<C-y>" : "\<Esc>"
    imap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
    imap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    imap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
    imap <expr> <C-Right>  pumvisible() ? "\<Right>" : "\<C-Right>"
    imap <expr> <C-Left>   pumvisible() ? "\<Left>" : "\<C-Left>"
    imap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
    imap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

    " Use <TAB> to select the popup menu:
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

    let g:ale_completion_enabled = 0
    let g:ale_linters = {
      \   'cs': [],
      \}

    let g:OmniSharp_server_stdio = 1
    let g:OmniSharp_server_path = 'omnisharp'

    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    let g:airline#extensions#tabline#enabled = 1

    set ssop="buffers,curdir,tabpages"

    source ${sha1Vim}/plugin/sha1.vim

    function! SessionPath()
      return "${variables.homeDir}/.vim-sessions/Session-" . sha1#sha1( getcwd() ) . ".vim"
    endfunction

    autocmd VimLeave * nested if (!isdirectory("${variables.homeDir}/.vim-sessions")) |
        \ call mkdir("${variables.homeDir}/.vim-sessions") |
        \ endif |
        \ execute "mksession! " . SessionPath()

    autocmd VimEnter * nested if argc() == 0 && filereadable(SessionPath()) |
        \ execute "source " . SessionPath()
 '';

  neovim-unwrapped = pkgs.neovim-unwrapped.overrideDerivation (old: {
    name = "neovim-unwrapped-0.5.0";
    version = "0.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "87d892afa0475644e91d9c8a57b7c35491c4dc32";
      sha256 = "03f9nb2hqmmpxvzxs7lm5kdwivs27cgp53k3h0w7sp1cp3a23gm9";
    };
    buildInputs = old.buildInputs ++ [ pkgs.utf8proc ];
  });

  neovim = (pkgs.wrapNeovim neovim-unwrapped { }).override {
    configure = {
      inherit customRC;
      packages.myVimPackage = with pkgs.vimPlugins; with vimPlugins; {
        start = [
          awesome-vim-colorschemes
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
          nerdcommenter
          ale
          YouCompleteMe
          omnisharp-vim
          ctrlp-py-matcher
          robotframework-vim
          sleuth
          vim-hashicorp-tools
          Jenkinsfile-vim-syntax
          neovim-gui-shim
        ];
        opt = [ nvim-lsp ];
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
      yaml-language-server
  '';
} {
  target = "${variables.homeDir}/bin/nvim";
  source = pkgs.writeScript "nvim" ''
    #!${pkgs.stdenv.shell}
    ${neovim}/bin/nvim "$@"
  '';
} {
  target = "${variables.homeDir}/bin/guinvim";
  source = pkgs.writeScript "guinvim.sh" ''
    #!${pkgs.stdenv.shell}
    set -xe
    export PWDHASH="$(${pkgs.coreutils}/bin/pwd | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.gawk}/bin/awk '{printf $1}')"
    export SOCK_PREFIX="''${SOCK_PREFIX:-/tmp}"
    export NVIM_SOCKET="$SOCK_PREFIX/$PWDHASH.sock"
    { sleep 2; ''${NVIM_QT_PATH} --server "$NVIM_SOCKET"; } &
    ${neovim}/bin/nvim --listen "$NVIM_SOCKET" --headless "''${@:2}"
  '';
} {
  target = "${variables.homeDir}/bin/q";
  source = pkgs.writeScript "open-nvim" ''
    #!${pkgs.stdenv.shell}
    function open_nvim_qt {
      export PATH="${lib.makeBinPath [ pkgs.python3Packages.python pkgs.python3Packages.python-language-server /* pkgs.python2Packages.robotframework-lsp omnisharp-roslyn hie */ pkgs.nodejs pkgs.gnugrep pkgs.python3Packages.yamllint ]}:${variables.homeDir}/.npm-packages/bin:$PATH"
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
