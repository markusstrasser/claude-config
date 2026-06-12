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
