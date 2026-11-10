# Wakeup Cadence & Autonomous-Run Discipline — local deltas only

> Re-slimmed 2026-09-02 (Fable 5.1 tabula rasa): rules kept, incident narratives live in this
> file's git history and the cited anchors. The ScheduleWakeup TOOL description carries the
> interval guidance — not duplicated here.

## Cadence deltas
- ~15 routines / 24h / account across CronCreate + ScheduleWakeup + RemoteTrigger, ALL projects. Prefer a synchronous wait or a launchd job when either can do the job.
- Job < 270s → one synchronous call: `until <done-test>; do sleep 5; done` or a Monitor. ScheduleWakeup #3 in one session for the same job class → wait synchronously.
- `Bash run_in_background` when a live Bash channel exists; ScheduleWakeup only when there isn't (autonomous loops, post-compaction handoffs).
- **Background jobs get reaped** (observed at ~2-4 min and at ~57 min). Split unbounded work per unit; after ~2 same-shape kills use `bgrun <name> -- <cmd>` (`~/Projects/skills/bin/bgrun`: nohup+disown, unbuffered log, `.done` marker with the rc) or `lane run <name> --repo <path> --brief <file>` for worktree-isolated worker lanes (`lane ls|stop|resume|reap`). Quitting the terminal app kills its whole process lineage, `setsid`/`nohup` included (Rex, 2026-10-26 20:33: three bgrun supervisors and a lane worker); a job that must outlive the terminal runs as `bgrun --launchd <name> -- <cmd>` (gui-domain launchd agent, same `.done`/`.log`; `lane run` workers stay exposed). In unattended lanes (`-p`, SDK, CI, cloud) background Bash stops at its `timeout` (default 30 min, max 2 h, CC ≥2.1.288): pass `timeout` up to 7200000 there; `bgrun` for longer. Never pipe a background command through `| tail` (a kill swallows all output). Live peeks read `<name>.log.tmp`; a watcher on a file that can exist before it is meaningful tests CONTENT, not existence.

## Self-imposed dates are reminders, not timers
Never schedule against a "revisit by DATE" in a finding, ADR, or proposal — only against external state on a real clock (CI, deploy, vendor window). Promotion or cut is evidence- or operator-triggered.

## Productive portfolio, not idle fallback (hook-enforced: `posttool-background-portfolio.sh`)
Every autonomous tick advances a portfolio: build/grind (dispatch, wake on completion) · red-team what landed · verifier-gated search · scout what exists · observe the tooling the session keeps asking for · run the operator's next thought step (`operator-deck next`: his usual steering prompts, rotated per project; do the one whose trigger holds and log it). A tick that only re-arms a timer is the anti-pattern; an idle wakeup is a hang-survival net (1200s+) only. A dependency gates measurement, not building. A closure naming candidates is a handoff: file the successor or refuse in writing. Real gates are money, held-out reserves, irreversible or outward-facing actions, operator-only accounts; HUMAN.md is for those only.

## Escalation is a file, never a block
Don't yield on a question you could resolve, or block waiting, while other fronts can progress. Append asks to loop-root `HUMAN.md` (feeds the questions view; add a `session: <id>` line); the human answers async. Acting on an `[answered: …]` block leaves a receipt line: `consumed: YYYY-MM-DD <ref> — <what was done / deferred: why>`. Escalate STRUCTURE, not tactics: stale_count ≥2 → change a frame or environment constraint; ≥4 → HUMAN.md. Stop only when the blocker is unresolvable AND no front progresses AND continuing wastes resources — write the ask, then stop. Enforcement marker: `.claude/loop-enforce-no-question-stop`.

## Watching long local jobs
- Arm a Monitor when remaining-ETA < timeout, or set timeout ≥ 1.5× expected wall. Monitor caps at 60 min and does not chain — for longer jobs re-arm per chunk or watch a status-file artifact via a nohup'd poller with Monitor as the notify layer only. A fired monitor still emits a later timeout notification — noise.
- Teammates have no ScheduleWakeup, and their Monitor notifications can batch-queue until a SendMessage arrives — pair watchers with ground-truth status checks; a quiet teammate at a completion boundary may be notification-starved.
- **A SendMessage to a teammate mid-turn waits unread until that turn ends**, which can be an hour (`~/.claude/teams/<team>/inboxes/<name>.json` shows `"read": false`). An idle teammate does not wake for it either: on 2026-10-26 two sends to an idle lane sat unread for 70 min. To reach a running or idle teammate, `TaskStop` it, then `SendMessage` it: that resumes it from its transcript with your message as its next prompt.
- **A dead teammate still lists as running or idle.** While teammates run, keep a Monitor on `~/Projects/skills/bin/lane-stall-watch <project-dir>/<session-id>/subagents <lanes…>`. It flags a tool call still unanswered past its declared timeout (the call never ran), a model call with no reply (a 529 leaves an `api-request` tail), a lane idle at turn end, and a busy lane holding a message unread past 10 min (UNREAD; on 2026-10-31 one 3 h turn never received six messages). On 2026-10-26 three lanes sat dead or unread for 84, 43 and 12 min before anyone checked.
- **Waiting on another local Claude session: `SendMessage(..., notify_when_idle: true)`** (CC 2.1.236) — one-shot native idle notice, no polling, no timer. Prefer it over ScheduleWakeup/Monitor when the thing you wait on is a peer session (`ListAgents` names it). Bypass-permission sessions may hold inbound peer messages for approval (`crossSessionInbound`/`dialogExpiry`), so a silent peer can be a held delivery, not a dead one.
- Positive-control every watcher filter at arm time: (1) the pattern matches a synthetic event line; (2) it matches 0 lines of the log as it stands. Refuse to arm otherwise.
- Prefer making the JOB observable (per-item progress lines) over wider watches.

## Hindsight metaloop
Grade every substantive external find with a real `rg` over own memos and levers: NOVEL · HAD-PARTS · HAD-LEVER (worst). Every HAD-* obligates an architecture fix; major finds get a blind replay first (arc-agi `loop/HINDSIGHT.md`).

## Killing and liveness
- Never `pkill -f` a substring on multi-job trees. `pgrep -fl '<pat>' | redact-env` first and read every match; anchor to a unique token; prefer the launch-recorded PID.
- Liveness: a quiet log + empty pgrep is grounds to CHECK, never a verdict. `ps -o pid=,etime=,stat=,comm= -p <recorded PID>` plus its child tree (`pgrep -P <PID>`) decides.
- Full-argument process listings (`pgrep -fl`, `ps aux`/`-ef`/`-p`, `ps -o args`) go through `redact-env`: on 2026-10-16 a raw `pgrep -fl` printed a pytest worker's environment, API keys included, into a transcript. `pretool-secret-output-guard.py` blocks the raw forms.

## Subagent death classes
When a subagent or lane dies, parse its failureReason against `~/.claude/references/subagent-death-classes.md` (rate limit, spend limit, 529, auth, sleep, content-classifier stop) before any nudge or re-dispatch. An account-dead or incident-dead fleet is never an idle parent.
