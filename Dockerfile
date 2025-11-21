ARG ALPINE_VERSION=3.22

FROM alpine:$ALPINE_VERSION AS builder

ENV VCONTROLD=0.98.12
WORKDIR /src

RUN apk --no-cache upgrade -a -U && apk --no-cache add linux-headers cmake make g++ libxml2-dev

RUN wget -O vcontrold.tar.gz https://github.com/openv/vcontrold/releases/download/v$VCONTROLD/vcontrold_$VCONTROLD.orig.tar.gz && \
    tar xf vcontrold.tar.gz && cd vcontrold-${VCONTROLD} && \
    cmake . -B build -DMANPAGES=OFF && cmake --build build && cmake --install build


FROM alpine:$ALPINE_VERSION
RUN apk --no-cache upgrade -a -U && apk --no-cache add mosquitto-clients libxml2 supervisor bash

COPY --from=builder /usr/sbin/vcontrold /usr/sbin/vcontrold
COPY --from=builder /usr/bin/vclient /usr/bin/vclient
COPY vcontrold.xml /etc/vcontrold/vcontrold.xml
COPY vito.xml /etc/vcontrold/vito.xml
COPY supervisord.conf /etc/supervisord.conf
COPY root /usr/local/bin
COPY commands /root/commands

CMD ["/usr/bin/supervisord"]
