# Disk Preflight — Check Before Large Downloads

Before any download over **10 GB** (`gsutil cp`, `curl`, `wget`, `aria2c`, `modal volume get`, `rclone copy`, blob-filtered clones of large monorepos, `huggingface-cli download`):

1. **Route first.** Can the consumer run where the data already is? A $0.10 cloud CPU container with the volume mounted beats a multi-hour laptop relay; the laptop is the relay of last resort (arc-agi 2026-08-19, `scripts/modal_kaggle_dataset.py` docstring).
2. **Then space.** `df -h "$DEST_DIR"`; abort if free < 1.5× payload. Unknown payload: probe first (`gsutil du -sh`, `curl -sI URL | grep -i content-length`, `modal volume ls`).

On failure stop and report `dest=<path> free=<X GB> need=<Y GB>`, then ask whether to relocate to `/Volumes/2TBPNY` (the only external SSD) or free space. Never start "and see how far it gets."

Skip for payloads under 1 GB and for piped streams that never materialize on disk (but check if the extraction lands on disk).
