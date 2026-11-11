{
  variables,
  pkgs,
  config,
  ...
}:
[
  {
    target = "${variables.homeDir}/bin/lockscreen";
    source = pkgs.writeScript "noctalialockscreen.sh" ''
      #!${pkgs.stdenv.shell}
      ${if config.programs.keepassxc.enable then ''
        ${pkgs.dbus}/bin/dbus-send \
          --session \
          --type=method_call \
          --dest=org.keepassxc.KeePassXC.MainWindow \
          /keepassxc \
          org.keepassxc.KeePassXC.MainWindow.lockAllDatabases || true
      '' else ""}
      exec ${pkgs.noctalia}/bin/noctalia msg session lock
    '';
  }
]
