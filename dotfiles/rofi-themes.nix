{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/rofi/themes/material.rasi";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi-themes/4033ccd2999a2a6bd9f599331e274e95a6756018/User%20Themes/material.rasi";
    sha256 = "0dr148lg020wnz6s6xfk9lz2yn46w3w9zc5fjg54imf4rljb875j";
  };
}{
  target = "${variables.homeDir}/.config/rofi/themes/sidetab-adapta.rasi";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi-themes/2088c73e4006f4b17d6ce75758c6f021e612d1c2/User%20Themes/sidetab-adapta.rasi";
    sha256 = "0d2lpqc8nm4k33xvd35s4gdi5a3azv1hdi0v6w3wzkh76gz7gxg3";
  };
}{
  target = "${variables.homeDir}/.config/rofi/themes/sidetab-my.rasi";
  source = builtins.toFile "sidetab-my.rasi" ''
configuration {
        show-icons:   true;
        sidebar-mode: true;
        font: "${variables.font.family} ${variables.font.extra} ${variables.font.size}";
}

* {
        background-color:           #222d32CC;
        text-color:                 #ffffff;

        accent-color:               #00bcd4;
        accent2-color:              #4db6ac;
        hover-color:                #39454b;
        urgent-color:               #ff5252;
        window-color:               #ffffff;

        selected-normal-foreground: @window-color;
        normal-foreground:          @text-color;
        selected-normal-background: @hover-color;
        normal-background:          @background-color;

        selected-urgent-foreground: @background-color;
        urgent-foreground:          @text-color;
        selected-urgent-background: @urgent-color;
        urgent-background:          @background-color;

        selected-active-foreground: @window-color;
        active-foreground:          @text-color;
        selected-active-background: @hover-color;

        border-color:               @accent-color;
}

#window {
        anchor:   northwest;
        location: northwest;
        width:    33%;
        height:   66%;
        margin:   0 0 0 1em;
        border:   0 1px 1px 1px;
}

#mainbox {
        children: [ entry, listview, mode-switcher ];
}

entry {
        expand: false;
        margin: 8px;
}

element {
        padding: 8px;
}

element normal.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
}

element normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
}

element normal.active {
        background-color: #004c64;
        text-color:       @active-foreground;
}

element selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
        border:           0 4px solid;
        border-color:     @accent2-color;
}

element selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
}

element selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
        border:           0 4px solid;
        border-color:     @accent2-color;

}

element alternate.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
}

element alternate.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
}

element alternate.active {
        background-color: @active-background;
        text-color:       @active-foreground;
}

button {
        padding: 8px;
}

button selected {
        background-color: @active-background;
        text-color:       @background-color;
}
  '';
}]
