FROM alpine:3.20

RUN apk add --no-cache ffmpeg bash procps coreutils

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV SRT_SOURCE_URL=""
ENV OME_HOST="ome"
ENV OME_PORT="9998"
ENV SRT_STREAMID="default/app/demo"
ENV SRT_LATENCY="200000"
ENV RESTART_DELAY_SEC="5"
ENV MAX_BACKOFF_SEC="60"

ENTRYPOINT ["/app/entrypoint.sh"]
