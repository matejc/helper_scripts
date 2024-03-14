# NixOS install procedure

- Local install
- Internet through Wi-Fi


## Make USB

```shell
$ wget https://channels.nixos.org/nixos-23.11/latest-nixos-minimal-x86_64-linux.iso
$ sudo dd ./latest-nixos-minimal-x86_64-linux.iso /dev/sdx
```


## Boot from USB


## Setup Wi-Fi

```shell
$ sudo systemctl start wpa_supplicant
```

```shell
$ wpa_cli
> add_network
0
> set_network 0 ssid "myhomenetwork"
OK
> set_network 0 psk "mypassword"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
```


## Partition disk

Inside file `./luks.nix`:
1. change disk, and
2. create /tmp/secret.key

```shell
$ sed -i 's|/dev/vda|/dev/sdx|' ./luks.nix

$ cat > /tmp/secret.key  # type in the password and press Ctrl+D when done

$ sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./luks.nix
```


## Mount file system

```shell
$ cryptsetup luksOpen /dev/sdx2 crypted
$ mount /dev/mapper/crypted /mnt

$ mkdir /mnt/boot
$ mount /dev/sdx1 /mnt/boot
```


## Configuration

```shell
$ nixos-generate-config --root /mnt
$ nano -wc /mnt/etc/nixos/configuration.nix
```


## Install

```shell
$ nixos-install
```


## Done

```shell
$ reboot
```
