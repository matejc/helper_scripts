# http://pastebin.com/3WF7rccW

  { config, pkgs, lib, ... }:
  {
    # networking
    networking = {
      firewall.enable = true;
      firewall.trustedInterfaces = [ "torbr0" "veth0" "tortun0" ];
      nat.enable = true;
      nat.externalInterface = "+";
      nat.internalInterfaces = [ "c-+" ];
      localCommands = ''
        export PATH=$PATH:${pkgs.bridge_utils}/sbin:${pkgs.iptables}/sbin

        ip netns list | grep tor || ip netns add tor
        ip link | grep veth0 || ip link add veth0 type veth peer name veth1
        ip link set veth0 up
        ip netns exec tor ip link | grep veth1 || ip link set veth1 netns tor
        ip netns exec tor ip link set veth1 up
        ip netns exec tor ip addr replace 10.6.6.2/24 broadcast 10.6.6.255 dev veth1
        ip netns exec tor ip route replace default via 10.6.6.1

        # Bridge torbr0
        brctl show | grep torbr0 || brctl addbr torbr0
        brctl addif torbr0 veth0 || true
        ip addr replace 10.6.6.1/24 broadcast 10.6.6.255 dev torbr0
        ip link set torbr0 up

        # tun2socks tortun0
        ip link | grep tortun0 || ip tuntap add dev tortun0 mode tun
        ip link set tortun0 up
        ip addr replace 10.6.7.1/24 broadcast 10.6.7.255 dev tortun0

        # vpn0
        #ip link | grep vpn0 || ip tuntap add dev vpn0 mode tun
        #ip link set vpn0 up

        # Route other traffic throught VPN, do NAT
        #ip rule del fwmark 20 table 2 || true
        #ip rule add fwmark 20 table 2
        #iptables -C PREROUTING -t mangle -i torbr0 -p icmp -j MARK --set-mark 20 || \
        #iptables -A PREROUTING -t mangle -i torbr0 -p icmp -j MARK --set-mark 20
        #iptables -C POSTROUTING -t nat -o vpn0 -j MASQUERADE || \
        #iptables -A POSTROUTING -t nat -o vpn0 -j MASQUERADE
        #iptables -C FORWARD -i vpn0 -j ACCEPT || iptables -A FORWARD -i vpn0 -j ACCEPT

        # Route TCP traffic directly throught tor network
        ip route flush table 1
        ip route add table 1 10.6.7.0/24 dev tortun0
        ip route add table 1 default via 10.6.7.1
        ip rule del from 10.6.6.0/24 table 1 || true
        ip rule add from 10.6.6.0/24 table 1
        #iptables -C PREROUTING -t mangle -i torbr0 -p tcp -j MARK --set-mark 10 || \
        #iptables -A PREROUTING -t mangle -i torbr0 -p tcp -j MARK --set-mark 10
      '';
    };

    services.tor.enable = true;
    services.tor.controlPort = 9051;
    services.tor.client.enable = true;
    services.tor.extraConfig = ''
      VirtualAddrNetwork 10.199.0.0/10
      TransPort 9040
      DNSPort 53
      DNSListenAddress 10.6.7.1
      HiddenServiceDir /var/lib/tor/hidden_service/
      HiddenServicePort 80 127.0.0.1:65100
    '';
    systemd.services.torsocks =
      { description = "tun2socks for tor";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.badvpn ];
        script = "badvpn-tun2socks --logger syslog --tundev tortun0 --netif-ipaddr 10.6.7.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:9050";
      };
    # Resolve connections from tor namespace with tor nameserver
    environment.etc = [
      { source = pkgs.writeText "tor-resolv.conf" "nameserver 10.6.7.1";
        target = "netns/tor/resolv.conf"; }
    ];
  }
