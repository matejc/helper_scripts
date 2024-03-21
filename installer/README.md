# NixOS install procedure

- Local install
- Internet through Wi-Fi


## Make USB

```shell
$ nix build './installer#packages.x86_64-linux.image'
$ sudo dd ./result/iso/*.iso /dev/sdx
```


## Boot from USB

C'mon ..., you know how to do it.

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

```shell
$ partition-with-disko /dev/sdy
```


## Configuration

```shell
$ nixos-generate-config --root /mnt
$ nano -wc /mnt/etc/nixos/configuration.nix
```


## Install

```shell
$ nix-channel --update
$ nixos-install
```


## Done

```shell
$ reboot
```
