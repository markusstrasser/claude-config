---
paths:
  - "**/*.py"
---

# Console Output Conventions

When writing Python scripts that produce terminal output, follow these patterns.
They work in Claude Code Bash (no TTY), Modal logs, pipes, AND direct terminal.

## Rules

1. **No `\r` carriage returns** — tqdm-style progress bars break in CC Bash and Modal. Use line-based progress instead.
2. **No raw ANSI escape codes** — they waste model tokens when captured. Use `sys.stdout.isatty()` detection or skip colors entirely.
3. **Unicode markers are free** — `✓ ✗ ! ▸ ● █ ░` render everywhere. Use them for status.
4. **Line-based progress** — print each step on a new line. Show `[3/10]` counters, not spinning bars.

## Helper module

agent-infra has `scripts/common/console.py` (`con.header/ok/warn/fail/kv/table`, `progress`, `status`). Elsewhere, print one line per step with the markers above.

## When NOT to use

- JSON output mode (`--json`) — structured data, not human output
- Log files — use stdlib `logging`
- One-line scripts — just `print()` is fine

## Redirected output

When running Python under `nohup`, pipes, or `> file` redirection:
- Always set `PYTHONUNBUFFERED=1` — `uv run` does NOT unbuffer Python's stdout
- Or add `os.environ.setdefault("PYTHONUNBUFFERED", "1")` near the top of long-running scripts
