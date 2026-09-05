# Epistemic evidence

Historical wording and incident pointers retained from global CLAUDE.md on 2026-09-05. Consult when investigating or revising the corresponding rule; current rules live in the entrypoint. This record does not add a startup read.

**AI-generated text is unverified by default** — pasted by the user or returned by a cross-model query. Check for hallucinated specifics, slop, impracticality (`model-guide` has per-model failure modes); cosign, reject, or complement, never adopt wholesale.

**Frontier timeliness.** Pre-frontier research (GPT-3.5/4, Claude 3, Gemini 1.x) doesn't transfer unless scale-independent — flag it "pre-frontier evidence, validity uncertain". Measure the live model for the RATE; read the papers for the METHOD and its known controls (length-ratio, truncation, blind ID) before measuring (agent-infra research/2026-06-11-frontier-judge-bias-measured.md).

**Reviewer recency blindspot.** A cross-model critique calling a dated, primary-verifiable fact "fabricated" is a verify-at-primary trigger (EDGAR/IR/filing), never a verdict (2026-06-04: two real SEC events called hallucinations by Gemini+GPT).

**Multi-model review routing** (agent-infra decisions/2026-06-14-review-dispatch-consolidation.md): diff/PR → `/code-review` once (never also `/critique` the same diff) · plan/design → `/critique model` with the `review_gate triage` preset · consequential plan write → `~/.claude/rules/plan-review-gate.md` · closeout → `/critique close` · deterministic probes before expensive cross-model adjudication. Economics: `model-guide` skill; transport: `llmx-routing.md`. Both families hallucinate repo internals — verify yourself.

High-stakes tool outputs: note provenance, cross-reference critical numbers. With search tools available, search — never answer "after my cutoff".

1. **Epistemics are architecture.** If it matters and is hookable, there's a hook; instructions cover only semantic predicates.
2. **Append-only for institutional knowledge.** Mark stale, never delete; corrections and changed convictions get NEW entries — belief-change history is calibration data.
3. **Cheapest check first:** preflight (5s) → smoke (1m) → full run.
4. **Data streams have owners** (hook-enforced): raw = read-only; human input = append-only; agent output = rederivable.
5. **Blind first pass:** read new evidence, form an independent assessment, THEN compare to the prior; document divergence.
6. **Tools document themselves for agents:** schema caches, generated indexes, self-describing names.
7. **Never let a proxy stand in for the principal check.** A decision-gating value comes from the principal check; silent fallbacks fail loud (`[DEGRADED]`); a prose page is not the structured source; an in-sample proxy in an eval/RSI loop Goodharts — only an aligned metric stops it. Labeled screens fine, silent substitutes never (agent-infra decisions/2026-06-10-silent-proxy-as-truth.md).
8. **A shared invariant has ONE definition** (taxonomy, schema, grading rule, regex): enforcers LOAD it; a vendored copy only behind a drift-test. Test: would two silently diverging copies be a correctness bug? Not for prose rules or local constants.
9. **The raw transcript is the source of truth; every summary is a proxy.** Grading or reviewing ANY agent run starts with the raw rollout turn-by-turn, never only counters, final-state files, or self-reports (2026-07-18: the first raw read found four findings every derived view had missed).

**A match signal LOCATES; it never DECIDES — and neither does your own inference.** Grep hits, embedding cosine, hit-count screens, a module's NAME, a function's apparent role, a memo's assertion, a linter snapshot: all locators. For any decision that matters ("does X consume Y", "is Z dead", "did this run", a count gating an action) the verdict is a call-site trace, the authoritative declaration, or an empirical run — logged per decision. A claim inherits the grade of its weakest link; "our own memo says so" is a locator too. (2026-07-24 genomics: three importers called "host-only" from module names were container-exclusive; two active worktrees labeled RECLAIM; cost two false escalations and one near-deletion of live work.)
