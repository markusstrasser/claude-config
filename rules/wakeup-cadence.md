# Wakeup Cadence — local deltas only

> Slimmed 2026-06-12: the ScheduleWakeup TOOL description now ships the full cache-aware
> interval guidance (270s/300s/1200s windows, "never 300-1100s", idle defaults 1200-1800s)
> — don't duplicate it here. This file keeps only what the harness does NOT say.

- **Account-wide ceiling:** Anthropic enforces ~15 routines / 24h / account across
  `CronCreate` + `ScheduleWakeup` + `RemoteTrigger`, ALL projects combined. Even a perfectly
  cache-warm wakeup spends quota. Prefer a synchronous wait or a launchd job (local,
  zero-quota) when either can do the job.
- **Job < 270s → synchronous Bash wait, no ScheduleWakeup at all.** Empirical anchor:
  cache break-even is 1.4-2× hits per prefix (zylos.ai 2026-03-27) — short-interval wakeup
  loops for ~100s jobs burn cache 4-5× per run.
- **Diagnostic:** ScheduleWakeup #3 in one session for the same job class → the job is short
  enough to wait on synchronously. Stop scheduling, inline the wait.
- **Mechanism split:** `Bash run_in_background` when there's a live Bash channel to dispatch
  on; `ScheduleWakeup` only when there isn't (autonomous loops, post-compaction handoffs).
  They are not substitutes.
- **`run_in_background` jobs get REAPED — chunk anything with unbounded wall time (added
  2026-07-04).** Observed: a 9-game CRN screen dispatched with no `timeout` was killed by the
  harness at ~57 min (`task-notification status: killed`, arc-agi session f4fecc9a 21:25→22:22Z)
  — the exact ceiling is undocumented, so treat any single background dispatch expected to run
  >~40 min as a smell. Split multi-unit work (per-game, per-seed, per-file) into separate
  background dispatches so a reap loses one unit, not the whole run; a genuinely monolithic
  long job belongs in `nohup`/launchd with a log file, not `run_in_background`.

## Self-imposed dates are reminders, not timers (added 2026-06-16)
A "promote/cut ~DATE", "revisit by DATE", or "review on DATE" written in a finding, shadow,
ADR, or proposal is a REMINDER, not a trigger — nothing fires on it unless an agent acts.
- **Never `ScheduleWakeup` / `/schedule` / `CronCreate` against a self-imposed date.** Schedule
  only against external state that changes on a real clock (a CI run, a deploy, a vendor window,
  a cron someone else owns). "Our shadow says promote/cut on the 21st" is a note, not a clock.
- Don't cite a self-imposed date as a deadline ("due the 21st") or treat it as a gate.
- Promotion/cut is **evidence-or-operator-triggered** — it happens when the data crosses a
  threshold or the operator decides, on whatever day that is.

Evidence: 2026-06-16 — agent offered to `/schedule` a shadow's "promote/cut ~2026-06-21";
operator: "What happens on June 21st? Nothing. If we don't do it."

## Productive portfolio, not idle fallback (added 2026-06-17, #f+#g)
An autonomous /loop's wake-time is for WORK, not waiting. Don't make the loop's primary
content a bare idle "fallback if it hangs" tick — each turn should advance a PORTFOLIO of
fronts at different cadences, ROTATING across ticks:
- **build/grind** — dispatch subagent grinds; wake on their completion (harness auto-wakes; never poll).
- **heretic/adversarial** — cross-model red-team of what JUST landed: find what's wrong, challenge
  faithfulness / oracle non-vacuousness, before it accretes. (A gate that can't fail, a "faithful"
  repro that cheats the technique — catch it now.)
- **dreamer/evolver** — run the verifier-gated program search where one EXISTS and is in-scope
  (don't run a paused loop, don't fabricate a search).
- **meta/observe** — RSI: what process/tooling/hook/rule the session keeps asking for.
A tick that only re-arms a timer with zero work done is the anti-pattern. The account ceiling
(≤~15 routines/24h) still binds — "better loops" = each tick does REAL work, NOT more timers.
An idle fallback wake-up is valid ONLY as a hang-survival net BEHIND event-driven completion
(long delay 1200s+), never as the loop's purpose.

**Tick-open self-check (added 2026-07-04, from MIDDLE_MANAGER pattern):** before dispatching,
check the LAST 2 ticks against this contract — was there a heretic pass on what landed? a dreamer
pass before converging? or serial grind only? Drift you catch yourself is free; drift the operator
catches costs a session flag (happened 3×: 2026-06-17, 2026-06-19 ×2). Pre-registered kill rule:
one more operator drift-flag within 30d (by ~2026-08-03) → this instruction failed, revert it and
escalate to a structural fix (tick-counter the loop surface renders).

Evidence: 2026-06-17 anim-workbench — agent set a bare 1800s idle fallback while two grind
subagents ran; operator (#f+#g): "scheudle yourself better /loops then (like meta/heretic/subagent
runs/dreamer etc)". The fix is portfolio rotation, institutionalized here (global), not one session.

