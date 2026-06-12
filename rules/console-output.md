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

## Pattern: Inline (no dependencies)

For scripts without access to a console module:

```python
import sys

def _ok(msg):  print(f"  ✓ {msg}")
def _warn(msg): print(f"  ! {msg}")
def _fail(msg): print(f"  ✗ {msg}")
def _header(s): print(f"\n[{s}]")
def _progress(i, n, label=""):
    pct = i * 100 // n
    bar = "█" * (pct * 20 // 100) + "░" * (20 - pct * 20 // 100)
    print(f"  [{i}/{n}] {bar} {pct}%{f' — {label}' if label else ''}")
```

## Pattern: Meta project

Meta has `scripts/common/console.py` with full implementation:

```python
from common.console import con, progress, status, color_status

con.header("Section")
con.ok("check passed")
con.warn("something iffy")
con.fail("broken")
con.kv("Key", "value")
con.table(["Col1", "Col2"], [["a", "b"]])
progress(3, 10, "processing")

with status("loading data"):
    data = load()
# prints: ✓ loading data (0.3s)
```

## When NOT to use

- JSON output mode (`--json`) — structured data, not human output
- Log files — use stdlib `logging`
- One-line scripts — just `print()` is fine

## Redirected output

When running Python under `nohup`, pipes, or `> file` redirection:
- Always set `PYTHONUNBUFFERED=1` — `uv run` does NOT unbuffer Python's stdout
- Pattern: `PYTHONUNBUFFERED=1 nohup uv run python3 script.py > log 2>&1 &`
- Or add `os.environ.setdefault("PYTHONUNBUFFERED", "1")` near the top of long-running scripts
