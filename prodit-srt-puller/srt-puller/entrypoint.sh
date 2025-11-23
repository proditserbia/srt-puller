#!/usr/bin/env bash
set -uo pipefail

LOG() {
  echo "[$(date --iso-8601=seconds)] [srt-puller] $*"
}

stop_requested=0
trap 'LOG "Stop requested (signal)"; stop_requested=1' TERM INT

SRT_SOURCE_URL="${SRT_SOURCE_URL:-}"
OME_HOST="${OME_HOST:-ome}"
OME_PORT="${OME_PORT:-9998}"
SRT_STREAMID="${SRT_STREAMID:-default/app/demo}"
SRT_LATENCY="${SRT_LATENCY:-200000}"

RESTART_DELAY_SEC="${RESTART_DELAY_SEC:-5}"
MAX_BACKOFF_SEC="${MAX_BACKOFF_SEC:-60}"

if [[ -z "$SRT_SOURCE_URL" ]]; then
  LOG "ERROR: SRT_SOURCE_URL is not set"
  exit 1
fi

DEST_URL="srt://${OME_HOST}:${OME_PORT}?mode=caller&latency=${SRT_LATENCY}&streamid=${SRT_STREAMID}"

LOG "Starting SRT puller"
LOG " Source: ${SRT_SOURCE_URL}"
LOG " Dest:   ${DEST_URL}"

backoff=${RESTART_DELAY_SEC}

while [[ "$stop_requested" -eq 0 ]]; do
  LOG "Launching ffmpeg..."

  ffmpeg \
    -loglevel info \
    -fflags +genpts \
    -i "${SRT_SOURCE_URL}" \
    -c copy \
    -f mpegts \
    "${DEST_URL}"

  exit_code=$?
  LOG "ffmpeg exited with code ${exit_code}"

  if [[ "$stop_requested" -ne 0 ]]; then
    LOG "Stop requested, not restarting ffmpeg"
    break
  fi

  LOG "Sleeping for ${backoff}s before restart..."
  sleep "${backoff}"

  backoff=$(( backoff * 2 ))
  if (( backoff > MAX_BACKOFF_SEC )); then
    backoff=${MAX_BACKOFF_SEC}
  fi
done

LOG "Exiting srt-puller"
