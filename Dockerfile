FROM hwdsl2/ipsec-vpn-server:alpine

WORKDIR /root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
    && apk --update add --no-cache v2ray curl

COPY res/scripts /root/
RUN chmod +x /root/*.sh

COPY conf/v2ray.json /etc/v2ray/config.json

EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/opt/src/run.sh"]