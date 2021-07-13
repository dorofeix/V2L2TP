# V2L2TP

## 用途

* 在Docker容器上搭建一个L2TP服务器
* 在Docker容器上实现一个透明代理网关
* 网关将L2TP客户端的流量转发至vmess或socks5代理
* 其他设备拨入这个L2TP VPN即可拥有全局透明代理

## 安装

1. 需要安装好Docker、Python3
2. 使用一个能正常操作Docker的账户，可以将账户加入docker组，或切换到root账户
3. clone这个git库到本地
4. 给项目目录下的 `*.sh`、`*.py` 文件赋予执行权限
5. 编辑 `conf/vpn.env` 文件，需要配置 `VPN_IPSEC_PSK`、`VPN_USER`、`VPN_PASSWORD` 这些参数，登陆L2TP VPN要用到
6. 编辑 `conf/vmess.json` 文件，配置vmess代理
7. 编辑 `conf/socks5.json` 文件，配置默认socks5代理，可选
8. 执行 `bash ./install.sh` ，会生成Docker镜像并启动容器，若容器正常运行就可以拨入L2TP VPN了，初始安装状态下流量不会经vmess或socks5代理
9. 执行 `python3 use_vmess.py` 切换到vmess代理
10. 或执行 `python3 use_socks5.py` 切换到默认的socks5代理
11. 参考下面的命令

```
$ git clone ... V2L2TP
$ cd V2L2TP
$ nano conf/vpn.env
......
$ nano conf/vmess.json
......
$ nano conf/socks5.json
......
$ chmod +x *.sh *.py
$ ./install.sh
......
$ docker ps # 检查容器是否正常启动
$ ./use_vmess.py
```

## 用法

* 执行 `python3 use_vmess.py` 切换到 `conf/vmess.json` 文件设定的vmess代理
* 执行 `python3 use_socks5.py` 切换到 `conf/socks5.json` 文件设定的默认socks5代理
* 执行 `python3 use_socks5.py 66.66.66.66:1080` 切换到 `66.66.66.66:1080` 的socks5代理
* 执行 `python3 use_socks5.py 66.66.66.66:1080 user pass` 切换到 `66.66.66.66:1080` 的socks5代理，并使用账户 `user` ，密码 `pass`
* 可以修改 `conf/v2ray.json` 文件，然后执行 `restart-v2ray.sh` ，容器内的V2Ray进程会重启，修改后的配置文件会生效
* 容器默认不会开机启动，修改 `install.sh` 文件，在启动参数加入 `--restart=always` 即开机启动
* 执行 `uninstall.sh` ，会删除生成的Docker镜像和容器，再执行 `install.sh` 即重新安装

## 目录文件说明

* `/conf/` 存放配置文件
* `/conf/socks5.json` 默认socks5代理配置
* `/conf/vmess.json` vmess代理配置
* `/conf/v2ray.json` V2Ray运行配置，挂载到容器内的 `/etc/v2ray/config.json` 文件
* `/conf/vpn.env` L2TP服务器的配置文件，包括预共享密钥、用户名、密码等
* `/res/` 存放一些静态文件
* `/Dockerfile` 用于生成Docker镜像
* `/install.sh` 安装脚本
* `/README.md` 说明文件
* `/restart-v2ray.sh` 重启v2ray进程，重载入配置文件
* `/restart.sh` 重启容器
* `/start.sh` 从停止状态启动容器
* `/stop.sh` 停止容器
* `/uninstall.sh` 卸载脚本
* `use_socks5.py` 切换到socks5代理
* `use_vmess.py` 切换到vmess代理

## 其他说明

* 使用了 [hwdsl2/ipsec-vpn-server:alpine](https://hub.docker.com/r/hwdsl2/ipsec-vpn-server) 作为L2TP服务器的基础镜像，Github链接 [在此](https://github.com/hwdsl2/docker-ipsec-vpn-server)
* 因许多socks5代理服务器不支持代理UDP流量，当切换为socks5代理时，UDP流量默认设定为由网关服务器直连，DNS等UDP流量不会经过socks5代理
* 在各种设备上连接L2TP VPN可参考 [这个页面](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-zh.md)