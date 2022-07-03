{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/wofi/config";
  source = pkgs.writeText "wofi.conf" ''
    width=600
    height=400
    filter_rate=100
  '';
} {
  target = "${variables.homeDir}/.config/wofi/style.css";
  source = pkgs.writeText "wofi.css" ''
window {
  margin: 0px;
  border: 1px solid #fb246f;
  background-color: #272822;
}

#input {
  margin: 5px;
  border: none;
  color: #a0e300;
  background-color: #32332b;
}

#inner-box {
  margin: 5px;
  border: none;
  background-color: #272822;
}

#outer-box {
  margin: 5px;
  border: none;
  background-color: #272822;
}

#scroll {
  margin: 0px;
  border: none;
}

#text {
  margin: 5px;
  border: none;
  color: #f8f8f2;
}

#entry:selected {
  background-color: #32332b;
}
  '';
}]
