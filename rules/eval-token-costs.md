# Eval & Measurement: Always Report Token Cost

Any eval, benchmark, or measurement doc/script MUST report **token cost per arm/run** alongside
quality and wall-time — **reasoning/thinking tokens** AND **output tokens** (input too when it
varies by arm). An arm that wins quality at 10× the tokens is usually the wrong pick; "higher
yield" may just be "more expensive." `$0`/subscription lanes still get measured — tokens may not
bill, but they carry latency/throughput. Result tables get explicit `reason_tok`/`out_tok`
columns; acceptance decisions run on **quality-per-token**. Capture via llmx usage logs
(`usage_tail_for` pattern or `--json` usage fields), baked into the harness, not bolted on.

Evidence: 2026-06-17 operator #f/#g ("always also measure the token costs thinking and out");
wave-1 extraction docs reported yield/faithfulness/wall but omitted tokens.
