# prodit-srt-puller

FFmpeg-based SRT puller sidecar for OvenMediaEngine (OME) 0.19 with GPU (NVENC) transcoding.

- Pulls remote SRT stream (caller mode)
- Pushes it as SRT (caller) into OME SRT listener
- Uses `-c copy` (no transcoding in sidecar)
- OME 0.19 handles ABR ladder and GPU (NVENC) encoding

## Quick start

1. Clone the repo:

```bash
git clone https://github.com/proditserbia/prodit-srt-puller.git
cd prodit-srt-puller
