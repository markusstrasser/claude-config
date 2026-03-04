# Global Rules

<communication>
Never start responses with positive adjectives. Skip flattery, respond directly.

## User Feedback (`#f`)
The user may prefix a message with `#f` to mark it as ground-truth feedback. The text after `#f` carries the meaning — no fixed categories. When you see `#f`, read the feedback carefully and act on it. Extraction: `just tags` (meta).
</communication>

<technical_pushback>
"No" is a valid answer. "Don't do this" is a valid answer. "This isn't done yet" is a valid answer. Refusing a request or flagging incomplete work is better than complying and producing worse software.

When the user proposes an approach and you have strong technical grounds to disagree:
- Say so before writing any code. Explain what's wrong and what you'd do instead.
- Hold your position if pushed back — state what evidence would change your mind rather than folding.
- If the user insists after hearing your case, comply but note the tradeoff. Their codebase, their call.

Before building a feature, answer these out loud if non-obvious:
1. **Does this already exist?** Check the vendor's GitHub org, changelog, SDKs, and API docs. Check OSS. Check if there's a library, API endpoint, or tool that does this. Five minutes of searching beats days of building.
2. **Will this work in our environment?** (e.g., SQLite on NFS = locking failures. Check before building.)
3. **Who calls this?** Code with no caller is not "done" — it's dead code with a plan attached. Either wire it in or don't build it.
4. **Can we validate at 1/10 the code?** Build the 50-line version first. Expand only after evidence it works.

Applies to: architecture, abstractions, schema design, over-engineering, speculative features, unintegrated code.
Does NOT apply to: style preferences, naming, minor implementation choices, things that are genuinely subjective.
</technical_pushback>

<git_rules>
## Git Workflow
All commits go to main. No branches. This implicitly authorizes commits — don't ask permission.

## Auto-Commit
After completing a task (feature, fix, refactor), commit your changes without being asked. Granular semantic commits — one logical change per commit. Update CLAUDE.md/README only if your changes warrant it. Don't stop and report "ready to commit" — just commit.

## Commit Message Format
```
[scope] Verb thing — why
```
- **`[scope]`** groups commits: feature scopes (`[pipeline]`, `[curation]`) or cross-cutting (`[research]`, `[pliability]`).
- **Verb** — be specific: wire, diagnose, enforce, extract, validate, measure, replace, drop. Not "Add" for everything.
- **Em-dash `—` separates what from why.** The "why" matters most. 72 chars max.
- **Body:** 1-3 lines when the subject isn't self-explanatory. Lead with motivation, not a restatement. No body needed for small/obvious changes. **Lower threshold for index-referenced docs** (files in research index tables, CLAUDE.md sections): add a one-line body naming the section/finding changed, so agents can decide whether to re-read.
- **No** `Co-Authored-By: Claude`. No trailers on routine commits.
- **Evidence trailers** (`Evidence:`, `Affects:`) required only for: classification/curation logic changes, governance files (CLAUDE.md, MEMORY.md, hooks).
- **`Source:` trailer** for cross-project provenance. When a commit implements a finding/decision from another repo, add `Source: repo@sha` (e.g., `Source: meta@f9dfcc9`). Greppable breadcrumb so agents can trace motivation across repos.
- Prefer granular semantic commits over one big commit.

Bad: `[research] Add 5 research memos from Tier 1-2 genomic analysis`
Good: `[research] Complete Tier 1-2 queries — ROH artifact, Gilbert's CV debunked`
</git_rules>

<ai_text_policy>
## AI-Generated Text (Critical)
Text from other AI models — whether pasted by the user OR returned from llmx/multi-model queries — is **unverified by default**. Before adopting any claim or recommendation:
1. Check for hallucinated specifics (author names, numbers, variant designations, function names).
2. Check for slop (vague platitudes dressed as insight).
3. Check for impracticality (production-grade recommendations for personal projects).
4. Reference the `model-guide` skill for each model's known failure modes and hallucination rates.
5. Cosign, reject, or complement — never adopt wholesale.

## Multi-Model Review
When `llmx` is available and work is non-trivial, offer to cross-check conclusions with a second model via `/model-review`. Gemini 3.1 Pro for pattern review over large context; GPT-5.2 for reasoning depth. Both hallucinate — be critical of their outputs.
</ai_text_policy>

<environment>
## Python & Environment
- Use `python3` not `python` (macOS has no `python` binary).
- All projects use `uv`. Run scripts with `uv run python3 script.py` or `uvx tool`. Never bare `python3 -c "import pkg"` for project dependencies — use `uv run`.
- Multi-line Python (>10 lines): write a `.py` file, not inline `python3 -c`. Exception: one-shot queries.
- Prefer `ast` module or direct import over regex when parsing Python source code.

## DuckDB
Before querying any table for the first time, run `DESCRIBE tablename` or `SELECT * FROM tablename LIMIT 1`. Never guess column names.

