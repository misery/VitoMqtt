ARG ALPINE_VERSION=3.16

FROM alpine:$ALPINE_VERSION AS builder

ENV VCONTROLD=0.98.11
WORKDIR /src

RUN apk upgrade -a -U && apk add linux-headers cmake make g++ libxml2-dev

RUN wget -O vcontrold.tar.gz https://github.com/openv/vcontrold/releases/download/v$VCONTROLD/vcontrold_$VCONTROLD.orig.tar.gz && \
    tar xf vcontrold.tar.gz && cd vcontrold-${VCONTROLD} && \
    cmake . -B build -DMANPAGES=OFF && cmake --build build && cmake --install build


FROM alpine:$ALPINE_VERSION
RUN apk upgrade -a -U && apk add tini mosquitto-clients libxml2

COPY --from=builder /usr/sbin/vcontrold /usr/sbin/vcontrold
COPY --from=builder /usr/bin/vclient /usr/bin/vclient

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/vclient"]
