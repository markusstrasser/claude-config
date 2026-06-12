---
paths:
  - "research/**"
---

# Research Tool Gotchas — Third-Party Constraints

Operational limits of external tools we can't fix. Our own MCP gotchas are in the research MCP's `instructions` field (loaded when MCP is active).

> Tool ROUTING (which engine for which need): `~/Projects/skills/research/references/tool-routing.md` — the global quick-subset (`research-api-routing.md`) was deleted 2026-06-12; the skill is the single owner.

- **PubMed via S2 — allele-specific queries fail** — S2 keyword matching is noisy for pharmacogenomics allele names (CYP3A4*22). Use Exa for PGx queries.
- **Researcher subagents exhaust turns without synthesizing** — prompt instructions get buried. Use CORAL epochs (parent-controlled 12-turn dispatches with file output). Never dispatch "find everything" — one axis per agent, max 8 searches.
- **Firecrawl credit exhaustion is silent** — no pre-check for remaining credits. Check manually before planning a Firecrawl-dependent workflow.
- **Heavy JS docs (Mintlify/Next.js) resist scraping MCPs** — `curl | perl | rg` is more reliable than Firecrawl or WebFetch for these sites.
- **Exa broad queries return massive, noisy results** — always set `contextMaxCharacters: 3000` on broad sweeps. Full text only for narrow queries. Oversized results can't be parsed.
- **Exa `crawling_exa` with multiple URLs may return only one** — check all URLs were returned.
- **Perplexity needs specific trial names for clinical data** — broad queries lack exact numbers. Two rounds: broad first, then narrow with exact trial/journal names.
- **Brave 429s on parallel use** — use serially, or as single-call fallback after Exa.
- **Perplexity batch ceiling: N ≤ 10 safe; N ≥ 25 risky** (rubber-stamps user-supplied numerical specifics at scale).

For the full 2026-05-19 N=60 failure-mode catalogue (museum-URL fetch failures, pretool burst-hook ceiling, spatial-orientation prose inversion, composer/responsory disambiguation, stylized-vs-literal interpretive claims): see `~/Projects/skills/research/references/tool-routing.md` §Failure modes worth knowing.
