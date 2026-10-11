---
paths:
  - ".claude/plans/**"
---

# Plan Review Gate

After writing a NEW plan or design that is **non-trivial and consequential**, automatically run plan review. This file loads only for `.claude/plans/`; the global CLAUDE.md carries the same triggers for designs and decisions written in `docs/`, `decisions/` or elsewhere. Continue already-authorized implementation after resolving findings; otherwise prepare a concrete decision for the user. Don't ask permission to run the review.

## Dispatch workflow (plan phase)

1. **VOI scout (one fork)** — if the plan names a load-bearing uncertainty, run deterministic probes `<1min` (grep, read, `git log`) or propose longer actions. See `agent-infra/decisions/2026-06-15-voi-sequenced-review.md`.
2. **Triage** — `review_gate.py triage` on the plan packet → read `dispatch.json` for preset (do not assume `standard`).
3. **Adjudicate** — `/critique model` with triage preset, `--extract --verify`, subparts if packet is large.
4. **Closeout later** — after implementation, `/critique close` reviews **design only**; diff was `/code-review` once. Do not re-review the same diff in critique.

Operational detail lives in `skills/critique/SKILL.md`. Preset promotion: `evals/critique_replay/ROUTING_VERDICT.md`.

**Triggers (all must be true):**
- New plan (not an update applying review findings)
- Has 3+ implementation phases or touches 2+ projects
- Introduces new dependencies, databases, or architectural patterns
- Would take >1 session to reverse if wrong

**Skip if:** Plan is small (<30 lines), single-phase, routine implementation, pure research, touches only one repo with no new deps, or user explicitly says to skip.

**Also trigger, even when a skip condition matches:**
- A decision that retires or deletes a stage, gate, dataset or interface. Route: `/critique model` with the premise scout.
- The first paid or irreversible launch of a new execution route. Route: one repo-access reviewer (`codex exec` or `llmx --mode agent`) traces the route's code path, and each finding is verified at file:line before launch. Packet critics cannot see the code, so `/critique model` is the wrong tool here.

**Post-review step:** After synthesizing model findings, ask yourself: "The review models had less project context than I do. Do I want to revise the cosigned/deferred/rejected list?" Noop is a valid answer — but make the check explicit. State where you disagree and why, don't just adopt wholesale.

**Why:** Cross-model review caught identifier naivety, over-engineering (Neo4j for <100K edges), math errors, and invalid joins in the biomedical KG plan — all invisible to the authoring model. But blind adoption is also wrong — models proposed Kùzu when DuckDB+NetworkX was already working. The value is adversarial pressure, not delegation.

**Evidence for the extra triggers (genomics, 2026-09/10):** the 2026-10-08 critique of a six-stage retirement (two Gemini and two Astra axes plus the premise scout) falsified the `pgx_concordance` premise, because that stage matches CPIC recommendations that no other stage publishes. It also found two other premises unproven, so only three retirements went ahead. The AND-triggers above would not have fired on that decision; the operator asked for the review (`genomics/decisions/2026-10-08-retire-allele-age-phewas-hla-class2.md`). The 2026-09-28 stage-plan review (cross4) produced 15 adopted changes and 5 rejected with evidence from 92 extracted claims (`genomics/docs/audit/2026-09-28-stage-forward-plan.md` §8). Repo-access Sol reviews of new launch routes found 5 fanout defects (2026-09-02, genomics `c73ad1d40`) and 3 confirmed wave-killers (2026-09-04, `genomics/docs/audit/2026-09-04-jw-route-critique/findings.md`) before the first paid runs. Cost: each run extracts 27–95 findings. The anchor check confirms 0–11 of them and leaves most inconclusive. On 09-28 both claims it labeled hallucinated were real. Verify adopted and rejected items at the source.

## Probe-backed numbers rule (estimates feeding owner decisions)

Any LOC/count/size estimate that an owner will approve work against must
either carry its inline derivation probe or be labeled `unprobed —
expect ~2x error`. Within-session calibration (evo 2026-06-11, n=5):
the two items with inline greps in the memo hit their numbers (scripts
263, spec_viewer 1,554); all three without ran ~2x hot or worse
(view_state 330→123, devtools 470→294, defhandler 400→0 — premise
falsified at pilot). Classification-on-contact is the real number;
file-level probes only bound what they directly count.

Same session, reviewer-blindness reconfirmed: packet-only Gemini went
0/5 on repo-grounded findings (all HELD with repo evidence); GPT-5.5
caught two real arithmetic errors and contributed one adopted
mechanism. Packet critique pressure-tests reasoning and arithmetic —
never repo facts. The author closes that gap with greps, per the rules
below.

## Liveness-probe rule

When the plan CONVERTS, REFACTORS, or BUILDS-ON named functions/intents/
handlers, include the literal grep proving each target has production
call/dispatch sites — registration is not liveness. Paste the output into
the plan. A target whose only references are its own definition, tests,
and docstring examples is dead code: the plan becomes "delete it," not
"convert it." Same check on the DOC side of any claimed join: if the plan
cites scenario/spec IDs, grep the doc for them — inventing plausible IDs
is the same phantom-join failure as inventing code fields.

**Evidence (2026-06-10 evo behavior-tables):** plan v1/v2 proposed
converting `:smart-split`'s 8 variants; `grep -rn ":smart-split" src/`
minus its own plugin showed only docstring examples — Enter dispatched
`:context-aware-enter`. Three packet-only review axes missed it; the
repo-access axis caught it. A full plan-write + 2 revision cycles spent
on dead code that a 30-second grep would have killed. The same plan
cited "EDIT-KILL-EOL-01" — `grep -ci kill LOGSEQ_BEHAVIOR_TRIADS.md` → 0.

## Probe-the-join rule

When the plan proposes joining two entities by a named field (`X.id`, `produces_refs`, `owner_path`, `claim_id`, etc.), include the literal grep that proves the join site exists inline. Plan writers consistently invent joins that look right semantically but don't exist in code — and the review models don't catch it because the plan body asserts the join as fact.

For every cross-entity join named in the plan:

1. Locate `<join_field>` with `rg`, then read both entity declarations and the actual mapping/caller. A same-line match is navigation, not proof that the join exists.
2. Confirm key meaning, mapping direction and a live consumer from the implementation or a focused empirical probe. Record that trace in the plan. If it remains unresolved, label the premise unverified and complete the probe before depending on it.
3. For "aggregate via `produces_refs`" / "lookup by `claim_id`" patterns, verify the index direction: a `produces_refs: list[str]` field on StageSpec doesn't index claims unless something maps stage→claim explicitly.

**Evidence (2026-05-12 substrate-closure T4):** plan §5.4 proposed compile-gate aggregation "via `produces_refs`" without probing. `produces_refs` indexes reference databases, not claims. The first T4 dispatch lost ~30 minutes discovering this in code; a 30-second `git grep` would have caught it.

Reviewer models routinely miss this class because they reason from the plan's claims, not from the code. The author must close the gap.
