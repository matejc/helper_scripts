{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/wofi/config";
  source = pkgs.writeText "wofi.conf" ''
    width=600
    height=400
    colors=colors
    filter_rate=100
  '';
} {
  target = "${variables.homeDir}/.config/wofi/style.css";
  source = pkgs.writeText "wofi.css" ''
window {
  border: 1px solid #00bcd4;
  background-color: #222d32CC;
}

#input {
  margin: 5px;
  background-color: #222d32CC;
}

#inner-box {
  margin: 5px;
  background-color: #222d32CC;
}

#outer-box {
  background-color: #222d32CC;
}

#scroll {
  background-color: #222d32CC;
}

#text {
  background-color: #222d32CC;
}
  '';
}]
