# Marker PDF→Markdown — Use Modal, Not Local

PDF → markdown extraction with `marker-pdf`: default to Modal-hosted Marker 2 (`corpus ingest --pdf …`, L4 + in-container vLLM). A 41-page PDF costs ~7 min / ~$0.09 cold and ~85 s / ~$0.02 warm, so batch PDFs to share a warm container. Local `--parser marker` is text-layer only (we run no local VLM); figures, equations and OCR need Modal.
Details, direct-invoke pattern, deploy check, and local-is-fine exceptions: `~/Projects/skills/modal/references/marker-pdf-extraction.md`.
