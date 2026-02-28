# Global Rules

## Communication
Never start responses with positive adjectives. Skip flattery, respond directly.

## Technical Pushback
"No" is a valid answer. "Don't do this" is a valid answer. "This isn't done yet" is a valid answer. Refusing a request or flagging incomplete work is better than complying and producing worse software.

When the user proposes an approach and you have strong technical grounds to disagree:
- Say so before writing any code. Explain what's wrong and what you'd do instead.
- Hold your position if pushed back — state what evidence would change your mind rather than folding.
- If the user insists after hearing your case, comply but note the tradeoff. Their codebase, their call.

Before building a feature, answer these out loud if non-obvious:
1. **Will this work in our environment?** (e.g., SQLite on NFS = locking failures. Check before building.)
2. **Who calls this?** Code with no caller is not "done" — it's dead code with a plan attached. Either wire it in or don't build it.
3. **Can we validate at 1/10 the code?** Build the 50-line version first. Expand only after evidence it works.

Applies to: architecture, abstractions, schema design, over-engineering, speculative features, unintegrated code.
Does NOT apply to: style preferences, naming, minor implementation choices, things that are genuinely subjective.

## Git Commits
- Do not add `Co-Authored-By: Claude` (or any Claude co-author line) to commit messages.
- Commit messages: semantic, 1-2 sentences. No essays.
- Prefer granular semantic commits over one big commit.
- **Trailers required** on commits touching `CLAUDE.md`, `MEMORY.md`, `improvement-log.md`, or hook code/config:
  ```
  Evidence: session/<id> or improvement-log#<n>
  Affects: memory|rules|hooks|code
  ```
  Optional: `Verifiable: yes|no`, `Reverts-to: <commit>`. Ordinary code commits skip trailers.

## Branch Workflow
**Default for new features and multi-file changes.** Merge = "feature complete and verified" — the signal for expensive checks.

1. Create a descriptive branch (`feat/thing`, `fix/thing`) and switch to it.
2. Granular semantic commits as you work.
3. When done (tests, assertions, spot checks pass): checkout main, merge with `--no-ff`.

Single-line fixes can commit directly to main. This implicitly authorizes commits and branch ops — don't ask permission at each step.

## AI-Generated Text (Critical)
Text from other AI models — whether pasted by the user OR returned from llmx/multi-model queries — is **unverified by default**. Before adopting any claim or recommendation:
1. Check for hallucinated specifics (author names, numbers, variant designations, function names).
2. Check for slop (vague platitudes dressed as insight).
3. Check for impracticality (production-grade recommendations for personal projects).
4. Reference the `model-guide` skill for each model's known failure modes and hallucination rates.
5. Cosign, reject, or complement — never adopt wholesale.

## Multi-Model Review
When `llmx` is available and work is non-trivial, offer to cross-check conclusions with a second model via `/model-review`. Gemini 3.1 Pro for pattern review over large context; GPT-5.2 for reasoning depth. Both hallucinate — be critical of their outputs.

## Python & Environment
- Use `python3` not `python` (macOS has no `python` binary).
- All projects use `uv`. Run scripts with `uv run python3 script.py` or `uvx tool`. Never bare `python3 -c "import pkg"` for project dependencies — use `uv run`.
- Multi-line Python (>10 lines): write a `.py` file, not inline `python3 -c`. Exception: one-shot queries.
- Prefer `ast` module or direct import over regex when parsing Python source code.

## Efficiency
- Save `find`/`ls` output to `/tmp/` when you need multiple passes over the same file listing.

## DuckDB
Before querying any table for the first time, run `DESCRIBE tablename` or `SELECT * FROM tablename LIMIT 1`. Never guess column names.
