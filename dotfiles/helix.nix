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

  ltex-ls = pkgs.runCommand "ltex-ls" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.vscode-extensions.valentjn.vscode-ltex}/share/vscode/extensions/valentjn.vscode-ltex/lib/ltex-ls-*/bin/ltex-ls $out/bin/ltex-ls \
      --prefix JAVACMD : ${pkgs.jre}/bin/java
  '';

  json-languageserver = pkgs.writeScriptBin "vscode-json-language-server" ''
    #!${pkgs.stdenv.shell}
    exec ${pkgs.nodePackages_latest.vscode-langservers-extracted}/bin/vscode-json-language-server $@
  '';

  path = with pkgs; lib.makeBinPath [
    stdenv.cc.cc binutils wl-clipboard
    nil
    terraform-ls
    python3Packages.python-lsp-server python3Packages.python
    nodejs
    taplo
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
    language-servers = [ "groovy-language-server" ]
    indent = { tab-width = 2, unit = "  " }
    grammar = "groovy"

    [language-server.groovy-language-server]
    command = "${groovyls}/bin/groovy-language-server"

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
    language-servers = [ "lemminx" ]

    [language-server.lemminx]
    command = "${pkgs.lemminx}/bin/lemminx"

    [language-server.typescript-language-server]
    config = { tsserver = { path = "${pkgs.nodePackages_latest.typescript}/bin/tsserver" } }

    [language-server.pylsp]
    config = { pylsp = { configurationSources = ["pycodestyle", "flake8"], plugins = { pycodestyle = { enabled = true }, flake8 = { enabled = true, executable = "${pkgs.python3Packages.flake8}/bin/flake8" } } } }

    [[language]]
    name = "latex"
    scope = "source.tex"
    injection-regex = "md|markdown|latex|tex"
    file-types = ["md", "markdown", "tex", "txt"]
    roots = []
    language-servers = [ "ltex-ls" ]
    indent = { tab-width = 2, unit = "  " }

    [language-server.ltex-ls]
    command = "${ltex-ls}/bin/ltex-ls"

    [[language]]
    name = "yaml"
    scope = "source.yaml"
    file-types = ["yml", "yaml"]
    roots = []
    comment-token = "#"
    indent = { tab-width = 2, unit = "  " }
    language-servers = [ "yaml-language-server" ]
    injection-regex = "yml|yaml"

    [language-server.yaml-language-server]
    command = "yaml-language-server"
    args = ["--stdio"]
    config = { redhat = { telemetry = { enabled = false } }, yaml = { schemas = { "https://json.schemastore.org/github-workflow.json" = "/.github/workflows/*", "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/master-standalone-strict/all.json" = "/*k8s*" } } }

    [[language]]
    name = "robot"
    scope = "source.robot"
    injection-regex = "robot"
    file-types = ["robot"]
    roots = []
    language-servers = [ "robotframework_ls" ]
    indent = { tab-width = 4, unit = "    " }

    [language-server.robotframework_ls]
    command = "robotframework_ls"

    [[grammar]]
    name = "robot"
    source = { git = "https://github.com/Hubro/tree-sitter-robot", rev = "f1142bfaa6acfce95e25d2c6d18d218f4f533927" }

    [[language]]
    name = "nix"
    scope = "source.nix"
    injection-regex = "nix"
    file-types = ["nix"]
    shebangs = []
    comment-token = "#"
    language-servers = [ "nixd" ]
    indent = { tab-width = 2, unit = "  " }

    [[grammar]]
    name = "nix"
    source = { git = "https://github.com/nix-community/tree-sitter-nix", rev = "1b69cf1fa92366eefbe6863c184e5d2ece5f187d" }

    [language-server.nixd]
    command = "${pkgs.nixd}/bin/nixd"
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
    C-7 = "toggle_comments"
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
    C-7 = "toggle_comments"
    C-c = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "insert_mode" ]
    C-x = [ "goto_line_start", "select_mode", "goto_line_end", ":clipboard-yank", "delete_selection", "insert_mode" ]
    C-v = ":clipboard-paste-before"
    pagedown = [ "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down", "move_line_down" ]
    pageup = [ "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up", "move_line_up" ]
    C-right = "move_next_word_end"
    C-left = "move_prev_word_start"
    C-k = [ "goto_line_start", "kill_to_line_end" ]
    C-space = "completion"
    S-tab = "unindent"
    S-up = [ "select_mode", "extend_line_up" ]
    S-down = [ "select_mode", "extend_line_down" ]
    S-left = [ "select_mode", "extend_char_left" ]
    S-right = [ "select_mode", "extend_char_right" ]

    [keys.select]
    del = "delete_selection_noyank"
    C-c = ":clipboard-yank"
    C-v = ":clipboard-paste-replace"
    C-u = "undo"
    C-z = "undo"
    C-r = "redo"
    C-7 = "toggle_comments"
    C-k = "delete_selection_noyank"
    C-x = [ ":clipboard-yank", "delete_selection" ]
    tab = "indent"
    S-tab = "unindent"
    S-up = "extend_line_up"
    S-down = "extend_line_down"
    S-left = "extend_char_left"
    S-right = "extend_char_right"
  '';
} {
  target = "${variables.homeDir}/bin/hx";
  source = pkgs.writeScript "hx-run.sh" ''
    #!${pkgs.stdenv.shell}
    set -e

    mkdir -p "${variables.homeDir}/.config/helix/runtime/grammars"
    mkdir -p "${variables.homeDir}/.config/helix/runtime/queries"

    ln -sf "${pkgs.helix}/lib/runtime/themes" "${variables.homeDir}/.config/helix/runtime/"

    ln -sf ${pkgs.helix}/lib/runtime/grammars/* "${variables.homeDir}/.config/helix/runtime/grammars/"
    ln -sf ${pkgs.helix}/lib/runtime/queries/* "${variables.homeDir}/.config/helix/runtime/queries/"

    export HELIX_RUNTIME="${variables.homeDir}/.config/helix/runtime"
    export PATH="${path}:${variables.homeDir}/.npm-packages/bin:${variables.homeDir}/.py-packages/bin:$PATH"
    export LIBRARY_PATH="${pkgs.stdenv.cc.libc}/lib:${pkgs.stdenv.cc.cc.lib}/lib''${LIBRARY_PATH+:$LIBRARY_PATH}"

    exec ${pkgs.helix}/bin/.hx-wrapped $@
  '';
}{
  target = "${variables.homeDir}/bin/lsp-install";
  source = pkgs.writeScript "lsp-install.sh" ''
    #!${pkgs.stdenv.shell}

    set -e

    if [[ "$1" == "clean" ]]
    then
      rm -vrf ${variables.homeDir}/.npm-packages/*
      rm -vrf ${variables.homeDir}/.py-packages/*
      exit 0
    fi

    export NPM_PACKAGES="${variables.homeDir}/.npm-packages"
    export PY_PACKAGES="${variables.homeDir}/.py-packages"

    npm_install() {
      mkdir -p $NPM_PACKAGES
      ${pkgs.nodejs}/bin/npm install -g --prefix="$NPM_PACKAGES" "$@"
    }

    pip_install() {
      ${pkgs.python3Packages.python}/bin/python -m venv "$PY_PACKAGES"
      $PY_PACKAGES/bin/python -m pip install --upgrade pip
      $PY_PACKAGES/bin/pip install "$@"
    }

    npm_install \
      bash-language-server \
      dockerfile-language-server-nodejs \
      typescript \
      typescript-language-server \
      yaml-language-server \
      vscode-json-languageserver \
      vscode-html-languageserver-bin \
      vscode-css-languageserver-bin \
      coc-powershell \
      ansible-language-server

    pip_install \
      robotframework-lsp

    echo "Done!"
  '';
}]
