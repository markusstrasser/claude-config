---
paths:
  - ".claude/plans/**"
---

# Plan Review Gate

After writing a NEW plan or design that is **non-trivial and consequential**, settle what probes and quick tests can settle, then run plan review on what remains. This file loads only for `.claude/plans/`; the global CLAUDE.md carries the same triggers for designs and decisions written in `docs/`, `decisions/` or elsewhere. Continue already-authorized implementation after resolving findings; otherwise prepare a concrete decision for the user. Don't ask permission to run the review.

## Dispatch workflow (plan phase)

0. **Settle first.** Answer each load-bearing premise with the probe that settles it (grep, a log query, one experiment run), and build and measure any part whose mistake would show within the session because it fails loudly or a test catches it. Write the answers into the plan. Review only what remains: premises no probe settles, a format or interface many parts will depend on, and costly or irreversible steps. If nothing remains, skip the review and record why in one line of the plan.
1. **VOI scout (one fork)** — if the plan still names a load-bearing uncertainty, run deterministic probes `<1min` (grep, read, `git log`) or propose longer actions. See `agent-infra/decisions/2026-06-15-voi-sequenced-review.md`.
2. **Triage** — `review_gate.py triage` on the plan packet → read `dispatch.json` for preset (do not assume `standard`).
3. **Adjudicate** — `/critique model` with triage preset, `--extract --verify`, subparts if packet is large.
4. **Closeout later** — after implementation, `/critique close` reviews **design only**; diff was `/diff-review` once. Do not re-review the same diff in critique.

Operational detail lives in `skills/critique/SKILL.md`. Preset promotion: `evals/critique_replay/ROUTING_VERDICT.md`.

**Triggers (all must be true):**
- New plan (not an update applying review findings)
- Has 3+ implementation phases or touches 2+ projects
- Introduces new dependencies, databases, or architectural patterns
- Would take >1 session to reverse if wrong
- Something load-bearing remains after step 0: a mistake no probe, test or build-and-measure step within the session would reveal

**Skip if:** Plan is small (<30 lines), single-phase, routine implementation, pure research, touches only one repo with no new deps, every remaining mistake would fail loudly within the session, or user explicitly says to skip.

**Also trigger, even when a skip condition matches:**
- A decision that retires a scientific capability: a stage or dataset whose output someone reads. Route: `/critique model` with the premise scout. Deleting dead code, a redundant gate or a replaced interface during cleanup is not a retirement; it gets the diff review only.
- The first paid or irreversible launch of a new execution route. Route: one repo-access reviewer (`codex exec` or `llmx --mode agent`) traces the route's code path, and each finding is verified at file:line before launch. Packet critics cannot see the code, so `/critique model` is the wrong tool here.

**Why:** Cross-model review caught identifier naivety, over-engineering (Neo4j for <100K edges), math errors, and invalid joins in the biomedical KG plan — all invisible to the authoring model. But blind adoption is also wrong — models proposed Kùzu when DuckDB+NetworkX was already working. The value is adversarial pressure, not delegation.

## Probe-backed numbers rule (estimates feeding owner decisions)

An estimate an owner will approve work against (lines, counts, sizes) carries
the probe that produced it, or says it is unprobed. File-level probes only bound
what they directly count.

## Liveness-probe rule

When the plan CONVERTS, REFACTORS, or BUILDS-ON named functions/intents/
handlers, include the literal grep proving each target has production
call/dispatch sites — registration is not liveness. Paste the output into
the plan. A target whose only references are its own definition, tests,
and docstring examples is dead code: the plan becomes "delete it," not
"convert it." Same check on the DOC side of any claimed join: if the plan
cites scenario/spec IDs, grep the doc for them — inventing plausible IDs
is the same phantom-join failure as inventing code fields.

## Probe-the-join rule

When the plan proposes joining two entities by a named field (`X.id`, `produces_refs`, `owner_path`, `claim_id`, etc.), include the literal grep that proves the join site exists inline. Plan writers consistently invent joins that look right semantically but don't exist in code — and the review models don't catch it because the plan body asserts the join as fact.

For every cross-entity join named in the plan:

1. Locate `<join_field>` with `rg`, then read both entity declarations and the actual mapping/caller. A same-line match is navigation, not proof that the join exists.
2. Confirm key meaning, mapping direction and a live consumer from the implementation or a focused empirical probe. Record that trace in the plan. If it remains unresolved, label the premise unverified and complete the probe before depending on it.
3. For "aggregate via `produces_refs`" / "lookup by `claim_id`" patterns, verify the index direction: a `produces_refs: list[str]` field on StageSpec doesn't index claims unless something maps stage→claim explicitly.

Reviewer models routinely miss this class because they reason from the plan's claims, not from the code. The author must close the gap.

Dated evidence for these rules: `~/.claude/references/plan-review-gate-evidence.md`.
