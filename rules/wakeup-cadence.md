# Wakeup Cadence & Autonomous-Run Discipline — local deltas only

> Slimmed 2026-06-12; re-slimmed 2026-07-13 (rules kept verbatim in meaning; incident
> narratives live in git history of this file + the cited anchors). The ScheduleWakeup TOOL
> description ships the full cache-aware interval guidance — don't duplicate it here.

## Cadence deltas (what the harness does NOT say)

- **Account-wide ceiling:** ~15 routines / 24h / account across `CronCreate` +
  `ScheduleWakeup` + `RemoteTrigger`, ALL projects. Prefer a synchronous wait or a launchd
  job (local, zero-quota) when either can do the job.
- **Job < 270s → synchronous Bash wait, no ScheduleWakeup.** Cache break-even is 1.4-2× hits
  per prefix (zylos.ai 2026-03-27); short-interval wakeups for ~100s jobs burn cache 4-5×.
- **Diagnostic:** ScheduleWakeup #3 in one session for the same job class → wait synchronously.
- **Mechanism split:** `Bash run_in_background` when a live Bash channel exists; `ScheduleWakeup`
  only when there isn't (autonomous loops, post-compaction handoffs). Not substitutes.
- **`run_in_background` jobs get REAPED — chunk unbounded wall time.** Observed kills at ~57 min
  AND (not only time-based) at ~2-4 min; the same commands under `nohup`+`disown` completed.
  Treat any single background dispatch >~40 min expected wall as a smell; split per-unit
  (per-game/seed/file) so a reap loses one unit. After ~2 same-shape kills, switch to
  `nohup` + status file. NEVER pipe a background command through `| tail -N` (tail buffers
  until EOF — a kill swallows ALL output); redirect to a log with `PYTHONUNBUFFERED=1`.
  (Evidence: arc-agi f4fecc9a 2026-07-04; 2026-07-05 4-run stop.)

## Self-imposed dates are reminders, not timers (2026-06-16)

A "promote/cut ~DATE" / "revisit by DATE" in a finding, shadow, ADR, or proposal is a REMINDER —
nothing fires unless an agent acts. Never `ScheduleWakeup`/`/schedule`/`CronCreate` against a
self-imposed date; schedule only against external state on a real clock (CI, deploy, vendor
window). Don't cite one as a deadline. Promotion/cut is evidence-or-operator-triggered.
(Operator: "What happens on June 21st? Nothing. If we don't do it.")

## Productive portfolio, not idle fallback (2026-06-17, #f+#g; 7 operator flags → hook)

