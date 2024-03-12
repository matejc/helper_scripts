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
  start = "openvpn --config /etc/openvpn/ovpn --pull-filter ignore 'ifconfig-ipv6' --pull-filter ignore 'route-ipv6' --script-security 2 --up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf --daemon --log /dev/stdout --auth-user-pass /etc/openvpn/pass";
  stop = "pkill openvpn";
}
, weston ? {
  start = "weston -B wayland --display=${wayland.outside} --socket=/run/user/${uid}/${wayland.inside} --xwayland --config=${westonConfigFile}";
  stop = "pkill weston";
}
, cmds ? [
  { start = "srelay -fi 0.0.0.0:9050"; }
]
, preCmds ? {
  outside = [];
  inside = [
    "echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6"
    "echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6"
  ];
}
, packages ? with pkgs; [ firefox ]
, stateDir ? "${home.outside}/.vpn/${name}"
, chroot ? "${stateDir}/chroot"
, mounts ? [ ]
, romounts ? [
  { from = "/run/opengl-driver"; to = "/run/opengl-driver"; }
  { from = "${home.outside}/.vpn/openvpns"; to = "/etc/openvpn"; }
  { from = "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"; to = "/etc/openvpn/update-resolv-conf"; }
]
, symlinks ? [ ]
, variables ? [ ]
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
, hostFwds ? [ { host_port = 9050; guest_port = 9050; } ]
, interactiveShell ? "${pkgs.bashInteractive}/bin/bash"
, launchers ? [
  {
    icon = "${pkgs.firefox}/share/icons/hicolor/32x32/apps/firefox.png";
    exec = "firefox --no-remote";
  }
]
, westonConfig ? ''
[core]
xwayland=true

[keyboard]
keymap_layout=us

[shell]
close-animation=none
focus-animation=none
startup-animation=none
background-color=0xff555555

[launcher]
icon=/usr/share/weston/terminal.png
path=/usr/bin/weston-terminal

