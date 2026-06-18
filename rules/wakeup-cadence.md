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

Evidence: 2026-06-17 anim-workbench — agent set a bare 1800s idle fallback while two grind
subagents ran; operator (#f+#g): "scheudle yourself better /loops then (like meta/heretic/subagent
runs/dreamer etc)". The fix is portfolio rotation, institutionalized here (global), not one session.

## Escalation is a file, never a block — the human is the OUTEST loop (added 2026-06-18, #f)
The outermost loop is the HUMAN. An autonomous loop **never ends a turn on a question and never
blocks waiting** for a human answer (= AutoResearch "ready means execute": finishing all prep then
asking "should I submit?" is the hidden zero-interaction violation — and it's our measured
`over_caution` blindspot cluster). When the loop needs the human, it writes and keeps going:
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
