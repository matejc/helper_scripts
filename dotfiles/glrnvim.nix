{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/glrnvim";
  source = pkgs.writeScript "glrnvim.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    env PATH="${variables.homeDir}/bin" ${pkgs.glrnvim}/bin/glrnvim "$@"
  '';
} {
  target = "${variables.homeDir}/.config/glrnvim.yml";
  source = pkgs.writeText "glrnvim.yml" ''
    # vim:fileencoding=utf-8:ft=yaml

    # Choose the backend terminal to run neovim in.
    # Current supported terminals: alacritty, urxvt, kitty.
    #
    backend: alacritty
    # path to backend executable file
    # NOTE: requires a backend key
    exe_path: "${if variables ? alacrittyPath then variables.alacrittyPath else "${pkgs.alacritty}/bin/alacritty"}"

    # The fonts to be used. Multi fonts can be supplied.
    # The first one will be set as the major font. Others will be set as
    # fallback fonts according to the given orders if possible.
    # NOTE: Not all backends support fallback font.
    fonts:
      - ${variables.font.family}

    # The font size to be used.
    #
    font_size: ${variables.font.size}

    # Set to true if the terminal's default configuration should be loaded
    # first. Other glrnvim configurations will overwrite the terminal settings
    # if they are set in glrnvim.yml.
    # urxvt is not impacted by this setting. It always load resources according
    # to the defined orders.
    #load_term_conf: false
  '';
}]
