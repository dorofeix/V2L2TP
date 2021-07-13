#!/bin/sh

ROOT_DIR=$(dirname $(readlink -f "$0"))

docker build -t v2l2tp "$ROOT_DIR"

docker run \
    --name v2ray-l2tp \
    --env-file "$ROOT_DIR/conf/vpn.env" \
    -v "$ROOT_DIR/conf/v2ray.json:/etc/v2ray/config.json" \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d --cap-add=NET_ADMIN \
    --device=/dev/ppp \
    --sysctl net.ipv4.ip_no_pmtu_disc=1 \
    --sysctl net.ipv4.ip_forward=1 \
    --sysctl net.ipv4.conf.all.accept_redirects=0 \
    --sysctl net.ipv4.conf.all.send_redirects=0 \
    --sysctl net.ipv4.conf.all.rp_filter=0 \
    --sysctl net.ipv4.conf.default.accept_redirects=0 \
    --sysctl net.ipv4.conf.default.send_redirects=0 \
    --sysctl net.ipv4.conf.default.rp_filter=0 \
    --sysctl net.ipv4.conf.eth0.send_redirects=0 \
    --sysctl net.ipv4.conf.eth0.rp_filter=0 \
    v2l2tp