An autonomous run's wake-time is for WORK. Each turn advances a PORTFOLIO of fronts, rotating:
- **build/grind** — dispatch subagent grinds; wake on completion (harness auto-wakes; never poll).
- **heretic/adversarial** — cross-model red-team of what JUST landed, before it accretes.
- **dreamer/evolver** — run the verifier-gated program search where one EXISTS and is in-scope.
- **scout** — find-what-exists (external frontier + own memos) before building.
- **meta/observe** — RSI: what process/tooling/hook the session keeps asking for. Explicitly
  includes the TRAINER'S OWN COCKPIT (#g 2026-07-04): input representations, UX/DX — the named
  tool is **`/interface-thinking`**, invoke it, don't freestyle. AND full-spectrum telemetry on
  the system under study (#g 2026-07-06): every measurement surface owes the ~$0 analytics suite
  (per-item panels, zero-vs-nonzero decompositions, coverage, dispersion) PROACTIVELY — a
  ratchet metric and a debugging suite are different instruments; owe both.

A tick that only re-arms a timer with zero work is the anti-pattern; an idle fallback wake-up is
valid only as a hang-survival net (1200s+) behind event-driven completion. Enforcement is the
hook **`~/Projects/skills/hooks/posttool-background-portfolio.sh`** (tick-open self-check
retired 2026-07-04 — instruction-level fixes failed 4× for this class; pair-rule applied).

Portable rules distilled from the later flags (5th-7th, arc-agi 2026-07-04→06):
- **A dependency gates MEASUREMENT interpretation, not BUILDING.** While a gate resolves, named
  next levers get BUILT in worktree-isolated dispatches (merge-after-gate); heretic/scholar on a
  just-landed verdict launches the same turn. A watcher-only turn with unblocked buildable
  levers on the board = the bare idle tick.
- **A closure that names candidates is a HANDOFF, not an ending** — file the successor in the
  same act or refuse in writing (reference: arc-agi `loop/idea_backlog.py done --spawns`).
  When a free build lane exists, sweep recent memos/rows for named-but-unqueued levers before
  filling the lane with hygiene.
- **A sign-off covers the ACTIVITY and BUDGET; parameter choices inside it are the agent's.**
  Real gates: codified money thresholds, held-out reserves, outward-facing/irreversible actions,
  operator-only accounts. HUMAN.md is for those, not a parking lot for agent-decidable calls.
  (arc-agi memory: feedback_overgating_real_gates.md)

**APPLIES TO EVERY AUTONOMOUS RUN — not just `/loop` ticks (2026-06-19, flagged 3×).** A `/goal`
run or pasted overnight driver is equally subject. FIRST action of any autonomous run: stand up
the portfolio `/loop`; never single-threaded serial build→measure. Self-check: about to
build/measure with no heretic on the last result and no dreamer before converging → drifted.

## Escalation is a file, never a block — the human is the OUTEST loop (2026-06-18, #f)

An autonomous loop doesn't yield on a question it could resolve, or block waiting, when it can
route the ask to a file and progress other fronts (this is the measured `over_caution` cluster).
Stopping is CORRECT only when the blocker is genuinely unresolvable AND no other front makes
real progress AND continuing wastes resources — write the ask, then stop.
- Append to loop-root `HUMAN.md` (a FEEDER into the existing question-VIEW, not a 5th queue —
  ADR 2026-06-16-agent-question-convergence); repos with an escalation store keep it. Human
  answers async. Per-loop "don't stop on resolvable asks" enforcement = operator-set
  `.claude/loop-enforce-no-question-stop` marker.
- **Escalate STRUCTURE, not tactics.** stale_count≥2 → change a structural constraint (frame/
  environment), not tactical params. stale_count≥4 → append to `HUMAN.md`. Tuning harder inside
  a stuck frame IS the cognitive loop.
(Source: Deli AutoResearch; convergence note in agent-infra decisions/2026-06-13-rsi-outer-loop-skill.md.)

## Monitor arming for long local jobs (2026-07-04)

- Arm the watch when remaining-ETA < timeout (e.g. after a mid-run liveness check), not at
  launch; or set timeout ≥ 1.5× full expected wall.
- A monitor whose event already fired still emits a later timeout notification — noise; never
  re-arm reflexively.
- Prefer making the JOB observable (per-item progress lines) over wider watches.
- **Positive-control every watcher filter AT ARM TIME — a PAIR (F12, promoted 2026-07-12):**
  (1) synthetic POSITIVE — the pattern must match the expected event line (echo it, or grep a
  log where the event class already occurred); (2) current-log ZERO-MATCH — a future event's
  pattern must match 0 lines in the log AS IT STANDS (>0 ⇒ it cannot discriminate your event;
  multi-arm logs sharing a line format are the standing hazard). Refuse to arm on failure.
  Poll-loop watchers owe the same check on their status-command parse. (3 dead watchers in one
  day 2026-07-06; a synthetic-positive-passing pattern still no-op'd 19 min on a shared format.)

## Hindsight metaloop — grade every external find "could we have derived it?" (2026-07-04, #g)

On every substantive external find (paper, system, SOTA), the scout/scholar front grades with a
real search over own artifacts (rg over levers/memos/walls, not recall):
**NOVEL** (needed data we didn't hold) · **HAD-PARTS** (components existed, nothing composed
them) · **HAD-LEVER** (idea sat in our library — worst). Every HAD-* verdict obligates an
ARCHITECTURE fix, not just intake. HAD-LEVER rate → 0 is the metric. For MAJOR finds run the
blind-replay variant BEFORE deep-reading: quarantine artifact, pre-register bands outside the
repo, dispatch blind ticks as FRESH HEADLESS PROCESSES on a pre-find worktree (same-session
subagents inherit the parent context snapshot — confirmed leak 2026-07-04); grep arm outputs
for quarantine-unique strings. Reference implementation: arc-agi `loop/HINDSIGHT.md` +
`loop/idea_backlog.py`. (Trigger incident: OPINE-World SOTA composed of levers that sat 2 weeks
in our library, fitness null.)

## pkill discipline for job trees (2026-07-12, two same-day incidents)

Never `pkill -f` a SUBSTRING pattern against multi-job trees (`*forkDC*` matched `forkDCH` —
killed a healthy train client; an earlier pkill matched a concurrent canary). Before any pkill
on shared infra: (1) `pgrep -fl <pattern>` FIRST and read every match; (2) anchor the pattern
to a unique token (full path, exact out-dir); (3) prefer the launch-recorded PID. The pgrep
preview is the kill's probe-before-action.

## Session-limit kills carry their own reset clock (2026-07-12)

Subagents dying with failureReason "You've hit your session limit · resets H:MMpm (TZ)" print
the reset time IN THE STRING — parse it, self-arm ONE ScheduleWakeup at reset+2-5min to
redispatch the dead lane. Never ask the operator for a clock the harness prints; never poll
before the parsed reset. (arc-agi 41f9b649.)

**Monthly-SPEND-limit kills print NO reset clock (2026-07-17)** ("hit your monthly spend limit ·
raise it at claude.ai/settings/usage") — the unblock is an operator account action at an unknown
time. Do NOT sit dead until the operator types "go on": arm ONE periodic ScheduleWakeup
(1800-3600s) whose tick sends a single cheap resume-probe to one dead lane; on success, resume
the fleet and report. Meanwhile the PARENT session (still alive) grades on-disk artifacts and
takes over closes inline — an account-dead fleet is not an idle parent. (arc-agi 2026-07-17:
fleet dead 3h until operator prompt; every completed-but-ungraded artifact was closeable inline
the whole time.)

**Liveness verdicts: a staleness signal LOCATES, exact-PID DECIDES (2026-07-17).** A quiet log +
empty pgrep is grounds to CHECK, never to declare a job reaped: log-write patterns are
runner-specific (flush-once-at-completion runners have silent logs mid-run by design), and
substring pgrep drowns in peer noise. The deciding check is `ps -p <exact recorded PID>` on the
launch-recorded PID + child tree. (arc-agi false-reap alarm 2026-07-17: parent declared a live
23-min episode dead from log staleness; agent's exact-PID check refuted it.)
