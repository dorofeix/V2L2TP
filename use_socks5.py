#!/bin/env python3

import os
import sys
import json

ROOT_DIR = os.path.dirname(__file__)

argv = sys.argv[1:]
if argv:
    _server = argv[0].split(':', 1)
    _ip, _port = _server[0], ( int(_server[1]) if len(_server)==2 else 1080 )
    print("设定socks服务器:", argv[0])
    if len(argv)==3:
        print("设定socks用户凭证: ", argv[1], argv[2])
        _user = [{
            "user": argv[1],
            "pass": argv[2],
            "level": 0
        }]
    else:
        _user = []
    vmess_conf = {
        "protocol": "socks",
        "settings": {
            "servers": [
                {
                    "address": _ip,
                    "port": _port,
                    "users": _user
                }
            ]
        },
        "streamSettings": {"sockopt": {"mark": 255}}
    }
else:
    print("使用默认socks配置文件(./conf/socks5.json)")
    with open(ROOT_DIR + '/conf/socks5.json', encoding='utf-8') as f:
        vmess_conf = []
        for l in f: vmess_conf.append(l.rsplit('//', 1)[0].strip())
    vmess_conf = json.loads('\n'.join(vmess_conf))

print('生成配置文件...', end='')
with open(ROOT_DIR + '/res/v2ray.json', encoding='utf-8') as f:
    v2ray_conf = []
    for l in f: v2ray_conf.append(l.rsplit('//', 1)[0].strip())
v2ray_conf = json.loads('\n'.join(v2ray_conf))
v2ray_conf['outbounds'] = [
    vmess_conf,
    {
        "tag": "direct",
        "protocol": "freedom",
        "settings": {},
        "streamSettings": {"sockopt": {"mark": 255}}
    }
]
v2ray_conf['routing'] = {
    "rules": [{
        "type": "field",
        "ip": ["0.0.0.0/0"],
        "network": "udp",
        "outboundTag": "direct"
    }]
}
v2ray_conf = json.dumps(v2ray_conf, indent=2)
with open(ROOT_DIR + '/conf/v2ray.json', 'w') as f:
    f.write(v2ray_conf)
print('ok')

print('重启容器内v2ray进程...\n')
os.system("docker exec v2ray-l2tp sh /root/restart-v2ray.sh")
print('\nv2ray配置已更新')