---
title: RAG LLM Size vs Retrieval Quality
tags:
  - rag
  - llm
  - retrieval
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-troubleshooting-retrieval-first]]"
  - "[[retrievalqa-chain-type-packing]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source: Distilled from capstone chat tuning (learning)
---

# RAG LLM Size vs Retrieval Quality

RAG **offloads facts** to retrieved chunks. The LLM’s job is mostly **read context and compose** — not memorize the corpus. A **smaller / cheaper** model often works for extractive Q&A when retrieval is good.

**Layman:** if the librarian picks the right cards, you don’t need a genius writer — you need someone who reads carefully.

## What retrieval quality buys you

| Good retrieval | LLM can |
|----------------|---------|
| On-topic k chunks | Summarize and quote faithfully |
| Poor retrieval | Hallucinate or abstain badly even with large models |

Fix retrieval first — [[rag-troubleshooting-retrieval-first]].

## Where small models struggle

- **Noisy context** — duplicate chunks (DPR Q&A tables), irrelevant passages in `stuff` prompt
- **Strict abstain** — must refuse when context doesn’t support answer ([[rag-corpus-coverage-and-abstain]])
- **Multi-hop reasoning** across many chunks
- **Following complex prompt rules** (ignore example questions in papers)

Mitigations: MMR retriever, tighter prompt, higher-quality k, not only bigger LLM.

## Tuning knobs (often before upsizing model)

```python
CHAT_LLM_PARAMS = {
    "temperature": 0.2,      # lower = stick to context
    "max_new_tokens": 512,
}
```

Retriever: `search_type="mmr"`, `k` and `fetch_k` tuned to reduce duplicate noise.

## Practical guidance

| Scenario | Start with |
|----------|------------|
| Capstone extractive QA | Small instruct model + good retrieval |
| Open-ended synthesis | Consider larger model **after** retrieval debug clean |
| Cost-sensitive prod | Invest in embed + retriever + corpus coverage |

## See also

- [[pluggable-embedding-models]]
- [[debug-retrieval-without-llm]]
- [[rag-moc]]