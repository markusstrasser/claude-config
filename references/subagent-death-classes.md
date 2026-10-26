# Subagent death classes

Moved verbatim from `~/.claude/rules/wakeup-cadence.md` on 2026-10-21 (always-loaded context cut). Read it when a subagent or lane dies.

## Table (parse the failureReason)
| String | Class | Do |
|---|---|---|
| "hit your session limit · resets H:MMpm" | rate limit | parse the clock; ONE ScheduleWakeup at reset+2-5 min; never ask the operator for it, never poll early |
| "You've hit your weekly limit · resets <date> at <time>" | weekly plan limit (every lane dies within a minute) | if the operator says capacity is back, revive each lane at once by raw agent id (below); otherwise ONE ScheduleWakeup at the reset; grade on-disk artifacts meanwhile. Messages sent just before the stop are already in each lane's transcript (genomics 2026-10-26 20:22 JST, six lanes) |
| "hit your monthly spend limit" | account limit, no clock | ONE periodic wakeup (1800-3600s) sending a single cheap resume-probe; the parent grades on-disk artifacts and closes inline meanwhile |
| 529 "Overloaded" | infra incident | after the 2nd, `curl status.claude.com/api/v2/status.json` before any nudge; ONE batch-resume timer (10-15 min); after a 3rd, pull the work inline (the parent lane usually survives); fill dead time with non-LLM work |
| "organization has disabled Claude subscription access" | auth state | no nudge, no timer, no API-key switch (a billing decision); write the ask, work inline; re-dispatch one probe lane only after a `/login` is observed |
| "Your computer went to sleep mid-response" | local suspend | worktree edits survive; ONE SendMessage to the same agent ("git status/diff first, then continue"), never a re-dispatch; prevent with `nohup caffeinate -i -t <secs> &` |
| "safeguards flagged this message … can't respond to this message with Opus 5.5" | content-classifier stop (5.5 adds `bio` and `reasoning_extraction`; the server fallback does not retry `reasoning_extraction`) | never resend the packet; re-dispatch ONCE on `model: sonnet`, briefed around the artifact and never quoting thinking-block text; a second stop → pull the work inline |
| OpenCode `error:provider.quota`, 402 "Insufficient Balance" (DeepSeek platform) | account balance, no clock | never retry or reroute to another account (a billing decision); write the operator-account ask; keep each clone and session and resume with `OC_SESSION` after the top-up; finish small residues inline. `oc_lane.sh` refuses launch on an empty balance (exit 85) and stops loud with exit 86 (genomics 2026-10-22, five lanes) |
| codex `ERROR: Selected model is at capacity` (exit 1) | transient provider capacity | `lane`'s codex worker waits it out in place and starts codex again on the same checkout for ~30 min, then exits 85; continue with `lane resume <name> --no-note`. Never switch models as the fix (arena 2026-10-26, seven gpt-6.1-sol lanes) |

An account-dead or incident-dead fleet is never an idle parent.

## Reviving teammates after the parent's terminal crashes
A resumed parent session has a new name and an empty teammate roster: `SendMessage` to a lane's name returns "No
agent named 'X' is reachable", and `ListAgents` lists no teammates. Send to the raw agent id instead,
`a<name>-<16 hex>`. Find it in the parent transcript's `agentId` fields
(`rg -o '"agentId":"a<name>-[0-9a-f]{16}"' <session>.jsonl`) or in the file names under
`<session>/subagents/agent-<id>.jsonl`. That send resumes the lane from its own transcript with the message as its next
prompt. Before reviving, check that each lane's transcript holds the last instruction sent to it (`rg -c` a phrase from
it). Tell each lane the parent's new name, so its replies reach you. Evidence: genomics 2026-10-26 21:10 JST, six lanes
revived this way after a weekly-limit stop and a terminal crash.
