# llmx Transport Routing

> Slimmed 2026-06-11: this file keeps only the always-needed routing essentials.
> Gotchas, footguns, subcommands (`vision`/`image`/`research`), codex dispatch,
> error codes, and Python patterns live in the **llmx-guide skill** — invoke it
> when writing non-trivial llmx calls or debugging a failure. Research-tool
> gotchas (Exa/Perplexity/S2) live in the research skill's `tool-routing.md`.

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

Key flags: `-m` model · `-s` system · `-f` file context (repeatable; use it
instead of `"$(cat file)"`) · `-o` output file · `-e` reasoning effort ·
`--flex` Gemini 50% off · `--schema` structured output.

## Transport Table

| Model | Transport | Cost |
|-------|-----------|------|
| Gemini (all) | paid API — free CLI retired 2026-05-31 | per-token; `--flex` = 50% off (best-effort; for background dispatch, pair with `--fallback`) |
| GPT-5.x | API (direct) | per-token |
| GPT-5.5 via `--lite bare`/`--lite research` | codex-cli (subscription) | $0 (ChatGPT plan) |
| claude-opus-4-8 via `--lite bare` | claude-cli (subscription) | $0 (OAuth sub; API key stripped) |

**Lite mode:** `--lite bare` (no tools, ~5K overhead) for training-knowledge
tasks; `--lite research` (research MCP only) for paper lookups. Allowlist:
`gpt-5.5`, `claude-opus-4-8` (+`gemini-3-flash-preview` back-compat — no cost
benefit for Gemini; use `--flex` instead).

## Model Selection / Deep Research → moved

Model + cosigner defaults: **model-guide skill** (single owner, beside Dispatch Economics).
`llmx research` provider routing: **research skill** `references/tool-routing.md`.
This file is TRANSPORT ONLY: invocation, flags, exit codes, timeouts.

## Hard Behavioral Rules

- **Exit 6 = billing exhausted (permanent — never retry). Exit 3 = transient rate limit.**
- **Gemini 503 → session-level fallback:** after the first 503, switch to GPT or Flash for the rest of the session; don't retry the same Gemini model.
- **xhigh dispatch: set `--timeout` explicitly and run it in the background.** The real lever is `--timeout` (it was always in `--help`; default 300s is what kills flag-less reasoning calls). xhigh on hard problems runs 30-45 min, so pass `--timeout 1800`-`3600` and use `run_in_background` (foreground Bash caps at 10 min); capture via `-o`. The auto-scaled default (high→600s, xhigh→1200s; llmx@d89db12) is only a safety net for callers who forget the flag — don't rely on it for long runs. Ceiling is 3600s; past an hour, async/batch is the right tool.
- **Never swap to a weaker model as a "fix"** — diagnose the dispatch (exit code, stderr JSON, `--debug` probe) before downgrading anything.
- llmx is editable-installed: changes in `~/Projects/llmx/` propagate instantly.
