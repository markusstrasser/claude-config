# llmx Transport Routing — hard rules only

Invocation, flags, subcommands, gotchas, Python patterns: **llmx-guide skill**. Model and cosigner choice: **model-guide**. Research-tool routing: research skill `references/tool-routing.md`. Agent mirror: `llmx info --write-mirror` → `~/.claude/cache/llmx-routing.json`.

- Prompt is POSITIONAL in `llmx chat`; `-p` is `--provider` (`llmx vision` inverts this). Always `-o FILE`, never `> file`.
- **Claude: subscription only** (default / `--subscription`); metered API needs explicit `-p anthropic-direct`. "Credit balance is too low" means you hit API-key billing, not subscription auth.
- Default GPT is `gpt-6-astra` via `--subscription` (codex-cli, $0); `gpt-5.5` retired (exit 2). Gemini is paid API (`--flex` 50% off; pair with `--fallback` for background dispatch).
- **Exit 6 = billing exhausted, never retry. Exit 3 = transient rate limit** (llmx retries 429/503 itself; switch models only if it persists across calls).
- High/xhigh reasoning: pass `--timeout 1800`–`3600` and run in the background with `-o`. Never swap to a weaker model as a "fix"; read the exit code and stderr first.
- Subscription-CLI allowlist (2026-07-10; rederive via `llmx info`): claude-fable-5-1, claude-fable-5, claude-opus-5, composer-2.5, gpt-6-astra, gpt-5.6{,-luna,-sol,-terra}, cursor-grok-4.6-{low,medium,high,xhigh}[-fast] (4.5 slugs removed from Cursor 2026-09-05; Grok Build `grok -p` is a separate subscription lane).
- llmx is editable-installed from `~/Projects/llmx/`; changes propagate instantly.