${pkgs.lib.concatImapStringsSep "\n" (i: l: ''
[launcher]
icon=${pkgs.runCommand "icon${toString i}.png" { buildInputs = [pkgs.imagemagick]; } "convert ${l.icon} -resize 24x24! $out"}
path=${pkgs.writeShellScript "launcher${toString i}.sh" "${l.exec}"}
'') launchers}
''
, westonConfigFile ? pkgs.writeText "weston.ini" westonConfig
}:
with pkgs.lib;
let
  nsjail = import ../nsjail.nix { inherit pkgs newuidmap newgidmap; };

  preCmdOutside = pkgs.writeShellScript "pre-cmd-outside.sh" ''
    ${concatMapStringsSep "\n" (c: "${c}") preCmds.outside}
  '';

  preCmdInside = pkgs.writeShellScript "pre-cmd-inside.sh" ''
    ${concatMapStringsSep "\n" (c: "${c}") preCmds.inside}
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
    ${concatImapStringsSep "\n" (i: p: ''
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

  mkWestonCmd = pkgs.writeShellScript "start-weston.sh" ''
    set -e
    stop_script() {
      echo "Exiting weston ..."
      ${weston.stop}
      exit 0
    }
    trap stop_script SIGINT SIGTERM EXIT
    ${weston.start} &
    weston_pid=$!
    while ! ls /run/user/${uid}/${wayland.inside}.lock
    do
      sleep 1
    done
    ${mkUpCmd}
    wait $weston_pid
  '';

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

    ${if weston != null then ''
    [program:weston]
    command = ${mkWestonCmd}
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
    stdout_logfile = ${home.inside}/.supervisord/weston.log
    stdout_logfile_maxbytes = 0
    '' else ""}

    ${concatImapStringsSep "\n" (i: p: ''
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

  insideCmd = pkgs.writeShellScript "inside.sh" ''
    set -e

    cat ${resolvConf} >/etc/resolv.conf

    echo -n "$$" > ${home.inside}/.ns.pid

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
  let
    slirp4netnsHostFwds = map (o: { execute = "add_hostfwd"; arguments = { proto = "tcp"; host_addr = "127.0.0.1"; } // o; }) hostFwds;
  in
    slirp4netnsHostFwds;

  script = pkgs.writeShellScript "script.sh" ''
    set -e

    mkdir -p ${stateDir}/home

    cat ${resolvConf} >${stateDir}/.resolv.conf
    touch ${stateDir}/home/.ns.pid

    ${preCmdOutside}

    for i in {1..50}
    do
      nspid="$(cat ${stateDir}/home/.ns.pid || echo "")"
      if [ ! -z "$nspid" ] && [ -f "/proc/$nspid/cmdline" ]
      then
        slirp4netns --disable-dns --configure --mtu=65520 --api-socket /tmp/slirp4netns.sock ${extraSlirp4netnsArgs} $nspid tap0 &
        echo "$!" >${stateDir}/home/.slirp4netns.pid

        json='{"execute": "list_hostfwd"}'
        while ! echo $json | nc -U /tmp/slirp4netns.sock; do sleep 0.1; done

        ${concatMapStringsSep "\n" (e: ''echo -n '${builtins.toJSON e}' | nc -U /tmp/slirp4netns.sock'') slirp4netnsExecute}
        break
      fi
      sleep 0.1
    done &

    trap 'echo Exiting slirp4netns ...; kill $(cat ${stateDir}/home/.slirp4netns.pid)' EXIT

    ${nsjail}/bin/nsjail \
      -Mo \
      --tmpfsmount / \
      --disable_proc \
      --bindmount ${stateDir}/home:${home.inside} \
      --tmpfsmount /root \
      --bindmount /dev:/dev \
      --bindmount /sys:/sys \
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
      --tmpfsmount /sbin \
      --symlink ${pkgs.openresolv}/bin/resolvconf:/sbin/resolvconf \
      --tmpfsmount /bin \
      --tmpfsmount /usr \
      --symlink ${paths}/bin:/usr/bin \
      --symlink ${pkgs.bash}/bin/bash:/bin/bash \
      --symlink ${pkgs.bash}/bin/sh:/bin/sh \
      --symlink ${paths}/share:/usr/share \
      --tmpfsmount /var/run \
      --tmpfsmount /run \
      --mount none:/run/user/${uid}:tmpfs:mode=0700,uid=${uid},gid=${gid} \
      ${if wayland != null then "--bindmount_ro /run/user/${uid}/${wayland.outside}:/run/user/${uid}/${wayland.outside}" else ""} \
      --env WAYLAND_DISPLAY=${wayland.inside} \
      ${if x11 != null then "--bindmount_ro /tmp/.X11-unix/${replaceStrings [":"] ["X"] x11}:/tmp/.X11-unix/${replaceStrings [":"] ["X"] x11} --env DISPLAY=${x11}" else "--env DISPLAY=:0"} \
      ${if enablePulse then "--bindmount_ro /run/user/${uid}/pulse:/run/user/${uid}/pulse --env PULSE_SERVER=/run/user/${uid}/pulse/native" else ""} \
      --disable_clone_newpid \
      --bindmount /proc:/proc \
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
      ${concatMapStringsSep " " (c: "--cap ${c}") caps} \
      ${concatMapStringsSep " " (m: "--tmpfsmount ${m}") tmpfs} \
      ${concatMapStringsSep " " (m: "--bindmount ${m.from}:${m.to}") mounts} \
      ${concatMapStringsSep " " (m: "--bindmount_ro ${m.from}:${m.to}") romounts} \
      ${concatMapStringsSep " " (m: "--symlink ${m.from}:${m.to}") symlinks} \
      ${concatMapStringsSep " " (m: "--env ${m.name}=${m.value}") variables} \
      --forward_signals \
      ${extraArgs} \
      -- ${insideCmd}
  '';

  resolvConf = pkgs.writeText "resolv.conf" ''
    ${concatMapStringsSep "\n" (i: "nameserver ${i}") nameservers}
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
    WAYLAND_DISPLAY=${wayland.outside} wl-paste | WAYLAND_DISPLAY=${wayland.inside} wl-copy
  '';

  pushClipboard = pkgs.writeShellScriptBin "clipboard-push" ''
    WAYLAND_DISPLAY=${wayland.inside} wl-paste | WAYLAND_DISPLAY=${wayland.outside} wl-copy
  '';

  buildInputs = with pkgs; [
    iproute2 slirp4netns curl fakeroot which sysctl procps kmod openvpn pstree
    util-linux fontconfig coreutils libcap strace less python3Packages.supervisor gawk dnsutils iptables
    gnugrep shadow pkgs.weston xfce.xfce4-icon-theme wl-clipboard pullClipboard pushClipboard
    openssl dconf srelay netcat vanilla-dmz inetutils gnused
  ] ++ packages;

  binPaths = makeBinPath buildInputs;

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
