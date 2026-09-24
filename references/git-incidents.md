# Git incident notes

Read only for shared-index, stash, or rehearsal recovery. Historical examples retained from global CLAUDE.md; current routine rules remain in that entrypoint.

All commits go to main, no branches — commit without asking, granular semantic commits, one logical change each. Never stop to report "ready to commit".

Hook-enforced: no `git add -A`/`.`; no backgrounded or piped `git commit` (capture the rc explicitly).

**Shared checkouts (peer sessions on one tree):**
- **Pathspec every commit:** `git commit -m … -- <your paths>` — a bare commit sweeps a peer's staged files under your message (arc-agi e2ab1ceb).
- **Same-file mixed authorship inverts it:** a pathspec commit takes the file's WORKING-TREE content, so stage only your hunk (`git add -p` / `git apply --cached`), verify `git diff --cached --stat`, then bare-commit.
- **Never bare `git stash`** — it rips peers' in-flight edits out from under live sessions and the pop conflicts. Use `git stash push -- <paths>`, a worktree, or `git show HEAD:<file>`. If you already did: don't resolve their conflict — `git checkout HEAD -- <file>`, save `git stash show -p` outside git, tell the operator.
- Concurrent peers on one repo → `claude --worktree` (a SessionStart hook warns).

**Stale `.git/index.lock` ("Another git process seems to be running"):** a git killed by SIGKILL (`subprocess.run(timeout=)` in a hook, a reaped job) leaves its lock behind, and every later git write prints the same text live contention does, so sleep-and-retry never ends. Stale = `lsof` on the lock is empty AND no `git` process runs in the repo; then remove it. Never judge by lsof alone: `git commit -a/--only` closes index.lock while its hooks run. `skills/hooks/pretool-git-stale-lock.sh` does this on every git command via the Bash dispatcher (every repo since 2026-09-24). Incidents: genomics 2026-09-17 (8 h 25 m blocked), heli 2026-09-24 (~10 min).

**A dry-run PASS is never live authorization.** Destructive or outward-facing shared-state actions gated on the operator need a fresh `AUTHORIZED-LIVE <date>` dated after the rehearsal (2026-07-16: a history rewrite ran on its own dry-run, ratified two days later).

**Derived artifacts are gitignored** — track generator + source, never output; add the ignore glob in the same commit as the generator.

## Commit message format
```
[scope] Verb thing — why
```
`[scope]` from the repo's `.git-scopes` (advisory). Specific verb (wire, diagnose, enforce, extract, drop — not "Add" for everything). Em-dash separates what from why; the why matters most; ≤72 chars, overflow into the body. Body 1–3 lines, motivation first. **No** `Co-Authored-By: Claude`.
Trailers: `Evidence:` (required on governance commits — CLAUDE.md, MEMORY.md, hooks, rules) · `Rejected:` (discarded alternatives; `just discarded`) · `Source:` (cross-project provenance) · `Affects:` · `Session-ID:` (auto by git hook).
Bad: `[api] Add several endpoint improvements and fixes` · Good: `[api] Rate-limit token refresh — prevents 429 cascade under load`
