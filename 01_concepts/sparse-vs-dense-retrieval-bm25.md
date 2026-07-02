---
title: Sparse vs Dense Retrieval (BM25 vs Embeddings)
tags:
  - rag
  - retrieval
  - bm25
  - embeddings
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[dense-passage-retrieval-dpr]]"
  - "[[cosine-similarity-vector-retrieval]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source: Fourth comparison — BM25 vs dense path (capstone uses dense only)
---

# Sparse vs Dense Retrieval (BM25 vs Embeddings)

Two ways to find relevant chunks. Your capstone uses **dense** only (Watsonx embed + Chroma). **BM25** is the classic **sparse** baseline — worth knowing for interviews and for why DPR papers compare against it.

**Layman:** BM25 = Ctrl+F with smart word counting. Dense = “sounds like the same topic” in math space.

## Comparison

| | **BM25** (sparse / keyword) | **Dense** (capstone / DPR-style) |
|--|-----------------------------|----------------------------------|
| **Idea** | Match words — TF-IDF style | Match meaning via vectors |
| **Good at** | Exact terms: “DPR”, “FAISS”, rare names | Paraphrases: “bad guy” ≈ “villain” |
| **Weak at** | Synonyms, rephrasing | Very rare exact phrases sometimes |
| **Your stack** | Not used | Watsonx embed + Chroma + cosine |

## How each works (one sentence)

**BM25:** score passages by how often query words appear, with dampening for very common words and document length normalization.

**Dense:** embed query and passages into high-dimensional vectors; rank by [[cosine-similarity-vector-retrieval]] (or related distance). See [[dense-passage-retrieval-dpr]] bi-encoder pattern.

## Why the DPR paper matters

Karpukhin et al. argue **dense** retrieval helps **open-domain QA** — questions and answers rarely share exact keywords. Your capstone implements that dense path; you are not running BM25 in parallel.

Production systems sometimes **hybrid** both (sparse + dense, merge scores). Out of scope for capstone 01 — but the interview line is: “we chose dense embeddings; BM25 would miss paraphrases our users actually type.”

## When you might add sparse later

| Signal | Lean sparse | Lean dense |
|--------|-------------|------------|
| SKU codes, legal citations, API symbol names | Strong | Weaker |
| Natural-language questions, docs with varied wording | Weak | Strong |

## See also

- [[dense-passage-retrieval-dpr]]
- [[retrieval-ranking-pipeline]]
- [[cosine-similarity-vector-retrieval]]
- [[rag-moc]]