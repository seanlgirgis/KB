---
title: RetrievalQA chain_type Packing Modes
tags:
  - rag
  - langchain
  - retrievalqa
  - chains
topics:
  - retrieval
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[langchain-rag-chains-overview]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-moc]]"
source:
---

# RetrievalQA chain_type Packing Modes

`RetrievalQA.from_chain_type(..., chain_type="...")` chooses **how retrieved chunks are packed into the LLM prompt** before the model answers. Only **four** string values are valid — this is LangChain vocabulary, not a free-form label (you cannot use `"things"`).

**Layman:** after the retriever pulls index cards, `chain_type` decides whether you **stuff** them all in one envelope, read them one-by-one and summarize, or refine an answer as you flip each card.

## The four options

| `chain_type` | Behavior | Plain English |
|--------------|----------|---------------|
| **`stuff`** | All chunks → **one** prompt → **one** LLM call | Cram every retrieved chunk into a single context block (from *stuffing*) |
| **`map_reduce`** | LLM answers **per chunk** → merge summaries | Many small reads, then combine |
| **`refine`** | Answer from chunk 1 → **refine** with chunk 2, 3, … | Draft answer, improve as more context arrives |
| **`map_rerank`** | Per-chunk answers scored → **pick best** | Try each piece, rank, return winner |

## stuff (default for labs)

```python
RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=False,
)
```

**When to use:**

- Small **`k`** (e.g. 3) and moderate chunk size (e.g. 500 chars)
- Capstone / lab 31 style RAG
- Simplicity — one retrieval, one generation

**Tradeoff:** entire context must fit the model’s input window. Too many or too long chunks → truncation or poor answers → consider `map_reduce` or lower `k`.

## map_reduce

**When to use:** many chunks or long documents that **cannot** fit one prompt.

**Cost:** more LLM calls (one per chunk group + merge) — higher latency and bill.

## refine

**When to use:** iterative polish across ordered chunks; older pattern, less common in quick prototypes.

**Cost:** sequential LLM calls — can add up.

## map_rerank

**When to use:** experimental ranking across chunk-level answers; less common in beginner paths.

## Related knobs (not chain_type)

| Parameter | Meaning |
|-----------|---------|
| `retriever` + `search_kwargs={"k": n}` | How many chunks to retrieve **before** packing |
| `return_source_documents` | Include source `Document`s in Python return — not extra LLM output billing; same stuffed input either way |

## Default for your stack

**`stuff` + `k=3`** — matches [[rag-text-chunking-splitters]] defaults and typical course capstones.

## See also

- [[langchain-rag-chains-overview]] — RetrievalQA vs LCEL and other RAG patterns
- [[rag-moc]]