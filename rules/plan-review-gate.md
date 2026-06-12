---
paths:
  - ".claude/plans/**"
---

# Plan Review Gate

After writing a NEW plan to `.claude/plans/` that is **non-trivial and consequential**, automatically run `/critique model the plan` before offering to execute. Don't ask — just run the review.

**Triggers (all must be true):**
- New plan (not an update applying review findings)
- Has 3+ implementation phases or touches 2+ projects
- Introduces new dependencies, databases, or architectural patterns
- Would take >1 session to reverse if wrong

**Skip if:** Plan is small (<30 lines), single-phase, routine implementation, pure research, touches only one repo with no new deps, or user explicitly says to skip.

**Post-review step:** After synthesizing model findings, ask yourself: "The review models had less project context than I do. Do I want to revise the cosigned/deferred/rejected list?" Noop is a valid answer — but make the check explicit. State where you disagree and why, don't just adopt wholesale.

**Why:** Cross-model review caught identifier naivety, over-engineering (Neo4j for <100K edges), math errors, and invalid joins in the biomedical KG plan — all invisible to the authoring model. But blind adoption is also wrong — models proposed Kùzu when DuckDB+NetworkX was already working. The value is adversarial pressure, not delegation.

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

1. Run `git grep -n "<join_field>" scripts/ | head -5` and paste the output into the plan.
2. If the field appears alongside the OTHER entity in at least one line, the join exists. If not, the plan is asserting a phantom relationship — STOP and probe before writing more.
3. For "aggregate via `produces_refs`" / "lookup by `claim_id`" patterns, verify the index direction: a `produces_refs: list[str]` field on StageSpec doesn't index claims unless something maps stage→claim explicitly.

**Evidence (2026-05-12 substrate-closure T4):** plan §5.4 proposed compile-gate aggregation "via `produces_refs`" without probing. `produces_refs` indexes reference databases, not claims. The first T4 dispatch lost ~30 minutes discovering this in code; a 30-second `git grep` would have caught it.

Reviewer models routinely miss this class because they reason from the plan's claims, not from the code. The author must close the gap.
