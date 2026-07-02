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
updated: 2026-06-19
related:
  - "[[retrievalqa-chain-type-packing]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[rag-llm-size-vs-retrieval-quality]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[cosine-similarity-vector-retrieval]]"
  - "[[dense-passage-retrieval-dpr]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-moc]]"
source: Distilled from MMR retriever settings (learning capstone chat)
---

# RAG MMR Retriever

**MMR** (Maximal Marginal Relevance) retrieval fetches chunks that are relevant to the question but **not redundant** with each other. Plain top-k similarity often returns five near-duplicate passages — common with PDF tables and repeated example Q&A blocks.

**Layman:** librarian shortlists 20 cards on topic, then picks 5 from different shelves — not five photocopies of one page.

## Where MMR sits in the pipeline

MMR runs **after** cosine similarity already scored the full index. See [[retrieval-ranking-pipeline]]:

```text
embed query → cosine rank all chunks → top fetch_k (20) → MMR → k (5) → LLM
```

| Step | What happens |
|------|----------------|
| Cosine | Every chunk gets a relevance score vs the question — [[cosine-similarity-vector-retrieval]] |
| `fetch_k=20` | Keep the best 20 by score (candidate pool) |
| MMR | Pick **5** that are relevant **and** not redundant with each other |

**Problem without MMR:** top 20 might be five copies of the same Gao survey paragraph — all high cosine, low new information.

MMR balances **relevance** (still similar to the question) and **diversity** (not too similar to chunks already picked).

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

- [[retrieval-ranking-pipeline]]
- [[cosine-similarity-vector-retrieval]]
- [[dense-passage-retrieval-dpr]]
- [[debug-retrieval-without-llm]]
- [[rag-custom-qa-prompt]]
- [[rag-moc]]