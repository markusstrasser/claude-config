# Disk Preflight — Check Before Large Downloads

Before any download likely to exceed **10 GB** — `gsutil cp`, `curl`, `wget`,
`aria2c`, `modal volume get`, `rclone copy`, `git clone --filter=blob:none` on a
large monorepo, `huggingface-cli download` of a model — run a free-space check
on the destination directory and abort if free space is less than **1.5× the
expected payload**.

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
the user whether to relocate to a larger volume (e.g. `/Volumes/SSK1TB`) or
free space first. Do not start the download "and see how far it gets."
