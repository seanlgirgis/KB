---
title: Dense Passage Retrieval (DPR)
tags:
  - rag
  - retrieval
  - embeddings
  - research
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[sparse-vs-dense-retrieval-bm25]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[cosine-similarity-vector-retrieval]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-moc]]"
source: Karpukhin et al. — in capstone PDF corpus; generalized for Watsonx + Chroma stack
---

# Dense Passage Retrieval (DPR)

**DPR** (Dense Passage Retrieval) is a method from the Karpukhin et al. paper — retrieve passages using **learned dense vectors**, not keyword overlap. It is the research name for the pattern your capstone already runs: embed questions and chunks, then compare vectors.

**Layman:** search by **meaning**, not by whether the exact word appears.

## Sparse vs dense

Full BM25 vs dense table: [[sparse-vs-dense-retrieval-bm25]]. Short version: sparse matches **words**; dense matches **meaning** via embeddings. Your capstone is the dense path; the DPR paper argues dense wins for open-domain paraphrase.

## Bi-encoder pattern

DPR uses a **bi-encoder**:

1. Encode the **question** → query vector
2. Encode each **passage** (chunk) → passage vectors (done at ingest)
3. Retrieve passages whose vectors are closest to the query vector

Your capstone maps this as:

```text
ingest:  embed_documents(chunks)  →  stored in Chroma
chat:    embed_query(question)    →  compared to stored vectors
```

See [[pluggable-embedding-models]] for the shared factory.

## DPR in your corpus vs your code

| | Role |
|--|------|
| **DPR PDF in corpus** | Theory paper you can ask questions about |
| **Watsonx + Chroma** | Production-shaped **implementation** of dense retrieval — not Facebook’s original DPR weights |

When [[rag-custom-qa-prompt]] warns about “paper example Q&A tables,” those often appear in DPR-style benchmark PDFs — high cosine duplicates, low information diversity. That is why [[rag-mmr-retriever]] helps downstream.

## See also

- [[sparse-vs-dense-retrieval-bm25]]
- [[retrieval-ranking-pipeline]] — where DPR-style dense retrieval fits in the full chain
- [[cosine-similarity-vector-retrieval]] — how “closest vector” is measured
- [[rag-mmr-retriever]]
- [[rag-moc]]