{ variables, config, pkgs, lib }:

let
  nodeGlobalBinPath = "${variables.homeDir}/.npm-packages/bin";
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vimPlugins {
    llvmPackages = pkgs.llvmPackages_6;
  });

  neovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        call plug#begin('${variables.homeDir}/.local/share/nvim/plugged')
        Plug 'sheerun/vim-polyglot'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-commentary'
        Plug 'spwhitt/vim-nix'
        Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
        call plug#end()

        let g:vscode_extensions = [
          \'vscode.typescript-language-features',
          \'vscode.json-language-features',
          \'vscode.css-language-features',
          \'vscode.markdown-language-features',
          \'vscode.html-language-features',
          \'vscode.php-language-features',
          \'ms-python.python'
        \]

        " multiple nvim instances
        nno <silent> <c-t>c :Veonim vim-create<cr>
        nno <silent> <c-g> :Veonim vim-switch<cr>
        nno <silent> <c-t>, :Veonim vim-rename<cr>

        " workspace functions
        nno <silent> ,f :Veonim files<cr>
        nno <silent> ,e :Veonim explorer<cr>
        nno <silent> ,b :Veonim buffers<cr>
        "or with a starting dir: nno <silent> ,d :Veonim change-dir ~/proj<cr>

        " searching text
        vno <silent> <C-f> :Veonim grep-selection<cr>
        nno <silent> <C-f> :Veonim grep<cr>
        nno <silent> / :Veonim buffer-search<cr>

        " language features
        nno <silent> sr :Veonim rename<cr>
        nno <silent> sd :Veonim definition<cr>
        nno <silent> si :Veonim implementation<cr>
        nno <silent> st :Veonim type-definition<cr>
        nno <silent> sf :Veonim references<cr>
        nno <silent> sh :Veonim hover<cr>
        nno <silent> sl :Veonim symbols<cr>
        nno <silent> so :Veonim workspace-symbols<cr>
        nno <silent> sq :Veonim code-action<cr>
        nno <silent> sk :Veonim highlight<cr>
        nno <silent> sK :Veonim highlight-clear<cr>
        nno <silent> ,n :Veonim next-usage<cr>
        nno <silent> ,p :Veonim prev-usage<cr>
        nno <silent> sp :Veonim show-problem<cr>
        nno <silent> <c-n> :Veonim next-problem<cr>
        nno <silent> <c-p> :Veonim prev-problem<cr>


        set guifont=Source\ Code\ Pro:h16
        set linespace=10
        set termguicolors
        set cursorline
        set number

        nno <silent> <c-p> :call Veonim('files')<cr>
        nno <silent> <c-o> :call Veonim('vim-create', '${variables.homeDir}/workarea')<cr>
        nno <silent> <c-0> :call Veonim('vim-switch')<cr>
        nno <silent> <c-n> :Vexplore<cr>
        nno <silent> <c-m> :messages<cr>
        nno <silent> <c-q> :qall<cr>
        nno <silent> <c-w> :bd<cr>
        nno <silent> <c-s> :w<CR>
        nno <silent> <c-PageUp> :bprev<cr>
        nno <silent> <c-PageDown> :bnext<cr>
        nno <silent> <cr> o
        nno <silent> <c-z> u
        nno <silent> <c-s-z> <c-r>
        nno <silent> <c-y> <c-r>

        nno <PageUp> 10<up>
        nno <PageDown> 10<down>
        vno <PageUp> 10<up>
        vno <PageDown> 10<down>
        vno <S-PageUp> 10<up>
        vno <S-PageDown> 10<down>
        nno <S-PageUp> v10<up>
        nno <S-PageDown> v10<down>
        nno <S-Down> vj
        nno <S-Up> vk
        nno <S-Left> vh
        nno <S-Right> vl
        vno <S-Down> j
        vno <S-Up> k
        vno <S-Left> h
        vno <S-Right> l
        nno <C-S-Right> vw
        nno <C-S-Left> hvb
      '';
      packages.myVimPackage = with pkgs.vimPlugins; with vimPlugins; {
        start = [
          vim-plug
        ];
        opt = [ ];
      };
    };
  };

  veonim = pkgs.writeScriptBin "veonim" ''
    #!${pkgs.stdenv.shell}
    env PATH="${neovim}/bin:${pkgs.coreutils}/bin:$PATH" ${pkgs.veonim}/bin/veonim
  '';
in [{
  target = "${variables.homeDir}/bin/veonim";
  source = "${veonim}/bin/veonim";
}]
