FROM alpine:latest
LABEL maintainer="r2dh"

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY start.sh setup.sh ./

RUN set -ex \
    && apk add --no-cache ca-certificates su-exec \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x ./setup.sh \
    && ./setup.sh "${TARGETPLATFORM}" "${TAG}"

ENTRYPOINT ["/usr/local/bin/start.sh"]
