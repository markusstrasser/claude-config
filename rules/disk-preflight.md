# Disk Preflight — Check Before Large Downloads

Before any download likely to exceed **10 GB** — `gsutil cp`, `curl`, `wget`,
`aria2c`, `modal volume get`, `rclone copy`, `git clone --filter=blob:none` on a
large monorepo, `huggingface-cli download` of a model — run a free-space check
on the destination directory and abort if free space is less than **1.5× the
expected payload**.

**ROUTE check first, then space (2026-08-19):** before moving >10 GB through this
machine at all, ask whether the CONSUMER can run WHERE THE DATA ALREADY IS. "The CLI
needs local files" means local-to-wherever-the-CLI-runs — a $0.10 cloud CPU container
with the volume mounted turns a multi-hour home-bandwidth double-relay into minutes
(and removes laptop sleep/DNS as failure modes). The laptop is a relay of last resort,
not a default. (Evidence: arc-agi 2026-08-19 — 54 GB Modal-volume→laptop→Kaggle relay
planned at ~6 h and DNS-killed mid-download; operator caught it; the Modal-side
`kaggle datasets create` did the same job in ~6 min/dataset. AP9 class:
`scripts/modal_kaggle_dataset.py` docstring.)

```bash
df -h "$DEST_DIR"            # or: df -BG "$DEST_DIR" for parseable GB
# free_gb < payload_gb * 1.5  → abort, ask user to relocate or free space
```

If the payload size is unknown, probe first:
- `gsutil du -sh gs://bucket/path`
- `curl -sI URL | grep -i content-length`
- `modal volume ls VOL PATH`

## Why

Real failure (2026-05-15, genomics): agent ran `gsutil -m cp -r` for a 23 GB
dataset into the project cwd without checking. Main disk hit 99% (8.3 GiB
free), download failed midway, partial files left behind. Session lost to
cleanup.

## When NOT to apply

- Small files (<1 GB) — overhead not worth it.
- Streaming/piped downloads (`curl | tar -x`) that don't materialize the full
  payload on disk — but DO check if writing to disk after extraction.

## How to abort

If preflight fails: stop, report `dest=<path> free=<X GB> need=<Y GB>`, and ask
the user whether to relocate to a larger volume (`/Volumes/2TBPNY` — the only
external SSD; SSK1TB was retired 2026-06-24) or free space first. Do not start
the download "and see how far it gets."
