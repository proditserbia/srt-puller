# prodit-srt-puller

FFmpeg-based **SRT puller sidecar** for **OvenMediaEngine (OME) 0.19** with full **GPU NVENC transcoding** support.

This setup:

- Pulls a **remote SRT stream** (caller mode)
- Pushes it into **OME’s SRT listener**
- Uses `-c copy` (zero transcoding in the puller)
- Offloads all encoding (ABR ladder, scaling, H.264 NVENC) to **OvenMediaEngine**
- Works inside Docker with NVIDIA runtime (CUDA/NVENC)

Ideal for production SRT ingest → GPU transcoding → HLS / LL-HLS / SRT output.

---

## Features

✅ SRT pull (caller mode)  
✅ Automatic reconnection (exponential backoff)  
✅ Pass-through into OME  
✅ Full NVENC ladder (1080p, 720p, 512p) from OME  
✅ HLS + LL-HLS ready  
✅ SRT listener output ready  
✅ Clean Dockerized environment

---

## Project Structure

```
prodit-srt-puller/
│
├── docker-compose.yml         # OME + SRT puller stack
│
├── srt-puller/
│   ├── entrypoint.sh          # FFmpeg auto-restart puller
│   ├── Dockerfile             # Alpine/FFmpeg image
│   ├── .env.example
│
├── ome/
│   ├── Server.xml             # NVENC-enabled OME config
│   ├── Dockerfile             # CUDA/NVENC-enabled OME build
│
└── README.md
```

---

## Requirements

- Linux host with **NVIDIA GPU**
- Recent **NVIDIA drivers**
- Docker + Docker Compose v2
- `nvidia-container-toolkit` installed

Verify:

```bash
nvidia-smi
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/proditserbia/prodit-srt-puller.git
cd prodit-srt-puller
```

Create `.env`:

```bash
cp .env.example .env
```

Edit `.env`:

```
# Remote SRT source (caller)
SRT_SOURCE_URL=srt://YOUR-SOURCE:PORT?passphrase=xxxx

# OME SRT listener (inside docker network)
OME_HOST=ome
OME_PORT=9999

# Must match streamid in OME configuration
SRT_STREAMID=default/app/demo
SRT_LATENCY=200000
```

---

## Start the stack

Build and run:

```bash
docker compose up -d --build
```

Check running services:

```bash
docker ps
```

You should see:

- `ome`
- `srt-puller`

---

## Verify GPU (NVENC) is active

Inside the OME container:

```bash
docker exec -it ome nvidia-smi
```

During active streaming you should see GPU utilization.

Additionally, OME logs must show NVENC usage:

```
Codec(1, H264, nvenc:0)
```

Or via API:

```bash
curl http://localhost:8081/v1/streams
```

---

## Playback URLs

### HLS:
```
http://HOST:3333/app/demo/master.m3u8
```

### LL-HLS:
```
http://HOST:3333/app/demo/master.llhls.m3u8
```

### SRT output (Listener):
```
srt://HOST:9998?mode=caller&latency=200000&streamid=default/app/demo/master
```

Test via FFplay:

```bash
ffplay "srt://HOST:9998?mode=caller&latency=200000&streamid=default/app/demo/master"
```

---

## Logging

### SRT Puller logs:
```bash
docker logs -f srt-puller
```

### OME logs:
```bash
docker logs -f ome
```

---

## Stopping the stack

```bash
docker compose down
```

---

## Notes

- SRT puller **never** transcodes — only passes through.
- OME performs:
  - H.264 NVENC encoding
  - Multiple resolution ladder
  - Audio passthrough and/or transcode
  - HLS/LL-HLS packaging
- Supports production-grade SRT ingest with automatic reconnection.

---

## License

MIT License — freely usable in commercial and private projects.
