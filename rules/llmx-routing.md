# llmx Transport Routing

> Slimmed 2026-06-11: this file keeps only the always-needed routing essentials.
> Gotchas, footguns, subcommands (`vision`/`image`/`research`), codex dispatch,
> error codes, and Python patterns live in the **llmx-guide skill** — invoke it
> when writing non-trivial llmx calls or debugging a failure. Research-tool
> gotchas (Exa/Perplexity/S2) live in the research skill's `tool-routing.md`.

## Agent mirror (read before dispatch)

```bash
llmx info --write-mirror   # → ~/.claude/cache/llmx-routing.json
```

Transport facts only — model/cosigner economics stay in **model-guide**.

## Invocation Reference

```
llmx chat -m MODEL [OPTIONS] "PROMPT"
```

**Prompt is POSITIONAL (trailing arg). `-p` is `--provider`, NOT prompt** (in
`llmx chat`; `llmx vision` inverts this — there `-p` IS the prompt). Misuse now
returns an explanatory error (llmx@4859217).

| Pattern | Command |
|---------|---------|
| Simple query | `llmx chat -m gpt-5.5 "What is X?"` |
| Document review | `llmx chat -m gpt-5.5 -f doc.md "Summarize this"` |
| Long instruction | `llmx chat -m gpt-5.5 -s "You are a reviewer" -f doc.md -o out.md "Find all errors"` |
| Output to file | always `-o FILE`, never `> file` (and never shell redirects with `run_in_background`) |
| Probe transport | `llmx chat --dry-run --subscription -m MODEL -e max "ping"` |
| Critique preflight | `model-review.py --preflight` → `.model-review/preflight-latest.json` |

Key flags: `-m` model · `-s` system · `-f` file context (repeatable; use it
instead of `"$(cat file)"`) · `-o` output file · `-e` reasoning effort (`max`
maps per backend) · `--subscription` (alias for `--lite bare`) · `--dry-run`
· `--flex` Gemini 50% off · `--schema` structured output.

## Transport Table

| Model | Transport | Cost |
|-------|-----------|------|
| Gemini (all) | paid API — free CLI retired 2026-05-31 | per-token; `--flex` = 50% off (best-effort; for background dispatch, pair with `--fallback`) |
| GPT-5.x | API (direct) by default | per-token |
| GPT-5.6 family via `--subscription` / `--lite bare` | codex-cli (subscription) | $0 (ChatGPT plan) — gpt-5.5 RETIRED from the sub allowlist (observed 2026-07-10, exit 2) |
| Claude (all) via default / `--subscription` | claude-cli (subscription) | $0 (OAuth sub; API key stripped) |
| Claude metered API | `-p anthropic-direct` only | per-token (explicit opt-in) |

**Claude policy:** subscription default, **never API unless explicit**
(`-p anthropic-direct` or `api_only=True` in Python). If you see "Credit balance
is too low", you hit API-key billing — not subscription auth.

**Lite mode:** `--subscription` (canonical) or `--lite bare` (legacy alias) for
no-tools subscription routing; `--lite research` (research MCP only) for paper
lookups. Subscription-CLI allowlist (as-of 2026-07-10; rederive: trip the error or `llmx info`):
claude-fable-5, claude-opus-4-8, composer-2.5, gemini-3-flash-preview, gpt-5.6{,-luna,-sol,-terra},
grok-4.5. `gpt-5.5` retired — use `gpt-5.6`.

## Model Selection / Deep Research → moved

Model + cosigner defaults: **model-guide skill** (single owner, beside Dispatch Economics).
`llmx research` provider routing: **research skill** `references/tool-routing.md`.
This file is TRANSPORT ONLY: invocation, flags, exit codes, timeouts.

## Hard Behavioral Rules

- **Exit 6 = billing exhausted (permanent — never retry). Exit 3 = transient rate limit.**
- **Gemini 503 → auto-retried (llmx@0e24d5c).** llmx now retries 429/503/overload with backoff+jitter (`LLMX_MAX_RETRIES` default 4) before surfacing exit 3, so a single 503 self-heals — don't manually switch on the first one. Only switch to GPT/Flash if exit 3 PERSISTS across calls (sustained outage) or raise `LLMX_MAX_RETRIES`.
- **xhigh dispatch: set `--timeout` explicitly and run it in the background.** The real lever is `--timeout` (it was always in `--help`; default 300s is what kills flag-less reasoning calls). xhigh on hard problems runs 30-45 min, so pass `--timeout 1800`-`3600` and use `run_in_background` (foreground Bash caps at 10 min); capture via `-o`. The auto-scaled default (high→600s, xhigh→1200s; llmx@d89db12) is only a safety net for callers who forget the flag — don't rely on it for long runs. Ceiling is 3600s; past an hour, async/batch is the right tool.
- **Never swap to a weaker model as a "fix"** — diagnose the dispatch (exit code, stderr JSON, `--debug` probe) before downgrading anything.
- llmx is editable-installed: changes in `~/Projects/llmx/` propagate instantly.

- **grok-4.5 `--subscription` — FIXED 2026-07-17 (llmx `b2728f1`).** Bare `grok-4.5 --subscription` now resolves to Cursor's default slug `cursor-grok-4.5-high` (`GROK45_SUBSCRIPTION_DEFAULT`); the old xai-api mis-route (403) is gone. Lanes: `cursor-grok-4.5-{low,medium,high}[-fast]`. (`-p cursor -m grok-4.5-xhigh` from earlier notes was never a real lane — do not use `xhigh`.)
