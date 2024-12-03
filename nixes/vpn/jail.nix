{ pkgs ? import <nixpkgs> {}
, name ? "default"
, user ? {
  outside = builtins.getEnv "USER";
  inside = "user";
}
, uid ? "1000"
, gid ? "1000"
, timeZone ? "UTC"
, nameservers ? [ "1.1.1.1" ]
, vpn ? {
  start = "openvpn --config /etc/openvpn/ovpn --script-security 2 --up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf --daemon --log ${home.inside}/.openvpn.log --auth-user-pass /etc/openvpn/pass";
  stop = "pkill openvpn";
}
, gpconnect ? null
, compositor ? {
  start = "labwc --startup /bin/compositor-cmds -C /etc/xdg/labwc";
  stop = "pkill labwc";
}
, socksproxy ? {
  guestPort = 1080; hostPort = 1080;
}
, httpproxy ? {
  guestPort = 3128; hostPort = 3128;
}
, cmds ? [
]
, preCmds ? {
  outside = [ ];
  inside = [ ];
}
, packages ? with pkgs; [ firefox foot ]
, stateDir ? "${home.outside}/.vpn/${name}"
, mounts ? [ ]
, romounts ? [
  { from = "/run/opengl-driver"; to = "/run/opengl-driver"; }
  { from = "${home.outside}/.vpn/${name}/openvpn"; to = "/etc/openvpn"; }
  { from = "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"; to = "/etc/openvpn/update-resolv-conf"; }
]
, symlinks ? [ ]
, variables ? [
  { name = "HISTFILE"; value = "${home.inside}/.zsh_history"; }
]
, wayland ? {
  outside = "wayland-1";
  inside = "wayland-9";
}
# , x11 ? ":0"
, x11 ? null
, enablePulse ? true
, caps ? [ ]
, extraArgs ? ""
, tmpfs ? [ ]
, home ? {
  outside = builtins.getEnv "HOME";
  inside = "/home/${user.inside}";
}
, newuidmap ? "/run/wrappers/bin/newuidmap"
, newgidmap ? "/run/wrappers/bin/newgidmap"
, extraSlirp4netnsArgs ? "--disable-host-loopback"
, hostFwds ? []
, slirp4netnsHostFwds ? []
, interactiveShell ? "${pkgs.bashInteractive}/bin/bash"
, defaultBrowser ? "firefox --no-remote"
, launchers ? [
  {
    name = "Clipboard Pull";
    exec = "/usr/bin/clipboard-pull >/dev/null 2>/dev/null </dev/null";
  }
  {
    name = "Clipboard Push";
    exec = "/usr/bin/clipboard-push >/dev/null 2>/dev/null </dev/null";
  }
  {
    name = "Browser";
    exec = defaultBrowser;
  }
  {
    name = "Terminal";
    exec = "foot";
  }
] ++ extraLaunchers
, extraLaunchers ? []
}:
let
  nsjail = import ../nsjail.nix { inherit pkgs newuidmap newgidmap; };

  labwcConfig = pkgs.writeText "config.xml" ''
    <?xml version="1.0"?>
    <labwc_config>
      <keyboard>
        <default />
        <keybind key="C-A-v">
          <action name="clipboard-pull" command="/usr/bin/clipboard-pull >/dev/null 2>/dev/null </dev/null" />
        </keybind>
        <keybind key="C-A-c">
          <action name="clipboard-push" command="/usr/bin/clipboard-push >/dev/null 2>/dev/null </dev/null" />
        </keybind>
      </keyboard>
    </labwc_config>
  '';

  labwcMenu = pkgs.writeText "menu.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <openbox_menu>
    <menu id="root-menu">
      ${pkgs.lib.concatImapStringsSep "\n" (i: l: ''
      <item label="${l.name}">
        <action>
          <name>Execute</name>
          <command>${pkgs.writeShellScript "launcher${toString i}.sh" "${l.exec}"}</command>
        </action>
      </item>
      '') launchers}
    </menu>
    </openbox_menu>
  '';

  shadowsocksFile = pkgs.writeText "shadowsocks.json" (builtins.toJSON {
    # local_address = "0.0.0.0";
    # local_port = shadowsocks.guestPort;
    locals = [
      {
        protocol = "http";
        local_address = "0.0.0.0";
        local_port = httpproxy.guestPort;
      }
      {
        protocol = "socks";
        local_address = "0.0.0.0";
        local_port = socksproxy.guestPort;
      }
    ];
  });

  gp-connect = pkgs.writeShellScriptBin "gp-connect" ''
    { sleep 2; chown -R ${uid}:${gid} "/run/user/${uid}"; } &
    eval $(${pkgs.gp-saml-gui}/bin/gp-saml-gui --$1 --clientos=Linux $2)
    echo $HOST; echo $USER; echo $OS
    echo "$COOKIE" | ${pkgs.openconnect}/bin/openconnect --protocol=gp -u "$USER" --os="$OS" --passwd-on-stdin --useragent='PAN GlobalProtect' --csd-wrapper=${pkgs.openconnect}/libexec/openconnect/hipreport.sh "$HOST"
  '';

  preCmdOutside = pkgs.writeShellScript "pre-cmd-outside.sh" ''
    ${pkgs.lib.concatMapStringsSep "\n" (c: "${c}") preCmds.outside}
  '';

  preCmdInside = pkgs.writeShellScript "pre-cmd-inside.sh" ''
    ${pkgs.lib.concatMapStringsSep "\n" (c: "${c}") preCmds.inside}
  '';

  mkCmd = name: { start, stop ? "" }: pkgs.writeShellScript "start-${name}.sh" ''
    set -e
    stop_script() {
      echo "Exiting ${name} ..."
      ${stop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM
    ${start}
    wait $!
  '';

  mkUpCmd = pkgs.writeShellScript "start-up.sh" ''
    set -e
    ${pkgs.lib.concatImapStringsSep "\n" (i: p: ''
    supervisorctl --serverurl=unix:///tmp/supervisor.sock restart p${toString i}
    '') cmds}
  '';

  mkVpnCmd = pkgs.writeShellScript "start-vpn.sh" ''
    set -e
    stop_script() {
      echo "Exiting vpn ..."
      ${vpn.stop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM
    ${vpn.start} || exit 1
    while true
    do
      sleep 1
    done
  '';

  mkCompositorCmd = pkgs.writeShellScript "start-compositor.sh" ''
    set -e
    stop_script() {
      echo "Exiting compositor ..."
      ${compositor.stop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM EXIT
    WAYLAND_DISPLAY=${wayland.outside} ${compositor.start}
  '';

  hostFwds' = if hostFwds == null then null else [
    { host_port = httpproxy.hostPort; guest_port = httpproxy.guestPort; }
    { host_port = socksproxy.hostPort; guest_port = socksproxy.guestPort; }
  ] ++ hostFwds;

  slirp4netnsHostFwds' = [
  ] ++ slirp4netnsHostFwds;

  supervisorConf = pkgs.writeText "supervisord.conf" ''
    [supervisord]
    directory = ${home.inside}/.supervisord
    user = root
    nodaemon = true
    pidfile = ${home.inside}/.supervisord/.pid

    [unix_http_server]
    file = /tmp/supervisor.sock
    chmod = 0777

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl = unix:///tmp/supervisor.sock

    ${if vpn != null then ''
    [program:vpn]
    command = ${mkVpnCmd}
    priority = 0
    directory = /root
    user = root
    numprocs = 1
    autostart = true
    autorestart = unexpected
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/vpn.log
    stdout_logfile_maxbytes = 0
    '' else ""}

    ${if gpconnect != null then ''
    [program:gp-connect]
    command = ${mkCmd "gp-connect" { start = "gp-connect ${gpconnect.type} ${gpconnect.server}"; stop = "pkill gp-connect";}}
    priority = 0
    directory = /root
    user = root
    numprocs = 1
    autostart = true
    autorestart = unexpected
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/gp-connect.log
    stdout_logfile_maxbytes = 0
    '' else ""}

    [program:shadowsocks]
    command = ${mkCmd "shadowsocks" { start = "sslocal -c ${shadowsocksFile}"; stop = "pkill sslocal";}}
    priority = 0
    directory = ${home.inside}
    user = ${user.inside}
    numprocs = 1
    autostart = true
    autorestart = unexpected
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/shadowsocks.log
    stdout_logfile_maxbytes = 0

    ${if compositor != null then ''
    [program:compositor]
    command = ${mkCompositorCmd}
    priority = 0
    directory = ${home.inside}
    user = ${user.inside}
    numprocs = 1
    autostart = true
    autorestart = true
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/compositor.log
    stdout_logfile_maxbytes = 0
    '' else ""}

    ${pkgs.lib.concatMapStringsSep "\n" (f: ''
    [program:socket${toString f.host_port}]
    command = ${mkCmd "socket-${toString f.host_port}" {start = "socat UNIX-LISTEN:${home.inside}/fwd/${toString f.host_port}.sock,fork,reuseaddr,unlink-early,mode=777 TCP:${if f ? guest_addr then f.guest_addr else "127.0.0.1"}:${toString f.guest_port}";}}
    priority = 0
    directory = ${home.inside}
    user = ${user.inside}
    numprocs = 1
    autostart = true
    autorestart = true
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/socket-${toString f.host_port}.log
    stdout_logfile_maxbytes = 0
    '') hostFwds'}

    ${pkgs.lib.concatImapStringsSep "\n" (i: p: ''
    [program:p${toString i}]
    command = ${mkCmd "p${toString i}" p}
    priority = ${toString i}
    directory = ${home.inside}
    user = ${user.inside}
    numprocs = 1
    autostart = false
    autorestart = true
    startsecs = 3
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${home.inside}/.supervisord/p${toString i}.log
    stdout_logfile_maxbytes = 0
    '') cmds}
  '';

  insideCmd = pkgs.writeShellScript "inside-${name}.sh" ''
    set -e

    cat ${resolvConf} >/etc/resolv.conf

    for i in {1..50}
    do
      if ip addr show dev tap0
      then
        break
      fi
      sleep 0.1
    done
    ip addr show dev tap0 || exit 1

    mkdir -p ${home.inside}/.supervisord

    trap 'echo "Be patient inside"' SIGINT

    ${preCmdInside}

    exec supervisord --configuration=${supervisorConf}
  '';

  slirp4netnsExecute =
    map (o: { execute = "add_hostfwd"; arguments = { proto = "tcp"; host_addr = "127.0.0.1"; } // o; }) slirp4netnsHostFwds';

  script = pkgs.writeShellScript "script.sh" ''
    set -e

    mkdir -p ${stateDir}/home/fwd

    cat ${resolvConf} >${stateDir}/.resolv.conf
    echo -n "" > ${stateDir}/.ns.pid

    ${preCmdOutside}

    ${if hostFwds' != null && hostFwds' != [] then ''
    inotifywait -r -m ${stateDir}/home/fwd |
      while read a b file; do
      ${pkgs.lib.concatMapStringsSep "\n" (f: ''
        [[ $b == *CREATE* ]] && [[ $file == *${toString f.host_port}.sock ]] && sh -c "socat TCP-LISTEN:${toString f.host_port},reuseaddr,fork UNIX-CONNECT:${stateDir}/home/fwd/${toString f.host_port}.sock &";
        [[ $b == *DELETE* ]] && [[ $file == *${toString f.host_port}.sock ]] && fuser -k ${toString f.host_port}/TCP;
      '') hostFwds'}
      done &
    echo -n "$!" > ${stateDir}/.inotifywait.pid
    '' else ""}

    for i in {1..50}
    do
      nspid="$(cat ${stateDir}/.ns.pid || echo "")"
      if [ ! -z "$nspid" ] && [ -f "/proc/$nspid/cmdline" ]
      then
        slirp4netns --disable-dns --configure --mtu=65520 --api-socket /tmp/slirp4netns.sock ${extraSlirp4netnsArgs} $nspid tap0 &
        echo "$!" >${stateDir}/home/.slirp4netns.pid

        json='{"execute": "list_hostfwd"}'
        for i in {1..50}
        do
          if echo $json | nc -U /tmp/slirp4netns.sock
          then
            break
          else
            sleep 0.1
          fi
        done

        ${pkgs.lib.concatMapStringsSep "\n" (e: ''echo -n '${builtins.toJSON e}' | nc -U /tmp/slirp4netns.sock'') slirp4netnsExecute}
        break
      fi
      sleep 0.1
    done &

    function exiting() {
      set +e
      echo Exiting ...
      kill $(cat ${stateDir}/home/.slirp4netns.pid)
      rm ${stateDir}/home/.slirp4netns.pid
      kill $(cat ${stateDir}/.inotifywait.pid)
      rm ${stateDir}/.inotifywait.pid
    }
    trap exiting EXIT

    ${nsjail}/bin/nsjail \
      -Mo \
      --tmpfsmount / \
      --bindmount ${stateDir}/home:${home.inside} \
      --tmpfsmount /root \
      --disable_proc \
      --mount none:/proc:proc \
      --bindmount /dev/urandom:/dev/urandom \
      --bindmount /dev/null:/dev/null \
      --bindmount /dev/net/tun:/dev/net/tun \
      --bindmount /dev/dri:/dev/dri \
      --mount none:/dev/shm:tmpfs:rw,mode=1777,size=1048576k \
      --mount none:/dev/pts:devpts:ptmxmode=0666 \
      --symlink /dev/pts/ptmx:/dev/ptmx \
      --mount none:/dev/mqueue:mqueue:rw \
      --mount none:/sys:sysfs \
      --mount none:/tmp:tmpfs:rw \
      --mount none:/tmp/.X11-unix:tmpfs:rw \
      --tmpfsmount /nix \
      --bindmount_ro /nix/store:/nix/store \
      --tmpfsmount /etc \
      --symlink ${hostsFile}:/etc/hosts \
      --symlink ${passwdFile}:/etc/passwd \
      --symlink ${groupFile}/etc/group:/etc/group \
      --symlink ${hostnameFile}:/etc/hostname \
      --symlink ${machineId}:/etc/machine-id \
      --symlink ${pkgs.tzdata}/share/zoneinfo/${timeZone}:/etc/localtime \
      --mount none:/etc/ssl:tmpfs:rw \
      --bindmount_ro ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt \
      --tmpfsmount /etc/xdg/labwc \
      --symlink ${labwcConfig}:/etc/xdg/labwc/rc.xml \
      --symlink ${labwcMenu}:/etc/xdg/labwc/menu.xml \
      --tmpfsmount /sbin \
      --symlink ${pkgs.openresolv}/bin/resolvconf:/sbin/resolvconf \
      --tmpfsmount /bin \
      --tmpfsmount /usr \
      --symlink ${paths}/bin:/usr/bin \
      --symlink ${pkgs.bash}/bin/bash:/bin/bash \
      --symlink ${pkgs.bash}/bin/sh:/bin/sh \
      --symlink ${mkUpCmd}:/bin/compositor-cmds \
      --symlink ${paths}/share:/usr/share \
      --tmpfsmount /var/run \
      --tmpfsmount /run \
      --mount none:/run/user/${uid}:tmpfs:mode=0700,uid=${uid},gid=${gid} \
      ${if wayland != null then "--bindmount_ro /run/user/${uid}/${wayland.outside}:/run/user/${uid}/${wayland.outside}" else ""} \
      ${if x11 != null then "--bindmount_ro /tmp/.X11-unix/${pkgs.lib.replaceStrings [":"] ["X"] x11}:/tmp/.X11-unix/${pkgs.lib.replaceStrings [":"] ["X"] x11} --env DISPLAY=${x11}" else "--env DISPLAY=:0"} \
      ${if enablePulse then "--bindmount_ro /run/user/${uid}/pulse:/run/user/${uid}/pulse --env PULSE_SERVER=/run/user/${uid}/pulse/native" else ""} \
      --hostname RESTRICTED \
      --cwd / \
      --keep_caps \
      --uid_mapping 0:100000:1 \
      --gid_mapping 0:100000:1 \
      --uid_mapping ${uid}:${uid}:1 \
      --gid_mapping ${gid}:${gid}:1 \
      --disable_rlimits \
      --bindmount_ro /etc/fonts:/etc/fonts \
      --bindmount_ro ${paths}/lib:/lib \
      --bindmount_ro ${paths}/libexec:/libexec \
      --env FONTCONFIG_FILE=/etc/fonts/fonts.conf \
      --env FC_CONFIG_FILE=/etc/fonts/fonts.conf \
      --env XDG_RUNTIME_DIR=/run/user/${uid} \
      --env XDG_DATA_DIRS=/usr/share \
      --env HOME=${home.inside} \
      --env USER=${user.inside} \
      --env PATH=${binPaths} \
      --env LD_LIBRARY_PATH=/lib \
      --env GIO_EXTRA_MODULES=/lib/gio/modules \
      ${pkgs.lib.concatMapStringsSep " " (c: "--cap ${c}") caps} \
      ${pkgs.lib.concatMapStringsSep " " (m: "--tmpfsmount ${m}") tmpfs} \
      ${pkgs.lib.concatMapStringsSep " " (m: "--bindmount ${m.from}:${m.to}") mounts} \
      ${pkgs.lib.concatMapStringsSep " " (m: "--bindmount_ro ${m.from}:${m.to}") romounts} \
      ${pkgs.lib.concatMapStringsSep " " (m: "--symlink ${m.from}:${m.to}") symlinks} \
      ${pkgs.lib.concatMapStringsSep " " (m: "--env ${m.name}=${m.value}") variables} \
      --forward_signals \
      ${extraArgs} \
      -- ${insideCmd} & nsjail_pid=$!
      sleep 0.1
      ps -o pid,cmd -u 100000 | awk '$3 == "${insideCmd}" {printf $1}' > ${stateDir}/.ns.pid
      wait $nsjail_pid
  '';

  resolvConf = pkgs.writeText "resolv.conf" ''
    ${pkgs.lib.concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
  '';

  machineId = pkgs.writeText "machine-id" ''
    10000000000000000000000000000000
  '';

  passwdFile = pkgs.writeText "passwd" ''
    root:!:0:0::/root:${interactiveShell}
    ${user.inside}:!:${uid}:${gid}::${home.inside}:${interactiveShell}
    nobody:!:65534:65534::/var/empty:${pkgs.shadow}/bin/nologin
  '';

  groupFile = pkgs.writeText "group" ''
    root:x:0:
    users:x:${gid}:${user.inside}
    nogroup:x:65534:nobody
  '';

  hostsFile = pkgs.writeText "hosts" ''
    127.0.0.1  RESTRICTED
  '';

  hostnameFile = pkgs.writeText "hostname" ''RESTRICTED'';

  pullClipboard = pkgs.writeShellScriptBin "clipboard-pull" ''
    export XDG_RUNTIME_DIR=/run/user/${uid}
    WAYLAND_DISPLAY=${wayland.outside} /usr/bin/wl-paste -n | /usr/bin/wl-copy -n
  '';

  pushClipboard = pkgs.writeShellScriptBin "clipboard-push" ''
    export XDG_RUNTIME_DIR=/run/user/${uid}
    /usr/bin/wl-paste -n | WAYLAND_DISPLAY=${wayland.outside} /usr/bin/wl-copy -n
  '';

  buildInputs = with pkgs; [
    iproute2 slirp4netns curl fakeroot which sysctl procps kmod openvpn
    util-linux fontconfig coreutils libcap strace less python3Packages.supervisor gawk dnsutils iptables
    gnugrep shadow labwc foot xfce.xfce4-icon-theme wl-clipboard pullClipboard pushClipboard
    openssl dconf netcat vanilla-dmz inetutils gnused openssh socat psmisc inotify-tools
    shadowsocks-rust
  ]
    ++ packages
    ++ (pkgs.lib.optionals (gpconnect != null) [gp-connect]);

  binPaths = pkgs.lib.makeBinPath buildInputs;

  paths = pkgs.buildEnv {
    name = "paths";
    paths = buildInputs;
    pathsToLink = [ "/bin" "/share" "/lib" "/libexec" ];
  };
in
  pkgs.mkShell {
    inherit name buildInputs;
    shellHook = ''
      exec ${script}
    '';
  }
