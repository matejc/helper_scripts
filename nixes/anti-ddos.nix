{ pkgs, lib, config, ... }:
{
  # Source: https://javapipe.com/blog/iptables-ddos-protection/

  networking.firewall.extraCommands = ''
    iptables_add() {
      iptables -C $@ || iptables -A $@
    }

    ### 1: Drop invalid packets ###
    #iptables_add PREROUTING -t mangle -m conntrack --ctstate INVALID -j DROP

    ### 2: Drop TCP packets that are new and are not SYN ###
    iptables_add PREROUTING -t mangle -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

    ### 3: Drop SYN packets with suspicious MSS value ###
    iptables_add PREROUTING -t mangle -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

    ### 4: Block packets with bogus TCP flags ###
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags FIN,ACK FIN -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags ACK,URG URG -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags ACK,PSH PSH -j DROP
    iptables_add PREROUTING -t mangle -p tcp --tcp-flags ALL NONE -j DROP

    ### 5: Block spoofed packets ###
    iptables_add PREROUTING -t mangle -s 224.0.0.0/3 -j DROP
    iptables_add PREROUTING -t mangle -s 169.254.0.0/16 -j DROP
    iptables_add PREROUTING -t mangle -s 172.16.0.0/12 -j DROP
    iptables_add PREROUTING -t mangle -s 192.0.2.0/24 -j DROP
    iptables_add PREROUTING -t mangle -s 192.168.0.0/16 -j DROP
    iptables_add PREROUTING -t mangle -s 10.0.0.0/8 -j DROP
    iptables_add PREROUTING -t mangle -s 0.0.0.0/8 -j DROP
    iptables_add PREROUTING -t mangle -s 240.0.0.0/5 -j DROP
    iptables_add PREROUTING -t mangle -s 127.0.0.0/8 ! -i lo -j DROP

    ### 6: Drop ICMP (you usually don't need this protocol) ###
    iptables_add PREROUTING -t mangle -p icmp -j DROP

    ### 7: Drop fragments in all chains ###
    iptables_add PREROUTING -t mangle -f -j DROP

    ### 8: Limit connections per source IP ###
    iptables_add INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset

    ### 9: Limit RST packets ###
    iptables_add INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
    iptables_add INPUT -p tcp --tcp-flags RST RST -j DROP

    ### 10: Limit new TCP connections per second per source IP ###
    iptables_add INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
    iptables_add INPUT -p tcp -m conntrack --ctstate NEW -j DROP

    ### 11: Use SYNPROXY on all ports (disables connection limiting rule) ###
    #iptables_add PREROUTING -t raw -p tcp -m tcp --syn -j CT --notrack
    #iptables_add INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    #iptables_add INPUT -m conntrack --ctstate INVALID -j DROP

    ### SSH brute-force protection ###
    iptables_add INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
    iptables_add INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

    ### Protection against port scanning ###
    iptables -n --list port-scanning || iptables -N port-scanning
    iptables_add port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
    iptables_add port-scanning -j DROP
  '';

  boot.kernel.sysctl = {
    "kernel.printk" = "4 4 1 7";
    "kernel.panic" = 10;
    "kernel.sysrq" = 0;
    "kernel.shmmax" = 4294967296;
    "kernel.shmall" = 4194304;
    "kernel.core_uses_pid" = 1;
    "kernel.msgmnb" = 65536;
    "kernel.msgmax" = 65536;
    "vm.swappiness" = 20;
    "vm.dirty_ratio" = 80;
    "vm.dirty_background_ratio" = 5;
    "fs.file-max" = 2097152;
    "net.core.netdev_max_backlog" = 262144;
    "net.core.rmem_default" = 31457280;
    "net.core.rmem_max" = 67108864;
    "net.core.wmem_default" = 31457280;
    "net.core.wmem_max" = 67108864;
    "net.core.somaxconn" = 65535;
    "net.core.optmem_max" = 25165824;
    "net.ipv4.neigh.default.gc_thresh1" = 4096;
    "net.ipv4.neigh.default.gc_thresh2" = 8192;
    "net.ipv4.neigh.default.gc_thresh3" = 16384;
    "net.ipv4.neigh.default.gc_interval" = 5;
    "net.ipv4.neigh.default.gc_stale_time" = 120;
    "net.netfilter.nf_conntrack_max" = 10000000;
    "net.netfilter.nf_conntrack_tcp_loose" = 0;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 1800;
    "net.netfilter.nf_conntrack_tcp_timeout_close" = 10;
    "net.netfilter.nf_conntrack_tcp_timeout_close_wait" = 10;
    "net.netfilter.nf_conntrack_tcp_timeout_fin_wait" = 20;
    "net.netfilter.nf_conntrack_tcp_timeout_last_ack" = 20;
    "net.netfilter.nf_conntrack_tcp_timeout_syn_recv" = 20;
    "net.netfilter.nf_conntrack_tcp_timeout_syn_sent" = 20;
    "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.ip_local_port_range" = "1024 65000";
    "net.ipv4.ip_no_pmtu_disc" = 1;
    "net.ipv4.route.flush" = 1;
    "net.ipv4.route.max_size" = 8048576;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.tcp_congestion_control" = "htcp";
    "net.ipv4.tcp_mem" = "65536 131072 262144";
    "net.ipv4.udp_mem" = "65536 131072 262144";
    "net.ipv4.tcp_rmem" = "4096 87380 33554432";
    "net.ipv4.udp_rmem_min" = 16384;
    "net.ipv4.tcp_wmem" = "4096 87380 33554432";
    "net.ipv4.udp_wmem_min" = 16384;
    "net.ipv4.tcp_max_tw_buckets" = 1440000;
    "net.ipv4.tcp_tw_recycle" = 0;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_max_orphans" = 400000;
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_synack_retries" = 1;
    "net.ipv4.tcp_syn_retries" = 2;
    "net.ipv4.tcp_max_syn_backlog" = 16384;
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_sack" = 1;
    "net.ipv4.tcp_fack" = 1;
    "net.ipv4.tcp_ecn" = 2;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_keepalive_time" = 600;
    "net.ipv4.tcp_keepalive_intvl" = 60;
    "net.ipv4.tcp_keepalive_probes" = 10;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.ipv4.ip_forward" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.all.rp_filter" = 1;
  };
}
