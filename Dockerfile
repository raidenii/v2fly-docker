FROM golang:alpine AS build

WORKDIR /tmp

ARG TAG

RUN apk add --no-cache ca-certificates git

RUN git clone -c advice.detachedHead=false --branch ${TAG} \
    --single-branch https://github.com/v2fly/v2ray-core src/v2ray-core \
    && cd src/v2ray-core \
    && go mod download \
    && CGO_ENABLED=0 go build -o /tmp/bin/v2ray -trimpath -ldflags "-s -w -buildid=" ./main

RUN mkdir -p ./etc \
    && echo "v2ray:x:7000:7000::/nonexistent:/sbin/nologin" >> ./etc/passwd \
    && echo "v2ray:!:::::::" >> ./etc/shadow \
    && echo "v2ray:x:7000:" >> ./etc/group \
    && echo "v2ray:!::" >> ./etc/groupshadow
    && chmod 400 /etc/shadow /etc/groupshadow

FROM scratch AS final

ARG TAG

LABEL maintainer="r2dh" \
      org.opencontainers.image.title="V2Fly Docker" \
      org.opencontainers.image.authors="r2dh" \
      org.opencontainers.image.url="https://github.com/raidenii/v2fly-docker" \
      org.opencontainers.image.source="https://github.com/v2fly/v2ray-core" \
      org.opencontainers.image.description="A Docker image for V2Fly" \
      org.opencontainers.image.version=$TAG

COPY --from=build /tmp/etc/* /etc/
COPY --from=build --chown=v2ray --chmod=755 /tmp/bin/v2ray /bin/v2ray

USER v2ray

ENTRYPOINT ["/bin/v2ray"]
