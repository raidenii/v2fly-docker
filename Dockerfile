FROM golang:alpine AS build

WORKDIR /tmp

ARG TAG

RUN apk add --no-cache ca-certificates git

RUN git clone -c advice.detachedHead=false --branch ${TAG} \
    --single-branch https://github.com/v2fly/v2ray-core src/v2ray-core \
    && cd src/v2ray-core \
    && go mod download \
    && CGO_ENABLED=0 go build -o /tmp/bin/v2ray -trimpath -ldflags "-s -w -buildid=" ./main \
    && chmod +x /tmp/bin/v2ray

RUN mkdir -p ./etc \
    && echo "v2ray:x:7000:7000::/nonexistent:/sbin/nologin" >> ./etc/passwd \
    && echo "v2ray:!:::::::" >> ./etc/shadow \
    && echo "v2ray:x:7000:" >> ./etc/group \
    && echo "v2ray:!::" >> ./etc/groupshadow

FROM scratch AS final
LABEL maintainer="r2dh"

COPY --from=build /tmp/etc/* /etc/
COPY --from=build --chown=v2ray /tmp/bin/v2ray /bin/v2ray

USER v2ray

ENTRYPOINT ["/bin/v2ray"]
