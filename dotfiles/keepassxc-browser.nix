{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/chromium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json";
  source = pkgs.writeText "chromium.json" ''
    {
        "name": "org.keepassxc.keepassxc_browser",
        "description": "KeePassXC integration with native messaging support",
        "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
        "type": "stdio",
        "allowed_origins": [
            "chrome-extension://iopaggbpplllidnfmcghoonnokmjoicf/",
            "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
        ]
    }
  '';
} {
  target = "${variables.homeDir}/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json";
  source = pkgs.writeText "firefox.json" ''
    {
        "name": "org.keepassxc.keepassxc_browser",
        "description": "KeePassXC integration with native messaging support",
        "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
        "type": "stdio",
        "allowed_extensions": [
            "keepassxc-browser@keepassxc.org"
        ]
    }
  '';
}]
