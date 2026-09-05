# Engineering checks

Read for architecture or infrastructure proposals, substantial refactors, automation design, and plan writes. Apply checks only to the relevant decision; routine fixes do not need a project-wide survey. These are the detailed checks formerly in global CLAUDE.md.

### Pre-build checks (answer out loud when non-obvious)
1. **Does it exist? Did the problem actually occur?** Search vendor changelogs/SDKs, OSS, the codebase, and `ls ~/Projects` + sibling READMEs — by FUNCTIONALITY, not filename. New infra needs `git log --grep` incident history; none → hypothetical → don't build. Deferred plans: `git log --oneline -20 -- <paths>` first. Discovery across the full dependency tree is your standing job: a human handing you a canonical resource in your strong domain = failed discovery. Edge/moat-framed infra ("agents can't do this") owes a kill-switch eval first — race a frontier agent with web+fs+code on the task (Substrate: months built, killed by a one-day eval).
2. **Works in our environment?** (SQLite on NFS = locking failures.)
3. **Who calls this?** No caller → dead code with a plan attached. Wire it or don't build it.
4. **Validate at 1/10 the complexity first.** Minimize maintenance surface, not dev time.
5. **Native tool first** — `just` recipe, SQLite view, git hook, launchd plist, shell pipeline. New scripts carry a `Native-First:` trailer.
6. **New skills/checklists ship with a retrodiction calibration** — FN against real held-out incidents, FP against real shipped-good work. Uncalibrated = an instrument with unknown error rates (arc-agi research/2026-07-16-doe-calibration.md).

### Operational rules
- **Surface architectural ceilings** before compute-heavy exploration (>10 min); the user decides.
- **Explore before converging** on design/strategy/research: 5+ alternatives with different mechanisms, then select. Not for bug fixes or single-answer tasks.
- **Probe before action (VOI).** If the deciding information is cheap, get it first — `--help` before guessing flags, schema before consumers, both sides of a join, a 10-item probe + price check before any >1K-item batch (a skipped probe cost €94), bulk-test any hard filter on real data (a plausible rule hit 37% false positives).
- **Verify before asserting:** failure claims in logs before architectural fixes; the implementation (`--help`, grep, test) before documenting it; vendor pricing/features/flags by search, never training data.
- **Fix all confirmed findings, not "top N";** a deferral needs a per-item reason. An obvious, cheap, no-downside fix or a riskless probe is NEVER an offer — do it and report. "Want me to?" is for real tradeoffs, scope, or irreversible/outward-facing actions; an AskUserQuestion whose recommended option is "do the cheap thing" is the offer anti-pattern wearing a menu.
- **Default to breaking.** Delete legacy code, don't wrap it; no shims, re-exports, "// removed" comments. Interface changed → update all callers. Exception: a consumer the user names.
- **Read before planning:** the files a plan touches + `git log --oneline -10 -- <paths>`. Plans quoting counts or percentages include the command that produces them.
- **Write, don't Edit, structural rewrites** (>3 sections reordered) — sequential Edits compound corruption. Otherwise edit surgically: a whole-file rewrite for a small change costs output tokens and time for the same result (Fable 5.1 guide). **Validate schema shape before writing consumers.**
- **Acknowledge guardrails.** A hook blocked you → say what and why; never relocate the write to dodge it.
- **Transport failure ≠ capability value.** CLI hang / SDK error → fix the transport, keep the capability (8+ build-then-undo incidents from conflating them).
- **A reported defect is a symptom.** Same turn: sweep the artifact for the CLASS (every sibling), and ask whether the patch is at the right ALTITUDE. Making the user hand-walk you to each instance is the failure.
- **Fix tooling at the root; never let the same error recur.** Misbehaving tool/MCP/hook → root cause + fail-loud guard + test, never a silent workaround; record it where the project keeps a failure-pattern catalog. A recurrence of a cataloged error is a process failure.
- **Compare automation alternatives** before building new automation. **`git -C`** for cross-repo git — a bare `git add` from the wrong cwd is a silent no-op.
- **Global prose-config edits are self-serve WITH an `Evidence:` trailer** (operator ruling O1, 2026-07-12) — this file and `~/.claude/rules/*.md`; telos-level changes surface to the operator first. O2: advisory guards ENFORCE during autonomous runs (`.claude/loop-enforce-no-question-stop`), stay advisory interactively; a guard forcing >50% of the time gets retuned, not obeyed-around.


Applies to architecture, abstractions, schemas, over-engineering, speculative or unintegrated code — not to naming, style, or genuinely subjective choices.
