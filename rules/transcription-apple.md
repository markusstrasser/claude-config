# Speech transcription — Apple SpeechAnalyzer via `yap`, NEVER whisper

Audio/video → text on this machine: use `~/.local/bin/transcribe <file>`
(wraps brew-installed `yap`, Apple SpeechAnalyzer, on-device, macOS 26+;
handles video containers directly, writes `<file>.json` beside the input).
Latest voice memo: `transcribe --latest-memo`.

Do NOT reach for whisper in any form (whisper-cli, mlx_whisper, uvx
downloads of whisper models) — retired here; operator rejected a whisper
dispatch on 2026-07-22 ("we're using apple transcribe new api now").
Apple lane is faster, no model blob, no download.

If `yap` is missing: `brew install yap` — don't fall back to whisper.
