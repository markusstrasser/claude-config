# Subagent death classes

Moved verbatim from `~/.claude/rules/wakeup-cadence.md` on 2026-10-21 (always-loaded context cut). Read it when a subagent or lane dies.

## Table (parse the failureReason)
| String | Class | Do |
|---|---|---|
| "hit your session limit · resets H:MMpm" | rate limit | parse the clock; ONE ScheduleWakeup at reset+2-5 min; never ask the operator for it, never poll early |
| "hit your monthly spend limit" | account limit, no clock | ONE periodic wakeup (1800-3600s) sending a single cheap resume-probe; the parent grades on-disk artifacts and closes inline meanwhile |
| 529 "Overloaded" | infra incident | after the 2nd, `curl status.claude.com/api/v2/status.json` before any nudge; ONE batch-resume timer (10-15 min); after a 3rd, pull the work inline (the parent lane usually survives); fill dead time with non-LLM work |
| "organization has disabled Claude subscription access" | auth state | no nudge, no timer, no API-key switch (a billing decision); write the ask, work inline; re-dispatch one probe lane only after a `/login` is observed |
| "Your computer went to sleep mid-response" | local suspend | worktree edits survive; ONE SendMessage to the same agent ("git status/diff first, then continue"), never a re-dispatch; prevent with `nohup caffeinate -i -t <secs> &` |
| "safeguards flagged this message … can't respond to this message with Opus 5.5" | content-classifier stop (5.5 adds `bio` and `reasoning_extraction`; the server fallback does not retry `reasoning_extraction`) | never resend the packet; re-dispatch ONCE on `model: sonnet`, briefed around the artifact and never quoting thinking-block text; a second stop → pull the work inline |
| OpenCode `error:provider.quota`, 402 "Insufficient Balance" (DeepSeek platform) | account balance, no clock | never retry or reroute to another account (a billing decision); write the operator-account ask; keep each clone and session and resume with `OC_SESSION` after the top-up; finish small residues inline. `oc_lane.sh` refuses launch on an empty balance (exit 85) and stops loud with exit 86 (genomics 2026-10-22, five lanes) |

An account-dead or incident-dead fleet is never an idle parent.
