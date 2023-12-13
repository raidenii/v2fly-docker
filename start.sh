#!/bin/sh

PUID=${PUID:-911}
PGID=${PGID:-911}

addgroup -g ${PGID} v2ray
adduser -u ${PUID} -G v2ray -s /sbin/nologin -h /etc/v2ray -D v2ray
chown -R v2ray:v2ray /etc/v2ray

exec su-exec v2ray /usr/bin/v2ray "$@"
