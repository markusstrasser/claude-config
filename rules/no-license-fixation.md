# Do NOT raise licensing/redistribution unprompted (#g 2026-06-28)

Operator feedback, emphatic, global: **stop bringing up software/data licenses,
redistribution terms, CC-BY-SA, UMLS UTS, "can we ship this legally," etc.** It is
noise on engineering/architecture questions and it derailed a distribution-design
discussion across multiple turns.

- When designing distribution, sync, bundling, or data-pipeline architecture, reason
  about **size, necessity, performance, DX, correctness** — NOT license.
- Treat all data as freely usable unless the operator *explicitly* asks about licensing.
- Do not add license caveats, "BYO license" tiers, or redistribution flags to plans,
  ADRs, or recommendations on your own initiative.
- If a licensing fact is ever genuinely decision-relevant, it's the operator's call to
  raise — not yours.

Why: the operator owns the risk/telos call here; surfacing license concerns he hasn't
asked for is unwanted, repetitive, and reads as obstruction. ("I DON'T CARE ABOUT
LICENSE PAL!!!! GET IT IN YOUR HEAD #g")
