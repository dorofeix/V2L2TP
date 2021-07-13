#!/bin/sh

set -e

# ***** 放行 L2TP 流量 *****
iptables -t mangle -I PREROUTING -p udp --dport 500 -j RETURN
iptables -t mangle -I PREROUTING -p udp --dport 4500 -j RETURN
iptables -t mangle -I OUTPUT -p udp --sport 500 -j RETURN
iptables -t mangle -I OUTPUT -p udp --sport 4500 -j RETURN
iptables -t mangle -I OUTPUT -p udp --sport 1701 -j RETURN
# ***************

# ***** V2RAY 规则 *****
# 设置策略路由
ip rule add fwmark 1 table 100 
ip route add local 0.0.0.0/0 dev lo table 100

# 代理局域网设备
iptables -t mangle -N V2RAY
iptables -t mangle -A V2RAY -d 127.0.0.1/32 -j RETURN
iptables -t mangle -A V2RAY -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A V2RAY -d 255.255.255.255/32 -j RETURN
iptables -t mangle -A V2RAY -d 172.0.0.0/8 -p tcp -j RETURN
iptables -t mangle -A V2RAY -d 172.0.0.0/8 -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY -j RETURN -m mark --mark 0xff
iptables -t mangle -A V2RAY -p udp -j TPROXY --on-ip 127.0.0.1 --on-port 12345 --tproxy-mark 1
iptables -t mangle -A V2RAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 12345 --tproxy-mark 1
iptables -t mangle -A PREROUTING -j V2RAY

# 代理网关本机
iptables -t mangle -N V2RAY_MASK
iptables -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN
iptables -t mangle -A V2RAY_MASK -d 172.0.0.0/8 -p tcp -j RETURN
iptables -t mangle -A V2RAY_MASK -d 172.0.0.0/8 -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1
iptables -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -j V2RAY_MASK

# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT
# ***************

/usr/bin/v2ray -config /etc/v2ray/config.json &

exec "$@"