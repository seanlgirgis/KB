---
title: RAG MMR Retriever
tags:
  - rag
  - retrieval
  - langchain
  - chromadb
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[retrievalqa-chain-type-packing]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[rag-llm-size-vs-retrieval-quality]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-moc]]"
source: Distilled from MMR retriever settings (learning capstone chat)
---

# RAG MMR Retriever

**MMR** (Maximal Marginal Relevance) retrieval fetches chunks that are relevant to the question but **not redundant** with each other. Plain top-k similarity often returns five near-duplicate passages — common with PDF tables and repeated example Q&A blocks.

**Layman:** pick the best card, then the next best card that says something **different**, not the same paragraph five times.

## Syntax (LangChain Chroma)

```python
retriever = vector_store.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 5, "fetch_k": 20},
)
```

| Param | Role |
|-------|------|
| `search_type="mmr"` | Diversity-aware selection |
| `fetch_k` | Candidate pool from vector search (larger) |
| `k` | Final chunks passed to LLM (smaller) |

**Typical pattern:** `fetch_k` ≥ 3× `k` (e.g. fetch 20, return 5).

## vs default similarity

| Mode | Behavior |
|------|----------|
| **Similarity** (default) | Top k by score — may duplicate |
| **MMR** | Balance relevance + diversity |

Use MMR when corpus has repetitive structure (papers with benchmark tables, FAQ-heavy docs).

## Match debug and chat

[[debug-retrieval-without-llm]] must use the **same** `search_type` and `search_kwargs` as chat — or you debug the wrong retrieval.

## Tradeoffs

| Pro | Con |
|-----|-----|
| Less duplicate noise in `stuff` prompt | Slightly more compute |
| Better use of context window | May drop a highly relevant duplicate that still helps |

## When to tune

- LLM echoes example questions from DPR-style tables → try MMR + stricter [[rag-custom-qa-prompt]]
- Answers miss obvious passage → try higher `k` or lower MMR effect (similarity mode)

## See also

- [[debug-retrieval-without-llm]]
- [[rag-custom-qa-prompt]]
- [[rag-moc]]