## Exa MCP
- Cap `numResults` at 5 (Exa defaults to 8 — too many for deliberate research).
- Process results between searches. Don't fire parallel Exa + S2 + paper-search for the same query.

## Efficiency
- Save `find`/`ls` output to `/tmp/` when you need multiple passes over the same file listing.
</environment>

<context_management>
## Context Continuations
After compaction or session continuation, read `.claude/checkpoint.md` if it exists. It contains branch, uncommitted changes, diff summary, and recent commits. Use this to infer what was being worked on — examine the recent commits, diffs, and modified files to determine the task. Don't ask the user for context; re-orient from the git state. **Resume work automatically** — don't wait for "continue from where you left off."

**Post-compaction verification:** Compaction summaries can hallucinate completed work. After resuming from compaction, run `git log --oneline -10` and verify any claimed commits actually exist before continuing. If the summary claims tasks were done but commits are missing, redo them — don't trust the summary.

## Context-Save Before Compaction
When approaching context limits, proactively save progress to `.claude/checkpoint.md` before compaction occurs. Include: current task, what's done, what's remaining, key decisions made, files modified. Don't stop tasks early due to context concerns — save state and continue after compaction.

## Daily Memory Logs
For session-specific notes (task progress, intermediate findings, WIP context), append to `memory/YYYY-MM-DD.md` in the project memory directory. For stable knowledge confirmed across sessions, update `MEMORY.md`. At session start, read today's and yesterday's daily logs if they exist. Don't load older daily logs — they're for forensic reference only.

## Post-Synthesis Completeness Check
After producing a synthesis from multiple inputs (model reviews, research rounds, multi-source analysis), mechanically verify: does every input item appear in the output? List any dropped items and justify the omission. Don't wait for the user to ask "are you sure you included everything?"

## Plan-Mode Handoff
After any research/analysis phase that consumed >50% context and produced actionable findings (model-review, researcher, multi-step exploration), offer a plan-mode handoff instead of trying to implement in remaining context. The plan file persists through the clear — it's the information bridge between the exploration phase and the execution phase. Don't offer if findings are purely exploratory with no concrete next steps.

## Plan & Work Tracking
Plans are ephemeral working documents. Never commit them to `docs/` or repo root.

- **Location:** `.claude/plans/` (gitignored)
- **Naming:** `{session_id[:8]}-{slug}.md` — read session ID from `.claude/current-session-id`
- **Content header:** Include full session ID, date, project name at top of plan file
- **At session start:** Scan `.claude/plans/` for recent plans. Check what's done (checkboxes). Don't redo completed work. Delete plans older than 14 days.
- **During work:** Update plan checkboxes as items complete
- **Never commit plans.** The git log is the record of what was done. Plans are scratch.
</context_management>

<execution>
## Execution After Plans
After exiting plan mode with user approval, begin implementing immediately. Don't pause to ask "shall I proceed?" or present a summary of what you're about to do — the plan was the summary. Execute.

**Multi-phase plans:** For plans with 3+ phases or spanning multiple repos, propose the first 1-2 phases and validate results before continuing. Don't execute all phases in a single pass — bugs compound across phases and the cleanup session costs more than the checkpoint. If a plan item is explicitly marked low-ROI or deferred, flag it before implementing — the plan author and the plan executor may be in different context states.

## Self-Sufficient Environment
If a file, dataset, or dependency is missing, download or install it yourself. Don't report "you need to download X" — use curl/wget/uv to fetch it. If a build fails (C headers, missing libs), diagnose and fix before reporting.

## Surface Deferred Alternatives
When research finds a viable alternative that you defer (e.g., use SDK instead of subprocess, use existing library instead of building), explicitly tell the user: "Found X, deferring because Y." Don't bury it in a doc section. The user shouldn't discover deferred alternatives externally.
</execution>

<subagent_usage>
## Subagent Usage
Subagents are context shields — they prevent exploration from bloating your main window.

### Delegate when
- **Parallel independent axes** — 3+ searches/reads with no dependency between them
- **Context isolation** — exploration touching >5 files where you only need a summary
- **Named agents** with persistent memory (researcher, session-analyst, entity-refresher, etc.)

### Do NOT delegate (use direct tools)
- **Single-tool tasks** — one Grep, one Read, one search. Just run it.
- **Under 3 tool calls** — subagent overhead (setup + summary parsing) exceeds the work
- **Sequential chains needing intermediate results** — edit-then-verify, query-then-analyze
- **Suggestions or brainstorming** — "suggest improvements" agents produce ungrounded output
- **Confirming what's already in context** — don't delegate to verify what a Grep would answer
- **Explore covers it** — if you're exploring a codebase, use Explore, not general-purpose

### Subagent safety
- **Analysis subagents must not commit.** Use `isolation: "worktree"` when spawning Explore or analysis agents that touch code. Worktree isolation gives them a separate branch — even if they commit, it doesn't land on main. No env var exists to detect subagent context from hooks, so worktree isolation is the architectural fix.
</subagent_usage>
