#!/bin/env python3

import os
import json


print('生成配置文件...', end='')

ROOT_DIR = os.path.dirname(__file__)

with open(ROOT_DIR + '/conf/vmess.json', encoding='utf-8') as f:
    vmess_conf = []
    for l in f: vmess_conf.append(l.rsplit('//', 1)[0].strip())
vmess_conf = json.loads('\n'.join(vmess_conf))

with open(ROOT_DIR + '/res/v2ray.json', encoding='utf-8') as f:
    v2ray_conf = []
    for l in f: v2ray_conf.append(l.rsplit('//', 1)[0].strip())
v2ray_conf = json.loads('\n'.join(v2ray_conf))
v2ray_conf['outbounds'] = [vmess_conf]

v2ray_conf = json.dumps(v2ray_conf, indent=2)
with open(ROOT_DIR + '/conf/v2ray.json', 'w') as f:
    f.write(v2ray_conf)

print('ok')

print('重启容器内v2ray进程...\n')
os.system("docker exec v2ray-l2tp sh /root/restart-v2ray.sh")
print('\nv2ray配置已更新')