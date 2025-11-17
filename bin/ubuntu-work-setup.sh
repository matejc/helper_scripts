#!/usr/bin/env bash

set -e

remove_snap() {
  rm -rf /var/cache/snapd/
  apt-get -y autoremove --purge snapd
  rm -fr ~/snap
  apt-mark hold snapd
}

install_in_vm() {
  apt-get -y install qemu-guest-agent spice-vdagent spice-webdavd openssh-server
}

install_general() {
  apt-get -y install ufw gpg curl git build-essential ca-certificates
}

install_proxy() {
  curl -L https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.5/shadowsocks-v1.23.5.x86_64-unknown-linux-gnu.tar.xz | tar -xJ -C /usr/bin

  cat << EOF > /etc/systemd/system/sslocal.service
[Unit]
Description=Shadowsocks-rust sslocal
After=network.target
Wants=network.target

[Service]
ExecStart=/usr/bin/sslocal --local-addr 0.0.0.0:1088
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now sslocal.service
  systemctl start sslocal.service
}

install_edge() {
  curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft-edge.gpg
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' > /etc/apt/sources.list.d/microsoft-edge.list
  apt-get -y update
  apt-get -y install microsoft-edge-stable
}

install_xpra() {
  wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc
  wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra-beta.sources
  apt-get -y update
  apt-get -y install xpra
}

install_intune() {
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
  rm microsoft.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" >> "/etc/apt/sources.list.d/microsoft-ubuntu-$(lsb_release -cs)-prod.list"
  apt-get -y update
  apt-get -y install intune-portal
}

help() {
  declare -F | awk '{print $3}'
}

all() {
  remove_snap
  install_general
  install_edge
  install_intune
}

"$@"
