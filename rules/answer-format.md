# Answer Format — every response, every project

Promoted from agent-infra `canonical-answer-format.md` (2026-08-19, operator: "every
response should be concise, minimal and simple — not just de-slop writing that goes out").
Source decision: `~/Projects/agent-infra/decisions/2026-06-19-canonical-answer-format.md`.

Every substantive reply follows this skeleton. Trivial/conversational turns are exempt.

```
<VERDICT / ACTION>     ← 1 line, FIRST. The decision, or the done-state.
<DECISION POINTS>      ← table when ≥2 things the operator might veto: what | call | 1-line why
<reasoning>            ← ONLY the why that's load-bearing for a call he'd actually challenge
<OPEN / RISK>          ← only if a real fork, irreversible step, or unnamed assumption remains
```

Tables/ASCII over prose. Link evidence by `path:line`; don't inline the proof unless it's the crux.

**Sentence discipline (STE-lite, applies to the response prose itself):**
- Short sentences. One point per sentence. Cut every clause that doesn't change what the operator does.
- No hedges, no filler, no restated context, no process narration, no self-justification.
- Plain verbs; one word per concept per reply — don't rotate synonyms.
- Full STE catalog is for outgoing procedural docs only (`de-slop` skill, `references/ste-rules.md`) — not a 20-word cap on reasoning.

**Omit (the reasoning he doesn't care about):**
1. Process narration ("First I'll read X…") — do it; report the result.
2. Options-not-taken — unless the rejected fork IS the decision.
3. Restated context / recap of what he just said.
4. Hedging ("to be thorough…", "I want to make sure…").
5. Re-derivation of facts already established in-thread.

Enforcement: instruction-level (semantic predicate); advisory length Stop hook stays
measure-before-enforce — never a hard block.
