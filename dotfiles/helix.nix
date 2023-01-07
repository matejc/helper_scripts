{ variables, config, pkgs, lib }:
let
  groovyls = pkgs.runCommand "groovy-language-server" {
    src = builtins.fetchurl {
      url = "https://github.com/Moonshine-IDE/Moonshine-IDE/raw/216aa139620d50995a14827e949825c522bd85e5/ide/MoonshineSharedCore/src/elements/groovy-language-server/groovy-language-server-all.jar";
      sha256 = "sha256:1iq8c904xsyv7gf4i703g7kb114kyq6cg9gf1hr1fzvy7fpjw0im";
    };
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/{bin,share/groovy-language-server}/
    ln -s $src $out/share/groovy-language-server/groovy-language-server-all.jar
    makeWrapper ${pkgs.jre}/bin/java $out/bin/groovy-language-server \
      --argv0 crowdin \
      --add-flags "-jar $out/share/groovy-language-server/groovy-language-server-all.jar"
  '';

  lemminx = pkgs.stdenv.mkDerivation rec {
    name = "lemminx";
    version = "0.19.2-655";
    # https://github.com/redhat-developer/vscode-xml/blob/master/package.json
    src = builtins.fetchurl {
      url = "https://download.jboss.org/jbosstools/vscode/snapshots/lemminx-binary/${version}/lemminx-linux.zip";
      sha256 = "sha256:05f6fzqg8wzki1d12v5kqx2w5xqhp955x8klxqh055a1x3sgg4jf";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    phases = "unpackPhase installPhase";
    unpackPhase = ''
      unzip $src -d .
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp lemminx-linux $out/bin/lemminx
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/bin/lemminx
    '';
  };

  ltex-ls = pkgs.runCommand "ltex-ls" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.vscode-extensions.valentjn.vscode-ltex}/share/vscode/extensions/valentjn.vscode-ltex/lib/ltex-ls-*/bin/ltex-ls $out/bin/ltex-ls \
      --prefix JAVACMD : ${pkgs.jre}/bin/java
  '';

  path = with pkgs; lib.makeBinPath [
    stdenv.cc.cc binutils wl-clipboard
    nil nodePackages_latest.yaml-language-server nodePackages_latest.bash-language-server
    terraform-ls python3Packages.python-lsp-server python3Packages.python
    python3Packages.pycodestyle
    nodePackages_latest.typescript-language-server nodePackages_latest.typescript nodejs
    nodePackages_latest.vscode-json-languageserver
  ];
in
[{
  target = "${variables.homeDir}/.config/helix/languages.toml";
  source = pkgs.writeScript "hx-languages.toml" ''
    [[language]]
    name = "groovy"
    scope = "source.groovy"
    injection-regex = "groovy"
    file-types = ["Jenkinsfile", "groovy"]
    shebangs = ["groovy"]
    roots = []
    comment-token = "//"
    language-server = { command = "${groovyls}/bin/groovy-language-server" }
    indent = { tab-width = 2, unit = "  " }
    grammar = "groovy"

    [[grammar]]
    name = "groovy"
    source = { git = "https://github.com/codieboomboom/tree-sitter-groovy", rev = "de8e0c727a0de8cbc6f4e4884cba2d4e7c740570" }

    [[language]]
    name = "xml"
    scope = "source.xml"
    injection-regex = "xml"
    file-types = ["xml"]
    indent = { tab-width = 2, unit = "  " }
    roots = []
    language-server = { command = "${lemminx}/bin/lemminx" }

    [[language]]
    name = "javascript"
    config = { tsserver = { path = "${pkgs.nodePackages_latest.typescript}/bin/tsserver" } }

    [[language]]
    name = "typescript"
    config = { tsserver = { path = "${pkgs.nodePackages_latest.typescript}/bin/tsserver" } }

    [[language]]
    name = "python"
    config = { pylsp = { configurationSources = ["pycodestyle", "flake8"], plugins = { pycodestyle = { enabled = true }, flake8 = { enabled = true, executable = "${pkgs.python3Packages.flake8}/bin/flake8" } } } }

    [[language]]
    name = "latex"
    scope = "source.tex"
    injection-regex = "md|markdown|latex|tex"
    file-types = ["md", "markdown", "tex", "txt"]
    roots = []
    language-server = { command = "${ltex-ls}/bin/ltex-ls" }
    indent = { tab-width = 2, unit = "  " }
  '';
} {
  target = "${variables.homeDir}/.config/helix/config.toml";
  source = pkgs.writeScript "hx-config.toml" ''
    theme = "gruvbox"

    [editor]
    line-number = "absolute"
    mouse = true
    bufferline = "multiple"
    cursorline = true

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.statusline]
    left = ["mode", "spinner"]
    center = ["file-name"]
    right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]
    separator = "│"
    mode.normal = "NORMAL"
    mode.insert = "INSERT"
    mode.select = "SELECT"

    [editor.whitespace.render]
    space = "none"
    tab = "all"
    newline = "none"

    [editor.whitespace.characters]
    nbsp = "⍽"
    tab = "→"

    [keys.normal]
    C-s = ":w"
    C-q = ":quit-all"
    C-S-w = ":bc"
    "ret" = "open_below"
    C-l = "insert_mode"
    C-o = "file_picker"
    C-p = "file_picker"
    C-f = "global_search"
    C-u = "undo"
    C-z = "undo"
    C-r = "redo"
    C-c = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "normal_mode" ]
    C-x = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "delete_selection", "normal_mode" ]
    C-v = ":clipboard-paste-before"
    pagedown = [ "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down" ]
    pageup = [ "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up" ]
    C-k = [ "goto_line_start", "kill_to_line_end" ]
    S-right = ":bnext"
    S-left = ":bprev"
    C-pagedown = ":bnext"
    C-pageup = ":bprev"
    A-v = ":vsplit-new"
    A-h = ":hsplit-new"
    A-c = ":bclose"
    A-up = "jump_view_up"
    A-down = "jump_view_down"
    A-left = "jump_view_left"
    A-right = "jump_view_right"
    A-S-up = "swap_view_up"
    A-S-down = "swap_view_down"
    A-S-left = "swap_view_left"
    A-S-right = "swap_view_right"
    C-home = "goto_file_start"
    C-end = "goto_last_line"

    [keys.insert]
    C-s = [ "normal_mode", ":w" ]
    C-l = "normal_mode"
    C-u = "undo"
    C-z = "undo"
    C-r = "redo"
    C-h = "toggle_comments"
    C-c = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "insert_mode" ]
    C-x = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "delete_selection", "insert_mode" ]
    C-v = ":clipboard-paste-before"
    pagedown = [ "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down" ]
    pageup = [ "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up" ]
    C-right = "move_next_word_end"
    C-left = "move_prev_word_start"
    C-k = [ "goto_line_start", "kill_to_line_end" ]

    [keys.select]
    del = "delete_selection_noyank"
    C-c = ":clipboard-yank"
    C-v = ":clipboard-paste-replace"
    C-u = "undo"
    C-z = "undo"
    C-r = "redo"
    C-k = "delete_selection_noyank"
    C-x = [ ":clipboard-yank", "delete_selection" ]
  '';
} {
  target = "${variables.homeDir}/bin/hx";
  source = pkgs.writeScript "hx-run.sh" ''
    #!${pkgs.stdenv.shell}
    set -e

    ln -sf "${pkgs.helix}/lib/runtime/queries" "${variables.homeDir}/.config/helix/"
    ln -sf "${pkgs.helix}/lib/runtime/themes" "${variables.homeDir}/.config/helix/"

    mkdir -p "${variables.homeDir}/.config/helix/grammars"
    ln -sf ${pkgs.helix}/lib/runtime/grammars/* "${variables.homeDir}/.config/helix/grammars/"

    export HELIX_RUNTIME="${variables.homeDir}/.config/helix"
    export PATH="${path}:$PATH"
    export LIBRARY_PATH="${pkgs.stdenv.cc.libc}/lib''${LIBRARY_PATH+:$LIBRARY_PATH}"

    exec ${pkgs.helix}/bin/.hx-wrapped $@
  '';
}]