**APPLIES TO EVERY AUTONOMOUS RUN — not just `/loop` idle-ticks (added 2026-06-19, #g+#f, flagged 3×).**
A `/goal` run, a pasted overnight-driver prompt, or any self-directed session is EQUALLY subject to this —
the portfolio is the DEFAULT operating mode, not something you do only while waiting. **FIRST action of any
autonomous run: stand up the portfolio `/loop`** (a self-paced `/loop` whose tick ROTATES grind / heretic /
dreamer / meta and dispatches subagents in PARALLEL) — do NOT run single-threaded serial build→measure.
Self-check: if you're about to build/measure with no heretic on the last result and no dreamer before
converging, you've already drifted — set the loop. (Why this kept failing: the section read as `/loop`-only
guidance, so `/goal` runs skipped it — that framing is now explicitly closed.) Evidence: 2026-06-19 arc-agi —
operator flagged the missing portfolio TWICE in one session ("Are you running dreamer/heretic/outer loops
regularly?" → "you have to set /loops for all the metascaffolding … are the docs not wired in?").

## Escalation is a file, never a block — the human is the OUTEST loop (added 2026-06-18, #f)
The outermost loop is the HUMAN. An autonomous loop doesn't **yield on a question it could resolve
itself, or block waiting** when it could route the ask to a file and progress other fronts
(= AutoResearch "ready means execute": finishing all prep then asking "should I submit?" is the
hidden zero-interaction violation — and it's our measured `over_caution` blindspot cluster).
**Stopping is CORRECT, not a failure, when** the blocker is genuinely unresolvable AND no other
front makes real progress AND continuing would waste resources — write the ask to `HUMAN.md`, then
stop. Spinning to avoid stopping is itself the waste anti-pattern ("a tick that only re-arms a timer
with zero work done", above). Whether a given loop is held to "don't stop on resolvable asks" is an
**explicit per-loop policy the operator sets** (drop a `.claude/loop-enforce-no-question-stop`
marker), not something a hook decides unilaterally. When the loop needs the human but has real work
left, it writes and keeps going:
- **Append to the loop-root `HUMAN.md`** (the loop's human-outbox — the human-facing surface of the
  outermost loop), then continue on other portfolio fronts. Non-blocking by construction.
- `HUMAN.md` is a **FEEDER into the existing question-VIEW, not a new store** (agent-infra ADR
  2026-06-16-agent-question-convergence, invariant #1: no 5th queue). A project that already has a
  human-escalation store (`decisions-pending/`, `steward-proposals/`) keeps using it; `HUMAN.md` is
  the single scannable entry point the loop's SessionStart/tick surface renders. The human answers async.
- **Escalate STRUCTURE, not tactics.** stale_count≥2 (two ticks, 0 new findings or a metric drop) →
  change a *structural constraint* — question the frame/environment — **not** tactical params
  ("two stalls → fix the environment, don't tune harder inside the same frame"). stale_count≥4
  (structurally stuck) → append to `HUMAN.md`. Tuning harder inside a stuck frame IS the cognitive loop.

Source: Deli AutoResearch SKILL.md (DeepSeek, 2026-06; convergent-validation note in agent-infra
decisions/2026-06-13-rsi-outer-loop-skill.md). The mechanisms we already had; this institutionalizes
the two sharp deltas (non-blocking file escalation + structure-not-tactics pivot) globally.

## Monitor arming for long local jobs (added 2026-07-04, arc-agi goal run)
A Monitor armed at JOB LAUNCH burns its timeout window on the silent early phase: tonight a 1h
watch on a >1h TIER run expired BEFORE the event (needed re-arm), and two completed monitors fired
stale timeout notifications afterwards. Rules of thumb:
- Arm the watch when remaining-ETA < timeout (e.g. after a mid-run liveness check), not at launch;
  or set timeout ≥ 1.5× the job's FULL expected wall.
- A monitor whose event already fired still emits a timeout notification later — treat "[Monitor
  timed out]" for an already-processed event as noise, never re-arm reflexively.
- Prefer making the JOB observable (per-item progress lines to stderr) over compensating with
  wider watches — a silent hour-long log is the root cause (fixed in holdout_eval 7a63ea5).

## Hindsight metaloop — grade every external find "could we have derived it?" (added 2026-07-04, #g)
Scouting that only IMPORTS the frontier hides the more valuable signal: whether your own loop
SHOULD have produced the find. On every substantive external find (paper, system, SOTA result)
the scout/scholar front also grades, with a real search over your own artifacts (levers, memos,
measured walls — rg, not recall):
- **NOVEL** — needed data/results we didn't hold → no fault, normal intake.
- **HAD-PARTS** — components existed but nothing composed/prioritized them → selection/composition miss.
- **HAD-LEVER** — the idea itself sat in our library/memos → consumption miss (worst grade).
Every HAD-* verdict obligates an ARCHITECTURE fix (which contract/gate/render let it slip), not
just intake of the item. Grades are append-only calibration; HAD-LEVER rate → 0 is the metric of
the selection architecture. For MAJOR finds, run the blind-replay variant BEFORE deep-reading:
quarantine the artifact, pre-register pass bands outside the repo, dispatch context-free blind
ticks against a pre-find worktree, grade, then land. Reference implementation: arc-agi
`loop/HINDSIGHT.md` + `loop/idea_backlog.py` (consume-or-justify obligation ledger — kills and
obligations get EQUAL in-context standing; skips resurface after 14d).

Evidence: 2026-07-04 arc-agi — OPINE-World took ARC-AGI-3 SOTA composed of mechanisms that sat
in our own lever library for 2 weeks (L-WM-004 extracted 06-20, status "proposed", fitness null;
437 levers, ZERO fitness values). Operator #g: "a metaloop that functions like this very
session — find clear misses, then fix the architecture so we could've discovered it ourselves."
