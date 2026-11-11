# Plan review gate: evidence

Moved from `rules/plan-review-gate.md` on 2026-11-11. The rules stay there; these dated incidents are why they exist.

**Evidence for the extra triggers (genomics, 2026-09/10):** the 2026-10-08 critique of a six-stage retirement (two Gemini and two Astra axes plus the premise scout) falsified the `pgx_concordance` premise, because that stage matches CPIC recommendations that no other stage publishes. It also found two other premises unproven, so only three retirements went ahead. The AND-triggers above would not have fired on that decision; the operator asked for the review (`genomics/decisions/2026-10-08-retire-allele-age-phewas-hla-class2.md`). The 2026-09-28 stage-plan review (cross4) produced 15 adopted changes and 5 rejected with evidence from 92 extracted claims (`genomics/docs/audit/2026-09-28-stage-forward-plan.md` §8). Repo-access Sol reviews of new launch routes found 5 fanout defects (2026-09-02, genomics `c73ad1d40`) and 3 confirmed wave-killers (2026-09-04, `genomics/docs/audit/2026-09-04-jw-route-critique/findings.md`) before the first paid runs. Cost: each run extracts 27–95 findings. The anchor check confirms 0–11 of them and leaves most inconclusive. On 09-28 both claims it labeled hallucinated were real. Verify adopted and rejected items at the source.

**Evidence for step 0 (arena, 2026-10-25):** the differential-oracle plan listed three unchecked premises. One awk over a harness run's log settled the first: after the arena opened, over 90% of the world thread's 8,976 rolls in scenario m7 came from creature code, which the arena has none of (RandomMovementGenerator, SmartScript timers, model choice), so roll records must carry their map. That changed the design, and a packet reviewer could not have seen it. Operator: "if something is easily settleable or testable ... let's get the quick answers before critique or maybe even not need a critique afterwards etc bc it's simple or throws anyway if not".

Same session, reviewer-blindness reconfirmed: packet-only Gemini went
0/5 on repo-grounded findings (all HELD with repo evidence); GPT-5.5
caught two real arithmetic errors and contributed one adopted
mechanism. Packet critique pressure-tests reasoning and arithmetic —
never repo facts. The author closes that gap with greps, per the rules
below.

**Evidence (2026-06-10 evo behavior-tables):** plan v1/v2 proposed
converting `:smart-split`'s 8 variants; `grep -rn ":smart-split" src/`
minus its own plugin showed only docstring examples — Enter dispatched
`:context-aware-enter`. Three packet-only review axes missed it; the
repo-access axis caught it. A full plan-write + 2 revision cycles spent
on dead code that a 30-second grep would have killed. The same plan
cited "EDIT-KILL-EOL-01" — `grep -ci kill LOGSEQ_BEHAVIOR_TRIADS.md` → 0.

**Evidence (2026-05-12 substrate-closure T4):** plan §5.4 proposed compile-gate aggregation "via `produces_refs`" without probing. `produces_refs` indexes reference databases, not claims. The first T4 dispatch lost ~30 minutes discovering this in code; a 30-second `git grep` would have caught it.

## Probe-backed numbers rule (original text and calibration, moved 2026-11-11)

Any LOC/count/size estimate that an owner will approve work against must
either carry its inline derivation probe or be labeled `unprobed —
expect ~2x error`. Within-session calibration (evo 2026-06-11, n=5):
the two items with inline greps in the memo hit their numbers (scripts
263, spec_viewer 1,554); all three without ran ~2x hot or worse
(view_state 330→123, devtools 470→294, defhandler 400→0 — premise
falsified at pilot). Classification-on-contact is the real number;
file-level probes only bound what they directly count.
