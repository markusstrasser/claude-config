# Wakeup Cadence & Autonomous-Run Discipline — local deltas only

> Re-slimmed 2026-09-02 (Fable 5.1 tabula rasa): rules kept, incident narratives live in this
> file's git history and the cited anchors. The ScheduleWakeup TOOL description carries the
> interval guidance — not duplicated here.

## Cadence deltas
- ~15 routines / 24h / account across CronCreate + ScheduleWakeup + RemoteTrigger, ALL projects. Prefer a synchronous wait or a launchd job when either can do the job.
- Job < 270s → synchronous Bash wait. ScheduleWakeup #3 in one session for the same job class → wait synchronously.
- `Bash run_in_background` when a live Bash channel exists; ScheduleWakeup only when there isn't (autonomous loops, post-compaction handoffs).
- **Background jobs get reaped** (observed at ~2-4 min and at ~57 min). Split unbounded work per unit; after ~2 same-shape kills use `bgrun <name> -- <cmd>` (`~/Projects/skills/bin/bgrun`: nohup+disown, unbuffered log, `.done` marker with the rc) or `lane run <name> --repo <path> --brief <file>` for worktree-isolated worker lanes (`lane ls|stop|resume|reap`). Never pipe a background command through `| tail` (a kill swallows all output). Live peeks read `<name>.log.tmp`; a watcher on a file that can exist before it is meaningful tests CONTENT, not existence.

## Self-imposed dates are reminders, not timers
Never schedule against a "revisit by DATE" in a finding, ADR, or proposal — only against external state on a real clock (CI, deploy, vendor window). Promotion or cut is evidence- or operator-triggered.

## Productive portfolio, not idle fallback (hook-enforced: `posttool-background-portfolio.sh`)
Every autonomous run (`/loop`, `/goal`, pasted overnight driver) advances a PORTFOLIO each turn: build/grind (dispatch, wake on completion — never poll) · heretic (cross-model red-team of what just landed) · dreamer/evolver (verifier-gated search where one exists) · scout (find-what-exists before building) · meta/observe (what tooling the session keeps asking for; the trainer's own cockpit via `/interface-thinking`; full-spectrum ~$0 telemetry on the system under study, not only the ratchet metric). A tick that only re-arms a timer is the anti-pattern; an idle wakeup is a hang-survival net (1200s+) only.
- A dependency gates MEASUREMENT interpretation, not BUILDING — build the named next levers in worktree-isolated dispatches while a gate resolves.
- A closure that names candidates is a HANDOFF — file the successor in the same act or refuse in writing.
- A sign-off covers the ACTIVITY and BUDGET; parameters inside it are the agent's. Real gates: money thresholds, held-out reserves, irreversible or outward-facing actions, operator-only accounts. HUMAN.md is for those only.

## Escalation is a file, never a block
Don't yield on a question you could resolve, or block waiting, while other fronts can progress. Append asks to loop-root `HUMAN.md` (feeds the questions view; add a `session: <id>` line); the human answers async. Acting on an `[answered: …]` block leaves a receipt line: `consumed: YYYY-MM-DD <ref> — <what was done / deferred: why>`. Escalate STRUCTURE, not tactics: stale_count ≥2 → change a frame or environment constraint; ≥4 → HUMAN.md. Stop only when the blocker is unresolvable AND no front progresses AND continuing wastes resources — write the ask, then stop. Enforcement marker: `.claude/loop-enforce-no-question-stop`.

## Watching long local jobs
- Arm a Monitor when remaining-ETA < timeout, or set timeout ≥ 1.5× expected wall. Monitor caps at 60 min and does not chain — for longer jobs re-arm per chunk or watch a status-file artifact via a nohup'd poller with Monitor as the notify layer only. A fired monitor still emits a later timeout notification — noise.
- Teammates have no ScheduleWakeup, and their Monitor notifications can batch-queue until a SendMessage arrives — pair watchers with ground-truth status checks; a quiet teammate at a completion boundary may be notification-starved.
- Positive-control every watcher filter at arm time: (1) the pattern matches a synthetic event line; (2) it matches 0 lines of the log as it stands. Refuse to arm otherwise.
- Prefer making the JOB observable (per-item progress lines) over wider watches.

## Hindsight metaloop
Grade every substantive external find with a real `rg` over own memos and levers: NOVEL · HAD-PARTS · HAD-LEVER (worst). Every HAD-* obligates an architecture fix; HAD-LEVER rate → 0 is the metric. Major finds: blind-replay first (quarantine the artifact, pre-register bands outside the repo, fresh headless processes on a pre-find worktree — same-session subagents inherit the parent context). Reference: arc-agi `loop/HINDSIGHT.md`.

## Killing and liveness
- Never `pkill -f` a substring on multi-job trees. `pgrep -fl` first and read every match; anchor to a unique token; prefer the launch-recorded PID.
- Liveness: a quiet log + empty pgrep is grounds to CHECK, never a verdict. `ps -p <recorded PID>` plus its child tree decides.

## Subagent death classes (parse the failureReason)
| String | Class | Do |
|---|---|---|
| "hit your session limit · resets H:MMpm" | rate limit | parse the clock; ONE ScheduleWakeup at reset+2-5 min; never ask the operator for it, never poll early |
| "hit your monthly spend limit" | account limit, no clock | ONE periodic wakeup (1800-3600s) sending a single cheap resume-probe; the parent grades on-disk artifacts and closes inline meanwhile |
| 529 "Overloaded" | infra incident | after the 2nd, `curl status.claude.com/api/v2/status.json` before any nudge; ONE batch-resume timer (10-15 min); after a 3rd, pull the work inline (the parent lane usually survives); fill dead time with non-LLM work |
| "organization has disabled Claude subscription access" | auth state | no nudge, no timer, no API-key switch (a billing decision); write the ask, work inline; re-dispatch one probe lane only after a `/login` is observed |
| "Your computer went to sleep mid-response" | local suspend | worktree edits survive; ONE SendMessage to the same agent ("git status/diff first, then continue"), never a re-dispatch; prevent with `nohup caffeinate -i -t <secs> &` |

An account-dead or incident-dead fleet is never an idle parent.
