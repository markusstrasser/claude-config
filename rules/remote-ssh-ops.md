# Remote-VM SSH/SCP Ops — Two Gotchas

Scripting SSH/SCP against remote VMs (genomics + hutter Hetzner fleet). Transcript-verified; both waste real time when missed.

**1. Connection bursts trip the host's `fail2ban` (port-22 ban, ~600s).** Rapid sequential SSH/SCP setup + liveness probes open many short-lived port-22 connections → the VM bans your IP. Tell: `Connection timed out` on port 22 while `ping` still answers — looks like a dead box, is a banned client (forced reboots / idle waits follow). Fix: reuse ONE connection via SSH multiplexing — in `~/.ssh/config`, `ControlMaster auto` + `ControlPersist 600` + `ControlPath ~/.ssh/cm-%r@%h:%p`; or enforce minimum spacing between same-host calls. Don't fan out N parallel `ssh host true` liveness probes.

**2. `pgrep -f <pat>` self-matches its own command line** → inflated count (a "still running" check that never reaches zero; off-by-one process counts). Fix: break the literal with a character class so the pattern text can't match itself — `pgrep -fc '[s]brc_stage_data'` (the `[s]` matches `s`, but the pattern *string* is `[s]brc…`); or exclude by PPID. Applies to any remote process-table parse over SSH.

Evidence: genomics `b38baad8`, hutter `897a2209` — each recurred across 2 distinct sessions (drift-mode, transcript-verified). Escalated `decisions-pending/2026-06-14-remote-ssh-ops-gotchas.md`, approved option A 2026-06-14.
