---
title: Retrieval Ranking Pipeline (Query to Chunks)
tags:
  - rag
  - retrieval
  - embeddings
  - chromadb
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[sparse-vs-dense-retrieval-bm25]]"
  - "[[dense-passage-retrieval-dpr]]"
  - "[[cosine-similarity-vector-retrieval]]"
  - "[[rag-mmr-retriever]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source: Distilled from capstone chat retriever chain (DPR-style dense + cosine + MMR)
---

# Retrieval Ranking Pipeline (Query to Chunks)

Three separate ideas chain together every time your capstone chat answers a question. **Dense retrieval** (DPR family) produces vectors; **cosine similarity** scores every chunk; **MMR** picks a diverse final set before the LLM sees text.

**Layman:** embed the question → score all index cards by meaning → shortlist the best 20 → pick 5 that aren’t photocopies → hand those to the writer.

## The chain (capstone defaults)

```text
Question text
    → embed_query()           → question vector
    → cosine similarity       → score all chunk vectors in Chroma
    → top fetch_k (20)        → candidate pool
    → MMR re-rank             → pick diverse k (5)
    → chunk page_content      → stuffed into LLM prompt
```

LangChain wiring (same as chat):

```python
retriever = vector_store.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 5, "fetch_k": 20},
)
```

Cosine ranking is **implicit** inside Chroma’s vector search — you don’t call it yourself unless debugging ([[debug-retrieval-without-llm]]).

## Three roles

| Term | Role | Analogy |
|------|------|---------|
| [[dense-passage-retrieval-dpr]] | **Why** use dense vectors for retrieval | Search by meaning, not exact words |
| [[cosine-similarity-vector-retrieval]] | **Score** each chunk vs the question | How close is this chunk’s meaning? |
| [[rag-mmr-retriever]] | **Choose** final k without duplicates | Best 5, not best 5 clones |

## Why dense (not BM25)

Your capstone does not use BM25. [[sparse-vs-dense-retrieval-bm25]] explains the tradeoff; DPR and your stack bet on **meaning** over exact keywords.

## Your stack ≈ DPR pattern (not the original model)

| DPR paper (Karpukhin et al.) | Your capstone |
|------------------------------|---------------|
| Bi-encoder: embed query + embed passages | Watsonx `embed_query` + ingest `embed_documents` |
| Compare vectors, retrieve top passages | Chroma + cosine similarity |
| (Paper trains its own encoders) | You use Watsonx embeddings — same **pattern**, different model |

You are not running Facebook’s DPR checkpoint; you are running the **same retrieval architecture**.

## Interview one-liner

> DPR is dense retrieval via embeddings; Chroma ranks with cosine similarity; MMR re-ranks for relevance plus diversity before we stuff k chunks into the LLM.

## Debug order

1. [[debug-retrieval-without-llm]] — see which 5 chunks MMR returns
2. Optional cosine compare on two different questions — near **1.0** on unrelated text → [[watsonx-truncate-input-tokens-rag-trap]]
3. Tune MMR / prompt only after retrieval looks sane

## See also

- [[rag-ingest-chat-two-script-architecture]]
- [[retrievalqa-chain-type-packing]] — what happens after chunks reach the LLM
- [[rag-moc]]